# Docker Güvenliği (Container Hardening) 🐳

Senin yaşadığın senaryo tam olarak buydu:
`RCE Açığı → Root Container → Tam Sistem Erişimi → Cryptominer/DDoS → 💀`

İşte bu zinciri kırmak için **kapsamlı** Docker güvenlik rehberi.

## 1. ASLA Root Olarak Çalıştırma (En Kritik!) �

Varsayılan olarak Docker konteynerleri `root` yetkisiyle çalışır. Konteynerden kaçan biri host makinede de `root` olur!

### Çözüm 1: Dockerfile'da USER Tanımla (En İyisi)

```dockerfile
# ✅ DOĞRU Dockerfile
FROM node:18-alpine

# Sistem kullanıcısı oluştur (UID: 1001)
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

WORKDIR /app
COPY --chown=appuser:appgroup . .

# Root'tan çık
USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
```

### Çözüm 2: Docker Compose'da Zorla

```yaml
services:
  app:
    image: my-app
    user: "1001:1001" # UID:GID
```

---

## 2. Read-Only Filesystem (Dosya Yazmayı Kapat) 📁

Saldırgan içeri girse bile dosya yazamasın, malware indiremesin.

```yaml
services:
  app:
    image: my-app
    read_only: true
    tmpfs:
      - /tmp:size=100M,mode=1777
      - /var/run:size=50M
    volumes:
      - ./data:/app/data:rw # Sadece gerekli yere yazma izni
```

---

## 3. Resource Limitleri (Miner Koruması) ⚡

CPU %100'e dayamasın, RAM tüketmesin.

```yaml
services:
  app:
    image: my-app
    deploy:
      resources:
        limits:
          cpus: "0.5" # Max yarım işlemci
          memory: 512M # Max 512MB RAM
        reservations:
          cpus: "0.25"
          memory: 256M
    pids_limit: 100 # Fork bomb koruması
    mem_swappiness: 0 # Swap yasak
```

---

## 4. Network İzolasyonu 🌐

Konteynerler dışarıya kafasına göre çıkamasın.

```yaml
services:
  backend:
    image: my-api
    networks:
      - internal-net # Sadece bu ağdaki veritabanına erişebilir

networks:
  internal-net:
    driver: bridge
    internal: true # Dış dünyaya (İnternete) erişim YOK!
```

> **Not:** `network_mode: host` kullanmak yasaktır!

---

## 5. Capabilities & Privileges 🔐

Docker'ın "ben her şeyi yaparım" yetkilerini tırpanlayın.

```yaml
services:
  app:
    cap_drop:
      - ALL # Önce her şeyi kapat
    cap_add:
      - NET_BIND_SERVICE # Sadece port açabilsin
    security_opt:
      - no-new-privileges:true # Privilege escalation (yetki yükseltme) engelle
```

### Tehlikeli Alanlar ⛔

- `--privileged`: **ASLA kullanma!** Host makinenin tüm cihazlarına erişim verir.
- `/var/run/docker.sock`: **Mount etme!** Konteynerin diğer konteynerleri silmesine/yaratmasına izin verir.

---

## 6. Secrets Yönetimi (Şifre Saklama) 🔑

Environment değişkenleri (`-e PASSWORD=123`) `docker inspect` ile görülebilir. Docker Secrets kullanın.

```yaml
services:
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

---

## 7. Komple Güvenli `docker-compose.yml` Örneği 🏆

Bunu kopyala ve projelerinde şablon olarak kullan:

```yaml
version: "3.8"

services:
  app:
    image: my-app:latest

    # 1. Non-root user
    user: "1001:1001"

    # 2. Read-only filesystem
    read_only: true
    tmpfs:
      - /tmp:size=100M,mode=1777

    # 3. Resource limits
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: 512M
    pids_limit: 100

    # 4. Capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true

    # 5. Network isolation
    networks:
      - frontend

    # 6. Secrets
    secrets:
      - api_key

    # 7. Logging limiti (Diski doldurmasın)
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

    # 8. Health check (Zombie container tespiti & Auto-restart)
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  frontend:
    driver: bridge

secrets:
  api_key:
    file: ./secrets/api_key.txt
```

---

## 8. Güvenlik Kontrol Scripti �

Mevcut konteynerlerin ne kadar güvenli? Bu script ile tara:

**Dosya:** `docker_security_check.sh`

```bash
#!/bin/bash
echo "=== 🐳 DOCKER GÜVENLİK KONTROLÜ ==="

echo -e "\n[1] Root olarak çalışan container'lar:"
for c in $(docker ps -q); do
    USER=$(docker exec $c whoami 2>/dev/null || echo "N/A")
    NAME=$(docker inspect --format '{{.Name}}' $c)
    if [ "$USER" = "root" ]; then
        echo "  ⚠️  $NAME: ROOT! (Düzeltilmeli)"
    else
        echo "  ✅ $NAME: $USER"
    fi
done

echo -e "\n[2] Privileged container'lar:"
docker ps -q | xargs docker inspect --format '{{.Name}}: Privileged={{.HostConfig.Privileged}}' | grep "true" || echo "  ✅ Yok"

echo -e "\n[3] Docker socket mount edilmiş:"
docker ps -q | xargs docker inspect --format '{{.Name}}: {{.Mounts}}' | grep "docker.sock" || echo "  ✅ Yok"

echo -e "\n[4] Resource limiti OLMAYAN container'lar:"
for c in $(docker ps -q); do
    NAME=$(docker inspect --format '{{.Name}}' $c)
    MEM=$(docker inspect --format '{{.HostConfig.Memory}}' $c)
    if [ "$MEM" = "0" ]; then
        echo "  ⚠️  $NAME: Limit yok! (Riskli)"
    fi
done

echo -e "\n[5] Host network kullananlar:"
docker ps -q | xargs docker inspect --format '{{.Name}}: {{.HostConfig.NetworkMode}}' | grep "host" || echo "  ✅ Yok"

echo -e "\n=== KONTROL TAMAMLANDI ==="
```

### Scripti Çalıştırma

```bash
# Scripti kaydet ve çalıştırılabilir yap
sudo nano /usr/local/bin/docker_security_check.sh
# (Yukarıdaki içeriği yapıştır)

sudo chmod +x /usr/local/bin/docker_security_check.sh

# Çalıştır
docker_security_check.sh
```

---

## 9. Image Güvenliği 🖼️

Container'ların temeli olan image'lar güvenli değilse, üstüne ne yaparsanız yapın boştur.

### Güvenilir Image Kullan

```bash
# ❌ YANLIŞ: Random kullanıcı image'ı (İçinde ne olduğu belirsiz)
docker pull randomuser/nginx-super

# ✅ DOĞRU: Official veya Verified Publisher
docker pull nginx:alpine
docker pull bitnami/nginx
```

### Minimal Base Image (Alpine Tercih Et)

```dockerfile
# ❌ Büyük image = Daha fazla güvenlik açığı, daha yavaş
FROM node:18          # ~900MB, yüzlerce gereksiz paket

# ✅ Minimal image = Küçük attack surface, hızlı
FROM node:18-alpine   # ~100MB, sadece gerekli paketler
```

### Image Tarama (Trivy)

Image'ı production'a almadan önce mutlaka tarayın.

```bash
# Kurulum
sudo apt install trivy -y

# Image tara
trivy image nginx:latest
trivy image my-app:latest

# CI/CD'de: HIGH/CRITICAL varsa build'i durdur
trivy image --exit-code 1 --severity HIGH,CRITICAL my-app:latest
```

---

## 10. Docker Daemon Hardening 🔧

Docker servisini (Daemon) güvenli hale getirmek için `/etc/docker/daemon.json` dosyasını yapılandırın.

**Dosya:** `/etc/docker/daemon.json`

```json
{
  "icc": false,
  "userns-remap": "default",
  "no-new-privileges": true,
  "live-restore": true,
  "userland-proxy": false,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

**Uygula:**

```bash
sudo systemctl restart docker
```

| Ayar                | Açıklama                                                                    |
| :------------------ | :-------------------------------------------------------------------------- |
| `icc: false`        | Container'lar arası varsayılan iletişimi kapat (Herkes herkesle konuşamaz). |
| `userns-remap`      | Container root ≠ Host root (İzolasyon).                                     |
| `no-new-privileges` | Privilege escalation engelle.                                               |
| `live-restore`      | Docker restart olunca container'lar ölmesin.                                |
| `log-driver`        | Logların diski doldurmasını engelle (Log Rotation).                         |

## Özet: Saldırı vs Önlem 🛡️

| Saldırı Tipi           | Önlem                                      |
| :--------------------- | :----------------------------------------- |
| **Container Breakout** | Non-root User, Read-only FS, No-Privileges |
| **Crypto Mining**      | Resource Limits (CPU/RAM)                  |
| **DDoS / Scanning**    | Internal Network (İzolasyon)               |
| **Data Theft**         | Docker Secrets                             |

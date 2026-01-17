# App Launch Checklist (Docker) 🐳

Uygulamanızı Docker ile canlıya almadan önce bu teknik detayları kontrol edin.

## 1. Container Sağlığı 🩺

- **Restart Policy:** `restart: always` veya `unless-stopped` ayarlı mı? (Sunucu reboot olunca kalkmalı).
- **Healthcheck:** `docker ps` yazdığınızda `(healthy)` ibaresini görüyor musunuz?
  ```yaml
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:80/health"]
    interval: 30s
    retries: 3
  ```

## 2. Kaynak Yönetimi ⚖️

- **Limits:** CPU ve RAM limiti koydunuz mu? (Koymazsanız Memory Leak tüm sunucuyu kilitler).
  ```yaml
  deploy:
    resources:
      limits:
        cpus: "1.0"
        memory: 512M
  ```

## 3. Loglama Stratejisi 📜

- **Driver:** Docker varsayılan olarak sonsuz log yazar. Diski doldurmamak için limit şart.
  ```yaml
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  ```

## 4. Veri Kalıcılığı (Persistence) 💾

- **Volumes:** Veritabanı verisi (MySQL/Postgres) `volume` olarak mount edildi mi? (Bind mount veya Named volume).
  - _Test:_ Container'ı sil (`docker rm -f`) ve tekrar başlat. Veriler duruyor mu?

## 5. Çevresel Değişkenler (ENV) 🌍

- **Debug Mode:** `ASPNETCORE_ENVIRONMENT` veya `NODE_ENV` değişkeni **Production** mı?
- **Secrets:** API Key'ler kodun içinde (hardcoded) değil, değil mi?

## Verify Commands ✅

```bash
# 1. Limitleri Gör
docker stats --no-stream

# 2. Log Ayarını Gör
docker inspect --format='{{.HostConfig.LogConfig}}' <container_id>

# 3. Restart Policy Gör
docker inspect --format='{{.HostConfig.RestartPolicy.Name}}' <container_id>
```

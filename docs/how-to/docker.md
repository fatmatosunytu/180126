# Docker Kurulumu ve Konfigürasyonu

Sunucularımızda uygulamaları izole etmek ve kolay yönetmek için **Docker** ve **Docker Compose** kullanıyoruz.

## 1. Kurulum (Resmi Repodan)

Ubuntu'nun kendi deposundaki docker genelde eskidir. Resmi Docker deposunu kullanarak en güncel sürümü kuralım.

Bu işlemi tek komutla yapan "Convenience Script"i kullanmak en pratiğidir:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Yetkilendirme (Sudo'suz Docker)

Her komutun başına `sudo` yazmamak için kullanıcımızı `docker` grubuna ekleyelim:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Test edin:

```bash
docker version
# Hata almıyorsanız tamamdır.
```

## 2. Docker Storage (Kritik)

Varsayılan olarak Docker, tüm imajları ve volume'leri `/var/lib/docker` altında tutar. Bu klasör "Boot Volume" üzerindedir. Eğer bu disk dolarsa sunucu çöker. Eğer sunucu bozulursa verileriniz gider.

Bu yüzden Docker verilerini harici **Block Volume**'e taşımalıyız.

> [!IMPORTANT]
> Önce [Oracle Block Volume](../../cloud/oracle/storage.md) rehberindeki adımları tamamlayıp diski `/mnt/blockvolume` altına mount ettiğinizden emin olun.

### Data Root Değiştirme Adımları

1.  **Klasörü Hazırla:**

    ```bash
    # Harici diskte docker için bir klasör aç
    sudo mkdir -p /mnt/blockvolume/docker-data
    ```

2.  **Konfigürasyon Dosyasını Düzenle:**
    `/etc/docker/daemon.json` dosyasını oluşturun veya düzenleyin:

    ```bash
    sudo nano /etc/docker/daemon.json
    ```

    İçeriği şu şekilde olmalıdır:

    ```json
    {
      "data-root": "/mnt/blockvolume/docker-data",
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "10m",
        "max-file": "3"
      }
    }
    ```

    _(Not: Log ayarlarını da ekledik ki loglar diski doldurmasın)_

3.  **Docker'ı Yeniden Başlat:**

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    ```

4.  **Doğrulama:**
    ```bash
    docker info | grep "Docker Root Dir"
    ```
    Çıktıda `/mnt/blockvolume/docker-data` görüyorsanız işlem başarılıdır! 🎉

## 3. Temel Komutlar

```bash
# Arkaplanda çalıştır
docker compose up -d

# Logları izle
docker compose logs -f

# Tüm sistemi temizle (Kullanılmayan imajlar, containerlar)
docker system prune -a
```

## 4. Docker Compose Nedir?

Tek tek `docker run` komutları yazmak yerine, projenin kökünde bir `docker-compose.yml` dosyası oluştururuz.

Örnek bir `docker-compose.yml`:

```yaml
services:
  web:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

Çalıştırmak için:

```bash
docker compose up -d
```

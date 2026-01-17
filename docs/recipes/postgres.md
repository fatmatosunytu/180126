# PostgreSQL Docker Hardening 🐘

Veritabanı, en değerli varlığınızdır. Standart `postgres` kurulumu geliştirme için iyidir ama production için yeterince güvenli değildir.

## 1. Secrets Kullanımı (Şifre Gizleme) 🔑

En büyük hata şifreyi `POSTGRES_PASSWORD=12345` diye açık açık yazmaktır. Docker Secrets kullanın.

**docker-compose.yml:**

```yaml
services:
  db:
    image: postgres:15-alpine
    environment:
      # Şifreyi environment'tan değil, dosyadan oku
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
      POSTGRES_USER: myuser
      POSTGRES_DB: mydb
    secrets:
      - db_password
    volumes:
      - db_data:/var/lib/postgresql/data
      # Özel config dosyası (Opsiyonel)
      #- ./postgresql.conf:/etc/postgresql/postgresql.conf

    # Dış dünyaya asla port açma! (ports: - "5432:5432" YAPMA)
    # Sadece internal ağdaki backend erişsin.
    networks:
      - backend-net

    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 1G

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## 2. Hardening (Sıkılaştırma)

Postgres process'i normalde `postgres` kullanıcısı ile çalışır (Non-root). Ancak dosya sistemini kısıtlayabiliriz.

```yaml
services:
  db:
    # ...
    # Veri dizini hariç her yeri kilitle
    read_only: true
    tmpfs:
      - /tmp
      - /var/run/postgresql

    # Shm size artırmazsanız performans düşer
    shm_size: 256mb
```

## 3. PostgreSQL Konfigürasyonu (Tuning) 🛠️

Varsayılan ayarlar çok muhafazakardır. Production için `postgresql.conf` dosyasını oluşturun ve mount edin.

**Örnek `postgresql.conf` (1GB RAM sunucu için):**

```ini
# Bağlantılar
listen_addresses = '*'
max_connections = 100

# Hafıza
shared_buffers = 256MB      # RAM'in %25'i
work_mem = 4MB              # shared_buffers / max_connections
maintenance_work_mem = 64MB

# Write Ahead Log (WAL) - Veri güvenliği
wal_level = replica
max_wal_size = 1GB
min_wal_size = 80MB

# Loglama (Saldırı tespiti için)
log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'ddl'       # Sadece tablo değişimlerini logla (CREATE/DROP)
```

## Özet

1.  **Port Açma:** `ports` kısmını sil. Sadece backend servisi `networks` üzerinden erişsin.
2.  **Secrets:** Şifreyi dosyadan okut.
3.  **Config:** Varsayılan ayarlarla performansı öldürme.

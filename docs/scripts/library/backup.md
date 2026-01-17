# Database Backup Script 💾

Basit, güvenilir ve rotasyonlu (eskileri silen) yedekleme scripti.

## Özellikler

- Docker içindeki Postgres veya MySQL'i yedekler.
- Yedekleri tarihli (`db-2023-10-27.sql.gz`) kaydeder.
- **Rotasyon:** 7 günden eski dosyaları otomatik siler.
- **Sıkıştırma:** Gzip ile yer tasarrufu sağlar.

## Kullanım

```bash
nano /usr/local/bin/backup-db.sh
chmod +x /usr/local/bin/backup-db.sh

# Crontab (Her gece 02:00)
0 2 * * * /usr/local/bin/backup-db.sh
```

## Kaynak Kod

```bash
#!/bin/bash
set -euo pipefail

# --- CONFIG ---
BACKUP_DIR="/var/backups/db"
CONTAINER_NAME="postgres_container_name"
DB_USER="postgres"
DB_NAME="myapp_db"
RETENTION_DAYS=7
DATE=$(date +%Y-%m-%d_%H%M)
# --------------

mkdir -p $BACKUP_DIR

echo "💾 Yedekleme Basliyor: $DATE"

# 1. Dump Al (Postgres)
# MySQL icin: docker exec $CONTAINER_NAME mysqldump -u... kullanin
docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME | gzip > "$BACKUP_DIR/db-$DATE.sql.gz"

# 2. Basari Kontrolu
if [ $? -eq 0 ]; then
    echo "✅ Yedek Basarili: $BACKUP_DIR/db-$DATE.sql.gz"
else
    echo "❌ Yedek ALINAMADI!"
    exit 1
fi

# 3. Rotasyon (Eskileri Sil)
echo "🗑️ $RETENTION_DAYS gunden eski yedekler siliniyor..."
find $BACKUP_DIR -name "db-*.sql.gz" -mtime +$RETENTION_DAYS -delete

# 4. (Opsiyonel) Offsite Copy
# rsync -avz $BACKUP_DIR user@backupserver:/remote/location/
```

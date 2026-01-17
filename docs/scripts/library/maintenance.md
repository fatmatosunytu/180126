# Maintenance (Temizlik) Scripti 🧹

Bu script, sunucuda zamanla biriken "dijital atıkları" temizler ve diskin dolmasını engeller.

## Ne Yapar?

1.  **Docker Prune:** Kullanılmayan image, container ve networkleri siler.
2.  **Journal Vacuum:** 3 günden eski systemd loglarını siler.
3.  **Apt Autoremove:** Gereksiz paketleri temizler.
4.  **Disk Check:** Doluluk %80'i geçtiyse uyarı verir (Mail/Slack entegrasyonu eklenebilir).

## Kullanım (Cron)

Haftalık çalışması için crontab'a ekleyin:

```bash
# Scripti kaydet
nano /usr/local/bin/maintenance.sh
chmod +x /usr/local/bin/maintenance.sh

# Crontab aç
crontab -e
# Şunu ekle (Her Pazar gece 03:00):
0 3 * * 0 /usr/local/bin/maintenance.sh >> /var/log/maintenance.log 2>&1
```

## Kaynak Kod

```bash
#!/bin/bash
set -u

echo "🧹 Temizlik Basladi: $(date)"

# 1. Docker Temizligi (Durdurulmus her seyi siler)
if command -v docker &> /dev/null; then
    echo "🐳 Docker System Prune..."
    # -a: Kullanilmayan image'lari da sil
    # -f: Onay sorma
    docker system prune -af --volumes
fi

# 2. Log Temizligi (Systemd)
echo "📜 Journalctl Vacuum (3 gun)..."
journalctl --vacuum-time=3d

# 3. Paket Temizligi
echo "📦 Apt Autoremove..."
apt-get autoremove -y
apt-get clean

# 4. Disk Kontrol
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
if [ "$USAGE" -gt 85 ]; then
    echo "🚨 UYARI: Disk Doluluk Orani %$USAGE!"
    # Buraya mail atma veya Slack webhook kodu eklenebilir
    # curl -X POST -H 'Content-type: application/json' --data '{"text":"Disk Dolu!"}' HOOK_URL
else
    echo "✅ Disk Durumu: %$USAGE (Normal)"
fi

echo "🏁 Temizlik Bitti: $(date)"
```

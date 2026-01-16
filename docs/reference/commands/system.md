# Sistem ve Süreç (Process) Yönetimi

Servisleri yönetmek ve kilitlenen programları sonlandırmak.

## 1. Servis Yönetimi (Systemd)

```bash
# Servis durumu
systemctl status nginx

# Başlat / Durdur / Yeniden Başlat
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx

# Başlangıçta açılsın / açılmasın
sudo systemctl enable nginx
sudo systemctl disable nginx

# Başarısız olan servisleri listele
systemctl --failed

# Gelişmiş Status Parametreleri
systemctl status nginx --no-pager  # Pager (less) kullanmadan çıktı ver
systemctl status nginx -l          # Satırları kesme (Full log)
systemctl status nginx -n 50       # Son 50 satır logu göster
```

### Servis Düzenleme (Advanced)

Servis dosyasını (`/lib/systemd/system/...`) elle açmak yerine bu komutu kullanın. Bu, yapılan değişiklikleri `/etc/systemd/system/` altına güvenli bir kopya (override) olarak kaydeder.

```bash
sudo systemctl edit nginx --full
```

## 2. Log İnceleme (Journalctl)

Systemd servislerinin loglarına bakmak için `journalctl` kullanılır.

```bash
# Bir servisin loglarını gör (Son sayfadan başla)
journalctl -u nginx -e

# Canlı izle (Tail -f gibi)
journalctl -u ssh -f

# Sadece bugünkü loglar
journalctl -u nginx --since "today"
```

## 3. Süreç Yönetimi (Ps & Kill)

Bir program donarsa ne yapılır?

```bash
# Çalışan süreçleri listele
ps aux | grep python

# Bir süreci öldür (PID numarasını ps ile bulup yazın)
kill 1234

# Zorla öldür (Force kill - Dikkatli kullanın)
kill -9 1234

# İsme göre öldür
pkill -f "python main.py"
```

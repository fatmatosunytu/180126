# Ağ ve Bağlantı Komutları

Portlar, IP adresleri ve bağlantı testleri için İsviçre çakısı komutlar.

## 1. Port Kontrolü (Netstat muadili)

Hangi servis hangi portu dinliyor?

```bash
# Dinleyen portları göster (Process ID ile beraber)
sudo ss -lntp

# l: listening, n: numeric, t: tcp, p: process
```

## 2. IP Adresleri

```bash
# IP adreslerini göster
ip a
# veya
ip addr show

# Routing tablosu (Gateway neresi?)
ip route
```

## 3. Bağlantı Testi (Curl & Ping)

```bash
# Bir siteye bağlanabiliyor muyum? (Sadece başlıkları al)
curl -I https://google.com

# DNS çözülüyor mu?
dig google.com +short
# veya
nslookup google.com

# Port açık mı? (Telnet yerine nc kullanılır)
nc -zv 127.0.0.1 22
# Connection refused -> Port kapalı veya servis yok
# Succeeded -> Port açık
```

# SSHGuard

**SSHGuard**, C ile yazılmış, son derece hafif ve hızlı bir saldırı engelleme aracıdır. Fail2ban'den daha basittir çünkü karmaşık Regex kuralları yerine log formatlarını doğrudan anlar.

## Neden SSHGuard?

- **Performans:** Çok az RAM ve CPU kullanır (Gömülü sistemler için bile uygundur).
- **Basitlik:** Karmaşık "Jail" veya "Filter" ayarlarıyla uğraşmazsınız.
- **Odak:** Önceliği SSH güvenliğidir ama diğer bazı servisleri de (Exim, Dovecot vb.) destekler.

> [!NOTE]
> Eğer çok özelleştirilmiş kurallara (örn: Nginx'te belirli bir URL'ye erişeni banla) ihtiyacınız varsa **Fail2ban** veya **CrowdSec** kullanın. "Kur ve unut" (Set and forget) istiyorsanız SSHGuard iyidir.

## 1. Kurulum

```bash
sudo apt update
sudo apt install -y sshguard
```

## 2. Yapılandırma

SSHGuard varsayılan ayarlarıyla gayet iyi çalışır. Ayar dosyası `/etc/sshguard/sshguard.conf` konumundadır.

**Önemli Ayarlar:**

```bash
# /etc/sshguard/sshguard.conf

# Backend: Kuralları kimin uygulayacağı (nftables, iptables, ufw vb.)
# Ubuntu'da genelde otomatik algılanır ama manuel de verilebilir:
BACKEND="/usr/lib/x86_64-linux-gnu/ssh_guard/sshg-fw-ufw"

# Log Dosyaları: Hangi dosyalar izlenecek?
# (Boş bırakılırsa systemd journal'dan okur - Modern sistemlerde önerilen budur)
# FILES="/var/log/auth.log /var/log/syslog"

# Kaç saniye banlı kalsın? (Örn: 120 saniye)
THRESHOLD=30
BLOCK_TIME=120

# Beyaz Liste (Whitelist)
# Kendinizi banlamamak için IP'nizi ekleyin
WHITELIST_FILE="/etc/sshguard/whitelist"
```

### Whitelist Oluşturma

```bash
sudo nano /etc/sshguard/whitelist
```

İçine IP adresinizi veya subnetinizi yazın:

```text
127.0.0.0/8
192.168.1.0/24
203.0.113.15
```

## 3. Yönetim ve Kontrol

Servisi başlatın:

```bash
sudo systemctl enable --now sshguard
sudo systemctl restart sshguard
```

**Durum kontrolü:**

```bash
systemctl status sshguard
```

**Logları izleme:**

SSHGuard'ın ne yaptığını görmek için loglara bakabilirsiniz:

```bash
journalctl -u sshguard -f
```

Eğer bir saldırı engellenirse şuna benzer bir log düşer:

`Attack from "1.2.3.4" on service 100 with danger 10.`

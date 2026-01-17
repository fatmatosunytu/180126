# Server Bootstrap Script 🛡️

Bu script, **boş bir Ubuntu/Debian sunucuyu** (Fresh Install) tek komutla "Prod-Ready" hale getirir.

> **GÜNCELLEME (v2):** Timezone, Kernel Hardening, Docker Compose v2 ve detaylı loglama eklendi.

## Özellikler

- **Kullanıcı:** `deployer` kullanıcısı (Sudo yetkisiyle).
- **SSH:** Port 2222, Root Login Kapalı, Timeout ayarları.
- **Güvenlik:** UFW, Fail2Ban (SSH korumalı), Kernel Hardening.
- **Sistem:** Timezone (Europe/Istanbul), Swap, Auto-Upgrades.
- **Docker:** Docker Engine + Compose v2.

## Kullanım

Scripti sunucuda bir dosyaya yapıştırın ve çalıştırın.

```bash
nano setup.sh
# Kodu yapıştır
chmod +x setup.sh
./setup.sh
```

## Kaynak Kod

```bash
#!/bin/bash
set -euo pipefail

# --- CONFIG ---
NEW_USER="deployer"
SSH_PORT="2222"
SWAP_SIZE="2G"
TIMEZONE="Europe/Istanbul"
# --------------

LOG_FILE="/var/log/server-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Sunucu Kurulumu Baslatiliyor... $(date)"

# 1. Root Kontrolu
if [ "$EUID" -ne 0 ]; then
  echo "❌ Lutfen root olarak calistirin (sudo su)"
  exit 1
fi

# 2. Backup SSH Config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)

# 3. Update
echo "📦 Paketler guncelleniyor..."
apt update && apt upgrade -y
apt install -y ufw fail2ban curl git unattended-upgrades \
               htop vim tmux ncdu net-tools

# 4. Timezone
echo "🕐 Timezone ayarlanıyor: $TIMEZONE"
timedatectl set-timezone $TIMEZONE
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# 5. Create User
if id "$NEW_USER" &>/dev/null; then
    echo "⚠️ Kullanici $NEW_USER zaten var."
else
    echo "👤 Kullanici olusturuluyor: $NEW_USER"
    adduser --gecos "" --disabled-password $NEW_USER
    echo "$NEW_USER:$(openssl rand -base64 32)" | chpasswd
    usermod -aG sudo $NEW_USER

    mkdir -p /home/$NEW_USER/.ssh
    chmod 700 /home/$NEW_USER/.ssh
    touch /home/$NEW_USER/.ssh/authorized_keys
    chmod 600 /home/$NEW_USER/.ssh/authorized_keys

    if [ -f /root/.ssh/authorized_keys ]; then
        cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
        chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
    fi
fi

# 6. SSH Hardening
echo "🔒 SSH sertlestiriliyor (Port: $SSH_PORT)..."
cat > /etc/ssh/sshd_config.d/hardening.conf << EOF
Port $SSH_PORT
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers $NEW_USER
EOF

# SSH config test
if sshd -t; then
    systemctl restart sshd
else
    echo "❌ SSH Config HATALI! Restart edilmedi."
fi

# 7. Firewall (UFW)
echo "🧱 Firewall ayarlaniyor..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable

# 8. Fail2Ban
echo "👮 Fail2Ban ayarlaniyor..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl enable --now fail2ban
systemctl restart fail2ban

# 9. Docker Install
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker kuruluyor..."
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $NEW_USER

    # Docker Compose
    apt install -y docker-compose-plugin
else
    echo "✅ Docker zaten kurulu."
fi

# 10. Swap Setup
if [ $(swapon --show | wc -l) -eq 0 ]; then
    echo "💾 Swap ($SWAP_SIZE) olusturuluyor..."
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

    # Swappiness ayarla
    sysctl vm.swappiness=10
    echo "vm.swappiness=10" >> /etc/sysctl.conf
fi

# 11. Unattended Upgrades
echo "� Otomatik güncellemeler ayarlanıyor..."
cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# 12. Kernel Hardening (Basit)
cat >> /etc/sysctl.conf << EOF

# Security Hardening
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF
sysctl -p

echo ""
echo "════════════════════════════════════════════════════"
echo "✅ Kurulum Tamamlandi!"
echo "════════════════════════════════════════════════════"
echo ""
echo "📋 ÖZET:"
echo "   • Kullanıcı: $NEW_USER"
echo "   • SSH Port: $SSH_PORT"
echo "   • Firewall: Aktif (80, 443, $SSH_PORT)"
echo "   • Fail2Ban: Aktif"
echo "   • Docker: Kurulu"
echo ""
echo "⚠️  ÖNEMLİ ADIMLAR:"
echo "   1. MEVCUT TERMİNALİ KAPATMAYIN!"
echo "   2. Yeni terminal açın ve test edin:"
echo "      ssh -p $SSH_PORT $NEW_USER@<SERVER_IP>"
echo ""
echo "   3. Bağlantı başarılıysa sunucuyu reboot edin:"
echo "      sudo reboot"
echo ""
echo "📝 Log dosyası: $LOG_FILE"
echo "════════════════════════════════════════════════════"
```

# Server Bootstrap Script 🛡️

Bu script, **boş bir Ubuntu/Debian sunucuyu** (Fresh Install) tek komutla "Prod-Ready" hale getirir.

## Ne Yapar?

1.  Sistemi günceller (`apt update`).
2.  `deployer` kullanıcısı oluşturur ve `sudo` yetkisi verir.
3.  SSH ayarlarını sertleştirir (Root login kapatır, Port değiştirir).
4.  UFW güvenlik duvarını "Default Deny" modunda kurar.
5.  Fail2Ban kurar.
6.  Docker ve Docker Compose kurar.
7.  Swap alanı yoksa oluşturur.

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
# --------------

echo "🚀 Sunucu Kurulumu Baslatiliyor..."

# 1. Root Kontrolu
if [ "$EUID" -ne 0 ]; then
  echo "❌ Lutfen root olarak calistirin (sudo su)"
  exit 1
fi

# 2. Update
echo "📦 Paketler guncelleniyor..."
apt update && apt upgrade -y
apt install -y ufw fail2ban curl git unattended-upgrades

# 3. Create User
if id "$NEW_USER" &>/dev/null; then
    echo "⚠️ Kullanici $NEW_USER zaten var."
else
    echo "👤 Kullanici olusturuluyor: $NEW_USER"
    adduser --gecos "" $NEW_USER
    usermod -aG sudo $NEW_USER

    # SSH Key klasoru
    mkdir -p /home/$NEW_USER/.ssh
    chmod 700 /home/$NEW_USER/.ssh
    touch /home/$NEW_USER/.ssh/authorized_keys
    chmod 600 /home/$NEW_USER/.ssh/authorized_keys

    # Root'un keylerini kopyala (Opsiyonel - kurulumu yapan kisi girebilsin diye)
    if [ -f /root/.ssh/authorized_keys ]; then
        cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
        chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
    fi
fi

# 4. SSH Hardening
echo "🔒 SSH sertlestiriliyor (Port: $SSH_PORT)..."
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i "s/^#*Port.*/Port $SSH_PORT/" /etc/ssh/sshd_config

# 5. Firewall (UFW)
echo "🧱 Firewall ayarlaniyor..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# 6. Docker Install
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker kuruluyor..."
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $NEW_USER
else
    echo "✅ Docker zaten kurulu."
fi

# 7. Swap Setup
if [ $(swapon --show | wc -l) -eq 0 ]; then
    echo "💾 Swap ($SWAP_SIZE) olusturuluyor..."
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    echo "vm.swappiness=10" >> /etc/sysctl.conf
fi

# 8. Fail2Ban
echo "👮 Fail2Ban ayarlaniyor..."
systemctl enable --now fail2ban

echo "✅ Kurulum Tamamlandi!"
echo "⚠️  Lutfen sunucuyu yeniden baslatmadan once YENI terminalden baglanmayi deneyin!"
echo "👉 ssh -p $SSH_PORT $NEW_USER@<ip>"
```

# Security Audit Script 🕵️‍♂️

"Sunucum ne kadar güvenli?" sorusunun cevabını veren hızlı tarama scripti.

## Ne Kontrol Eder?

- Açık Portlar (Hangileri dinliyor?)
- UFW Durumu (Aktif mi?)
- SSH Root Login (Açık mı?)
- Docker Socket Durumu
- Disk Kullanımı

## Kullanım

Ara sıra manuel çalıştırın.

```bash
./audit.sh
```

## Kaynak Kod

```bash
#!/bin/bash

echo "🔍 SECURITY AUDIT STARTING..."
echo "=============================="

# 1. UFW Check
echo "[+] Checking UFW Status:"
ufw status | grep "Status" || echo "❌ UFW Not Found"

# 2. Listening Ports
echo -e "\n[+] Listening Ports (Public):"
# 0.0.0.0 veya [::] dinleyenleri bul
ss -tulpn | grep -E '0.0.0.0|\[::\]'

# 3. SSH Config Check
echo -e "\n[+] Checking SSH Config:"
grep "^PermitRootLogin" /etc/ssh/sshd_config || echo "⚠️ PermitRootLogin setting not found (Default might be YES)"
grep "^PasswordAuthentication" /etc/ssh/sshd_config || echo "⚠️ PasswordAuthentication setting not found"

# 4. Fail2Ban
echo -e "\n[+] Fail2Ban Status:"
systemctl is-active fail2ban >/dev/null && echo "✅ Active" || echo "❌ Inactive"

# 5. Docker Check
echo -e "\n[+] Docker Socket Rights:"
ls -l /var/run/docker.sock

echo -e "\n[+] Disk Usage:"
df -h /

echo "=============================="
echo "AUDIT COMPLETE"
```

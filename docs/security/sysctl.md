# Kernel Hardening (Sysctl)

Bu bölüm, Linux çekirdeğini (kernel) network saldırılarına (IP spoofing, redirect saldırıları) ve bellek taşmalarına karşı sıkılaştırmayı hedefler. "Level 2" hardening seviyesidir.

> [!WARNING]
> Bu ayarlar çekirdek seviyesindedir. Uygulamadan önce test ortamında denemeniz önerilir. Docker kullananlar `net.ipv4.conf.all.forwarding` ayarını KAPATMAMALIDIR.

## Uygulama

`/etc/sysctl.d/99-hardening.conf` adında yeni bir dosya oluşturun:

```bash
sudo tee /etc/sysctl.d/99-hardening.conf << 'EOF'
# ==============================================
# NETWORK SECURITY (Ağ Güvenliği)
# ==============================================

# ICMP Redirect Kabulu Kapat (Man-in-the-middle riskini azaltır)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# ICMP Redirect Gönderimi Kapat (Router değilseniz gerekmez)
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# IP Spoofing Koruması (Source Route kapalı)
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Yanlış Yönlendirilmiş Paketleri Logla (Martian Packets)
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# SYN Flood Koruması
net.ipv4.tcp_syncookies = 1

# ==============================================
# KERNEL SAFETY (Çekirdek Güvenliği)
# ==============================================

# Kernel erişimini kısıtla (dmesg sadece root görsün)
kernel.dmesg_restrict = 1

# Ptrace kısıtlaması (Bir sürecin diğerini debug etmesini zorlaştırır)
kernel.yama.ptrace_scope = 1

# SUID Core dump almayı kapat (Setuid programlar core dump basmasın)
fs.suid_dumpable = 0

# Kernel pointer adreslerini gizle
kernel.kptr_restrict = 2

# SysRq tuşunu kısıtla (Sadece shutdown/reboot için)
kernel.sysrq = 0
EOF
```

## Aktifleştirme

Ayarları hemen uygulamak için:

```bash
sudo sysctl --system
```

## Doğrulama

Ayarların yüklendiğini kontrol etmek için örnek bir sorgu yapın:

```bash
sysctl net.ipv4.conf.all.accept_redirects
# Çıktı: net.ipv4.conf.all.accept_redirects = 0
```

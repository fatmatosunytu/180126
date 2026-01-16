# Kernel Hardening (Sysctl)

Bu bölüm, Linux çekirdeğini (kernel) ağ saldırılarına ve yetki yükseltme (privilege escalation) girişimlerine karşı "çelik yelek" giydirmeyi hedefler.

> [!NOTE] > **Bu ayarlar ne işe yarar?**
> Varsayılan Linux ayarları "maksimum uyumluluk" içindir. Biz bunu "maksimum güvenlik" olarak değiştireceğiz.
> Örneğin: `ICMP Redirect` açık olursa, bir saldırgan trafiğinizi kendi üzerine çekebilir. Biz bunu kapatacağız.

## 1. Uygulama

`/etc/sysctl.d/99-hardening.conf` adında yeni bir dosya oluşturuyoruz. Bu yöntem (yeni dosya açmak) en temiz yöntemdir, istediğiniz an dosyayı silip eski haline dönebilirsiniz.

Aşağıdaki komutu kopyalayıp terminale yapıştırın:

```bash
sudo tee /etc/sysctl.d/99-hardening.conf << 'EOF'
# ==============================================
# NETWORK SAFETY (Ağ Güvenliği)
# ==============================================

# IP Spoofing Koruması
# Amaç: Saldırganın IP adresini taklit etmesini (spoof) engeller.
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# ICMP Redirect Kabulu Kapat
# Amaç: "Trafiği şuradan dolaştır" diyen sahte paketleri reddeder.
# (Man-in-the-Middle saldırılarını önler)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# ICMP Redirect Gönderimi Kapat
# Amaç: Biz bir Router değiliz, kimseye yol tarif etmemize gerek yok.
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# TCP SYN Flood Koruması
# Amaç: DoS saldırılarına karşı direnç sağlar (SYN Cookies).
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2

# Yanlış Yönlendirilmiş Paketleri Logla (Martian Packets)
# Amaç: Olmaması gereken bir yerden paket gelirse loglara yazar.
net.ipv4.conf.all.log_martians = 1

# ==============================================
# KERNEL SAFETY (Çekirdek Güvenliği)
# ==============================================

# Kernel Loglarını (dmesg) Gizle
# Amaç: Saldırgan kernel hafıza adreslerini görüp exploit yazamasın.
kernel.dmesg_restrict = 1

# Ptrace Kısıtlaması (Yama)
# Amaç: Bir sürecin (process) diğerini izlemesini/değiştirmesini engeller.
kernel.yama.ptrace_scope = 1

# SUID Core Dump Kapat
# Amaç: Yetkili bir program çökerse, hafızasını diske yazmasın (İçinde şifre olabilir).
fs.suid_dumpable = 0

# Kernel Pointer Adreslerini Gizle
# Amaç: Exploit geliştirmeyi çok daha zor hale getirir.
kernel.kptr_restrict = 2
EOF
```

## 2. Aktifleştirme

Ayarları sisteme yüklemek için:

```bash
sudo sysctl --system
```

## 3. Doğrulama

Ayarların gerçekten uygulandığını kontrol edelim. Örneğin `accept_redirects` değeri `0` olmalı:

```bash
sysctl net.ipv4.conf.all.accept_redirects
# Çıktı şu olmalı: net.ipv4.conf.all.accept_redirects = 0
```

## 4. Sorun Çıkarsa (Geri Alma)

Eğer bu ayarlar uygulamanızı bozarsa (örneğin Kubernetes veya özel network modülleri bazen IP Forwarding ister), dosyayı silip ayarları eski haline getirebilirsiniz.

```bash
# 1. Dosyayı sil
sudo rm /etc/sysctl.d/99-hardening.conf

# 2. Ayarları sıfırla (veya sunucuyu yeniden başlat)
sudo sysctl --system
```

# Fail2ban ile Aktif Korumas

Bu bölüm, sunucuyu kaba kuvvet (brute-force) saldırılarına karşı koruyan **Fail2ban** aracının kurulumunu ve "Production Ready" yapılandırmasını anlatır.

Özellikle Ubuntu 24.04 ve modern sistemlerde `jail.conf` dosyasını düzenlemek yerine `jail.d` altında override oluşturmak en temiz yöntemdir.

## 1. Kurulum ve Kontrol

Önce paketi kurun ve servisin durumuna bakın:

```bash
sudo apt update
sudo apt install -y fail2ban
sudo systemctl status fail2ban --no-pager
```

Eğer "active (running)" değilse servisi başlatın:

```bash
sudo systemctl enable --now fail2ban
```

## 2. SSH Koruması (Jail Oluşturma)

SSH servisi için özel bir yapılandırma dosyası oluşturacağız. Bu yöntem ana konfigürasyonu bozmadan güvenli değişiklik yapmamızı sağlar.

```bash
sudo nano /etc/fail2ban/jail.d/sshd.local
```

Dosyanın içine aşağıdaki ayarları yapıştırın. Port kısmının sizin kullandığınız portla (**2222**) aynı olduğundan emin olun.

```ini
[sshd]
enabled = true
backend = systemd
port = 2222        # DİKKAT: SSH Portunuz 2222 ise burası da 2222 olmalı!
maxretry = 5       # 5 Hatalı denemede yakala
findtime = 10m     # Bu 5 hatayı 10 dakika içinde yaparsa
bantime = 1h       # 1 Saat boyunca banla
```

## 3. Whitelist (Kendini Banlamamak)

Eğer sabit bir IP adresiniz varsa, kendinizi güvenli listeye ekleyebilirsiniz.

Aşadaki dosyayı düzenleyin (yoksa oluşur):

```bash
sudo nano /etc/fail2ban/jail.d/whitelist.local
```

En üste IP adresinizi ekleyin (birden fazla IP varsa boşlukla ayırın):

```ini
[DEFAULT]
ignoreip = 127.0.0.1/8 192.168.1.50/32
```

## 4. Aktifleştirme ve Kontrol

Ayarları geçerli kılmak için servisi yeniden başlatın:

```bash
# Konfigürasyonda hata var mı kontrol et
sudo fail2ban-client -t

# Servisi yeniden başlat
sudo systemctl restart fail2ban
```

### Durum Sorgulama

Korumaların çalıştığını doğrulamak için:

```bash
# Genel durum (Hangi hapishaneler aktif?)
sudo fail2ban-client status
# Çıktı: Jail list: sshd

# SSH Jail detayları (Kimler banlanmış?)
sudo fail2ban-client status sshd
```

## 5. Test Etme (Ban Testi)

Ayarlarınızın çalışıp çalışmadığını test etmek için en güvenli yöntem şudur:

1.  **Farklı Bir Bağlantı Bulun:** Şu an bağlı olduğunuz interneti **kullanmayın** (kendinizi banlarsanız sunucuyla bağınız kopar!). Telefonunuzun mobil internetini (Hotspot) kullanabilirsiniz.
2.  **Hatalı Giriş Yapın:** Mobil internet üzerinden terminal açın (Termius vb.) ve sunucunuza **yanlış şifre** ile bağlanmayı deneyin.
    ```bash
    ssh kullanıcı@sunucu-ip -p 2222
    ```
3.  **Tekrarlayın:** 5-6 kez hızlıca yanlış şifre girin.
4.  **Banlanma:** Bir süre sonra cevap gelmemeye başlayacak veya "Connection Refused" alacaksınız. Tebrikler, banlandınız!
5.  **Ban Kaldırma (Unban):**
    Şimdi çalışan (Wi-Fi) bağlantınızdan sunucuya dönün ve o banlanan (mobil) IP'yi affedin:

    ```bash
    # Önce IP'yi bulalım
    sudo fail2ban-client status sshd

    # Banı kaldıralım
    sudo fail2ban-client set sshd unbanip <MOBIL_IP_ADRESINIZ>
    ```

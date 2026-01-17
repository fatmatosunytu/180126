# SSH İçin 2FA (İki Aşamalı Doğrulama) 🔐

SSH anahtarınızı çaldırsanız bile, telefonunuzdaki kod olmadan kimsenin sunucuya girememesini sağlayın. Bu rehberde **Google Authenticator** kullanarak SSH güvenliğini en üst seviyeye çıkaracağız.

## 1. Kurulum

Gerekli PAM modülünü kuralım:

```bash
sudo apt update
sudo apt install libpam-google-authenticator -y
```

## 2. 2FA'yı Aktif Etme

Bu komutu **kendi kullanıcınızla** (root olmayan) çalıştırın:

```bash
google-authenticator
```

Size soracağı sorulara şu cevapları verin:

1.  **Do you want authentication tokens to be time-based?** -> `y` (Evet)
2.  **QR Kodu:** Ekranda kocaman bir QR kod çıkacak. Bunu telefonunuzdaki Google Authenticator veya Authy uygulamasına okutun.
3.  **Secret Key & Recovery Codes:** Bu kodları güvenli bir yere kaydedin! (Telefonunuz kaybolursa sunucuya girmek için lazım olur).
4.  **Update the .google_authenticator file?** -> `y` (Ayarları kaydet)
5.  **Disallow multiple uses of the same authentication token?** -> `y` (Aynı kodu iki kere kullanamasınlar - Replay Attack koruması)
6.  **Increase the time-skew window?** -> `n` (Hayır, saatimiz senkronize kalsın)
7.  **Enable rate-limiting?** -> `y` (Evet, brute-force koruması)

## 3. SSHD ve PAM Yapılandırması

Şimdi SSH servisine "Girişte bu modülü kullan" diyeceğiz.

### A) PAM Ayarı

Dosyayı açın:

```bash
sudo nano /etc/pam.d/sshd
```

En alta şu satırı ekleyin (veya `@include common-auth` satırını bulup onun **altına** ekleyin):

```nginx
# Google Authenticator 2FA
auth required pam_google_authenticator.so
```

### B) SSHD Ayarı

SSH Config dosyasını açın:

```bash
sudo nano /etc/ssh/sshd_config
```

Şu ayarı bulun ve `yes` yapın (Yoksa ekleyin):

```nginx
KbdInteractiveAuthentication yes
# Not: Bazı eski sürümlerde "ChallengeResponseAuthentication yes" olabilir.
```

Eğer **SSH Anahtarı** kullanıyorsanız, hem anahtar hem de şifre istemesi için şunu ekleyin (Dosyanın en altına):

```nginx
# Hem SSH Key hem de 2FA Kodu ZORUNLU olsun:
AuthenticationMethods publickey,keyboard-interactive
```

## 4. Servisi Yeniden Başlatma

Ayarları uygulayalım:

```bash
sudo systemctl restart ssh
```

> ⚠️ **ÇOK ÖNEMLİ UYARI:** Şu anki terminal penceresini **SAKIN KAPATMAYIN!**
> Yeni bir terminal açıp bağlanmayı deneyin. Eğer hata yapıldıysa mevcut pencereden düzeltebilirsiniz. Kapatırsanız sunucu dışarıda kalırsınız!

## 5. Bağlantı Testi

Yeni bir terminal açın ve bağlanmayı deneyin:

```bash
ssh kullanici@sunucu-ip
```

Süreç şöyle işlemeli:

1.  Önce SSH anahtarınızı doğrular (şifre sormaz).
2.  Ardından `Verification code:` diye sorar.
3.  Telefondaki 6 haneli kodu girersiniz.
4.  Giriş Başarılı! 🎉

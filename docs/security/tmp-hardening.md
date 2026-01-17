# /tmp Klasörü Güvenliği (Noexec) 🛡️

Linux sunucularda `/tmp` klasörü, geçici dosyalar için kullanılır ve dünyadaki **her kullanıcı** buraya yazabilir (`rwxrwxrwt`).
Bu özellik, saldırganların zararlı scriptlerini (exploit, shell script, virüs) buraya indirip çalıştırması için mükemmel bir yuvadır.

Bu açığı kapatmak için `/tmp` klasörünü **noexec** (içinde hiçbir şey çalıştırılamaz) moduyla bağlayacağız.

> **Amaç:** Saldırgan `/tmp` içine virüs indirse bile `./virus` diyerek çalıştıramasın.

## 1. Hazırlık ve Yedek

`fstab` dosyası sunucunun açılışında diskleri bağlar. Yanlış bir harf, sunucunun açılmamasına neden olabilir. Önce yedek alalım!

```bash
sudo cp /etc/fstab /etc/fstab.bak
```

## 2. /tmp'yi Güvenli Bağlama (Tmpfs)

Bu işlem `/tmp` klasörünü RAM üzerinde (tmpfs) tutar ve çalıştırılabilir dosyaları engeller.

Dosyayı açın:

```bash
sudo nano /etc/fstab
```

En alt satıra şunu ekleyin:

```nginx
# Secure /tmp (noexec prevents running scripts)
tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0
```

- **noexec:** Script/program çalıştırılamaz.
- **nosuid:** Root yetkisi alan dosya barınamaz.
- **nodev:** Aygıt dosyası (device file) oluşturulamaz.

## 3. Ayarları Uygulama

Kaydettikten sonra (Ctrl+O, Enter, Ctrl+X), ayarları aktif etmek için:

```bash
# Değişiklikleri uygula
sudo mount -o remount /tmp || sudo mount -a
```

> **Not:** Eğer hata alırsanız veya "busy" derse sunucuyu yeniden başlatmanız gerekebilir (`reboot`).

## 4. Doğrulama (Hacker Testi) 🧪

Gerçekten çalışıp çalışmadığını test edelim. `/tmp` içine basit bir script yazıp çalıştırmayı deneyelim.

```bash
# 1. /tmp'ye git
cd /tmp

# 2. Masum bir script oluştur
echo 'echo "Eğer bunu görüyorsan GÜVENLİK YOK!"' > test_hack.sh

# 3. Çalıştırma izni ver
chmod +x test_hack.sh

# 4. Çalıştırmayı dene
./test_hack.sh
```

**Beklenen Sonuç:**

```bash
-bash: ./test_hack.sh: Permission denied
# Veya
Erişim engellendi
```

Eğer **"Permission denied"** hatası alıyorsanız tebrikler! 🎉
Saldırganlar artık `/tmp` üzerinden script çalıştıramaz.

## ⚠️ Önemli Uyarı: Apt ve Scriptler

Bazı kötü yazılmış scriptler veya güncellemeler `/tmp` içinde çalışmak isteyebilir (Nadir).
Eğer bir güncelleme sırasında sorun yaşarsanız geçici olarak korumayı kaldırabilirsiniz:

```bash
# Korumayı kaldır (exec izni ver)
sudo mount -o remount,exec /tmp

# İşini hallet, güncellemeyi yap...

# Korumayı geri aç
sudo mount -o remount,noexec /tmp
```

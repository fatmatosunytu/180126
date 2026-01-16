# Dosya ve Dizin Komutları

Sunucu yönetiminde en çok kullanılan dosya arama, içerik okuma ve yetkilendirme komutları.

## 1. Arama (Find & Grep)

Aradığınız dosyayı veya metni bulamıyorsanız:

```bash
# İsme göre dosya bul (Örn: .log ile bitenler)
find . -name "*.log"

# Büyük dosyaları bul (100MB'dan büyük)
find /var -size +100M

# Son 24 saatte değiştirilen dosyalar
find . -mtime -1

# İçerikte metin ara (Recursive)
grep -r "error" /var/log/

# Sadece dosya ismini göster, içeriği gösterme
grep -rl "sunucu hatasi" .
```

## 2. İçerik Görüntüleme

```bash
# Dosyayı canlı izle (Loglar için birebir)
tail -f access.log

# Son 50 satırı göster ve izle
tail -n 50 -f access.log

# Dosyayı sayfa sayfa oku (Boşluk ile ilerle, q ile çık)
less buyuk_dosya.txt

# Dosyanın başını gör (İlk 10 satır)
head config.yaml
```

## 3. İzinler ve Sahiplik (Chmod & Chown)

```bash
# Dosyayı çalıştırılabilir yap
chmod +x script.sh

# Sadece sahibine tam yetki ver (En güvenli)
chmod 600 id_rsa

# Klasör ve içindekilerin sahipliğini değiştir
chown -R www-data:www-data /var/www/html
```

## 4. Arşivleme (Tar & Zip)

```bash
# Klasörü sıkıştır (tar.gz)
tar -czvf yedek.tar.gz /var/www

# Arşivi aç
tar -xzvf yedek.tar.gz

# Zip açma
unzip dosya.zip
```

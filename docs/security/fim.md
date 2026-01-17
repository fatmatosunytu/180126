# Dosya Bütünlük Takibi (AIDE) 🕵️‍♂️

Bir saldırgan sunucuya sızdığında genellikle `sshd_config`, `passwd` veya `crontab` gibi kritik dosyaları değiştirir. **AIDE (Advanced Intrusion Detection Environment)**, sistemdeki dosyaların "parmak izini" (Hash) alır ve herhangi bir değişiklik olduğunda sizi uyarır.

> **Mantık:** İlk gün bir "Fotoğraf" (Snapshot) çekersiniz. Her gece yeni fotoğrafla eskisini karşılaştırırsınız. Fark varsa, biri dosyayı değiştirmiş demektir.

## 1. Kurulum

```bash
sudo apt update
sudo apt install aide -y
```

## 2. İlk Veritabanını Oluşturma

Kurulumdan sonra AIDE'nin sistemin "temiz" halini öğrenmesi gerekir. Bu işlem sistemdeki dosya sayısına göre 1-2 dakika sürebilir.

```bash
# Veritabanını oluştur (Bu işlem biraz sürer)
sudo aideinit

# Oluşan veritabanını aktif hale getir
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

## 3. Yapılandırma (Gürültüyü Azaltma)

AIDE varsayılan olarak **çok hassastır**. Log dosyaları geliştikçe "Dosya değişti!" diye uyarı verir. Bunu engellemek için ayarları düzenleyelim.

Dosya: `/etc/aide/aide.conf`

```bash
sudo nano /etc/aide/aide.conf
```

Aşağıdaki gibi bir filtreleme mantığı kullanabilirsiniz (Dosyanın sonuna ekleyin veya mevcut kuralları düzenleyin):

```nginx
# Log dosyalarının sadece "büyümesini" göz ardı et (İçerik değişebilir ama silinemez)
/var/log/   FreqRot
/var/mail/  FreqRot

# Geçici dizinleri yoksay
!/tmp/
!/var/run/
!/var/tmp/
```

> **Not:** `FreqRot` (Frequent Rotation), log dosyaları için özel bir moddur. Dosyanın değişmesini normal karşılar.

## 4. Manuel Kontrol

İstediğiniz zaman sistemde değişiklik var mı diye kontrol etmek için:

```bash
sudo aide --check
```

- **Çıktı Boşsa:** Değişiklik yok (Temiz).
- **Çıktı Varsa:** Değişen dosyaların listesini verir.

## 5. Değişiklikleri Onaylama (Update)

Sistemi güncellediniz (`apt upgrade`) veya konfigürasyon değiştirdiniz. AIDE "Dosyalar değişti!" diye bağıracaktır. Bunların "yetkili değişiklik" olduğunu söylemek için veritabanını güncellemelisiniz:

```bash
# Yeni durumu 'Normal' kabul et
sudo aide --update

# Yeni veritabanını aktif et
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

## 6. Otomasyon (Cron)

AIDE zaten `/etc/cron.daily/aide` altına kendi scriptini koyar ve her sabah mail atar. Ancak mail sunucunuz yoksa log dosyasına yazmasını sağlayabilirsiniz.

Eğer otomatik çalışmıyorsa basit bir cron ekleyelim:

```bash
# Her gece 04:00'te kontrol et ve loga yaz
0 4 * * * /usr/bin/aide --check > /var/log/aide-check.log 2>&1
```

## ⚠️ Önemli Uyarı

AIDE, **canlı saldırıyı engellemez**. Sadece saldırı **olduktan sonra** neyin değiştiğini size söyler.
Bu yüzden AIDE veritabanını (`/var/lib/aide/aide.db`) güvenli bir yere (örn: mail adresinize veya başka sunucuya) yedeklemeniz önerilir. Yoksa saldırgan veritabanını da değiştirip kendini gizleyebilir!

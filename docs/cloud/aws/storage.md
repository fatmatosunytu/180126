# AWS EBS: Esnek Blok Depolama

AWS'de ek disk ihtiyacınızı karşılayan servise **EBS (Elastic Block Store)** denir. Oracle'daki **Block Volume** ile mantık olarak tamamen aynıdır.

## 1. EBS vs. Oracle Block Volume

| Özellik            | AWS EBS                   | Oracle Block Volume           |
| :----------------- | :------------------------ | :---------------------------- |
| **Bağlantı Tipi**  | Native (EBS bus)          | iSCSI / Paravirtualized       |
| **Performans**     | IOPS bazlı (gp3 önerilir) | VPU (Performance Units) bazlı |
| **Sunucuya Takma** | Console'dan "Attach"      | iSCSI komutları + Console     |

> [!TIP] > **AWS gp3 Avantajı:** gp3 disk tipi, gp2'ye göre daha ucuzdur ve performansını disk boyutundan bağımsız olarak ayarlamanıza izin verir. Yeni disk açarken **gp3** seçtiğinizden emin olun.

## 2. Disk Oluşturma ve Takma

1. AWS Console > **EC2 > Elastic Block Store > Volumes** sayfasına gidin.
2. **Create Volume** butonuna basın.
3. **Availability Zone:** Sunucunuzla (EC2) **AYNI** bölgeyi seçin (Örn: `us-east-1a`).
4. Oluşturulan diske sağ tıklayıp **Attach Volume** deyin ve sunucunuzu seçin.

## 3. Sunucu İçinde Diski Tanıtma

AWS'de diskler genellikle `/dev/xvdf` veya modern (Nitro) sistemlerde `/dev/nvme1n1` olarak görünür.

### Adım 1: Diski Bulun

```bash
lsblk
```

_(Örn: 50GB'lık yeni diskiniz nvme1n1 olarak görünüyorsa devam edin)._

### Adım 2: Formatlama (Sadece İlk Kez)

```bash
# SADECE BOŞ DİSK İÇİN!
sudo mkfs.ext4 /dev/nvme1n1
```

### Adım 3: Kalıcı Bağlantı (fstab)

Oracle rehberinde yaptığımız gibi `UUID` kullanarak bağlamak en güvenli yoldur:

1. **UUID Öğren:** `sudo blkid /dev/nvme1n1`
2. **Klasör Aç:** `sudo mkdir -p /data`
3. **fstab'a Ekle:** `sudo nano /etc/fstab`

   ```ini
   UUID=SİZİN-UUID-BURAYA  /data  ext4  defaults,nofail  0  2
   ```

   _(AWS'de `nofail` eklemek önemlidir; disk bir sebeple takılmazsa sunucunun açılmasını engellemez)._

4. **Bağla:** `sudo mount -a`

## 4. Root Volume Genişletme (Pratik)

Eğer sunucuyu açarken diski küçük tuttuysanız ve sonradan AWS Console'dan boyutu artırdıysanız, sunucu içinde şu iki komutla kapasiteyi güncelleyebilirsiniz:

```bash
# Partisyonu genişlet
sudo growpart /dev/nvme0n1 1

# Dosya sistemini genişlet (ext4 için)
sudo resize2fs /dev/nvme0n1p1
```

_(Not: Cihaz isimleri nvme0n1p1 gibi sisteminize göre değişebilir, `lsblk` ile kontrol edin)._

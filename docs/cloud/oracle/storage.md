# Oracle Block Volume: Ekstra Depolama

Oracle Cloud'un ücretsiz sunduğu 200GB disk alanını verimli kullanmak için **Block Volume** kullanmalısınız. İşletim sistemi çökerse bile Block Volume'deki verileriniz (Docker volume'leri, veritabanları) güvende kalır.

> [!TIP] > **Neden Boot Volume Değil?**
> Boot volume (işletim sisteminin kurulu olduğu disk) çökerse veya silinirse içindeki veriler gider. Verilerinizi her zaman harici bir Block Volume'de tutmak "Best Practice"tir.

## 1. Volume Oluşturma (Panel)

1.  Oracle Cloud panelinde **Storage > Block Volumes** menüsüne gidin.
2.  **Create Block Volume** butonuna tıklayın.
3.  **Name:** `data-volume` (veya istediğiniz bir isim).
4.  **Size:** İhtiyacınız kadar (Örn: 50GB veya 100GB).
5.  **Availability Domain:** Sunucunuzla (Compute Instance) **AYNI** domain'i seçtiğinizden emin olun (Örn: `Frankfurt-1 AD-3`). Farklı yerlerdeki diskleri sunucuya takamazsınız.

## 2. Volume'ü Sunucuya Takma (Attach)

1.  Oluşturduğunuz Volume'ün içine girin.
2.  Soldan **Attached Instances** sekmesine tıklayın.
3.  **Attach to Instance** butonuna basın.
    - **Instance:** Sunucunuzu seçin.
    - **Attachment Type:** `iSCSI` (Paravirtualized daha yavaştır, iSCSI önerilir).
    - **Device Path:** Entegre yol yerine basitçe `/dev/oracleoci/oraclevdb` gibi bir yol seçimi sunmaz, bunu sunucu içinde göreceğiz.
4.  **Attach** diyerek işlemi başlatın.

### iSCSI Bağlantı Komutları

Attach işlemi bitince (State: Attached), sağdaki "üç nokta" menüsünden **iSCSI Commands & Information** seçeneğine tıklayın. Size 3-4 satırlık uzun komutlar verecek.

Bu komutları kopyalayın ve sunucunuzda (SSH ile) çalıştırın.

```bash
# Örnek (Sizin komutlarınız farklı olacak!):
sudo iscsiadm -m node -o new -T iqn.2015-12.com.oracleiaas:volume... -p 169.254.2.2:3260
sudo iscsiadm -m node -o update -T iqn.2015-12.com.oracleiaas:volume... -n node.startup -v automatic
sudo iscsiadm -m node -T iqn.2015-12.com.oracleiaas:volume... -p 169.254.2.2:3260 -l
```

Başarılı olup olmadığını kontrol edin:

```bash
lsblk
# Çıktıda 'sdb' (veya sdc) adında yeni bir disk görmelisiniz.
```

## 3. Formatlama ve Mount Etme

Disk ham (raw) haldedir. Dosya sistemi oluşturmalıyız.

> [!WARNING]
> Bu işlem diskin içindeki **HER ŞEYİ SİLER**. Diski ilk kez kullanıyorsanız yapın. Dolu bir diski taktıysanız bu adımı atlayın!

### a. Dosya Sistemi Oluştur (Format)

```bash
# Diskin sdb olduğunu varsayıyoruz (lsblk ile kontrol edin!)
sudo mkfs.ext4 -F /dev/sdb
```

### b. Kalıcı Mount (fstab)

Sunucu kapandığında bağlantının kopmaması için `/etc/fstab` dosyasına eklemeliyiz.

1.  **Mount Klasörü Oluştur:**

    ```bash
    sudo mkdir -p /mnt/blockvolume
    ```

2.  **UUID Öğren:**
    `/dev/sdb` ismine güvenmeyin, her rebootta değişebilir. UUID sabittir.

    ```bash
    sudo blkid -o value -s UUID /dev/sdb
    # Çıktı: a1b2c3d4-e5f6-.... (Bunu kopyalayın)
    ```

3.  **fstab Düzenle:**

    ```bash
    sudo nano /etc/fstab
    ```

    Dosyanın en altına şu satırı ekleyin (UUID kısmını kendi kodunuzla değiştirin):

    ```ini
    UUID=SİZİN-KOPYALADIĞINIZ-UUID  /mnt/blockvolume  ext4  defaults,noatime,_netdev  0  2
    ```

    - `_netdev`: Bu bir ağ diskidir, ağ gelmeden mount etmeye çalışma (Boot'un takılmasını önler).

4.  **Test Et ve Bağla:**

    ```bash
    sudo mount -a

    # Hata vermediyse kontrol et:
    df -h | grep blockvolume
    ```

## 4. Kullanım İpuçları

### Yetkiler

Diski `root` mount ettiği için normal kullanıcı yazamaz. Sahipliği değiştirin:

```bash
sudo chown -R $USER:$USER /mnt/blockvolume
```

### Docker Verisini Buraya Taşımak

Docker'ın tüm imajlarını ve volume'lerini bu güvenli diske taşımak için [Docker Kurulumu](../../how-to/docker.md) rehberindeki "Data Root" bölümünü okuyun.

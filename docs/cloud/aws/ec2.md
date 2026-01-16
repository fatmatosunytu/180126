# AWS EC2: Detaylı Sunucu Kurulum Rehberi

AWS'de sunucu (EC2) açmak, yüzlerce seçenek yüzünden karmaşık görünebilir. Bu rehber, **sadece ihtiyacınız olan** ayarlara odaklanarak güvenli ve ücretsiz/ucuz bir başlangıç yapmanızı sağlar.

## 0. Maliyet ve Free Tier Mantığı (Sürpriz Fatura Yeme!)

Makineyi açmadan önce cüzdanımızı koruyalım:

1.  **750 Saat Kuralı:** Yeni hesaplar için ilk 12 ay, aylık 750 saat `t2.micro` veya `t3.micro` ücretsizdir.
    - 1 Sunucu = 24 saat x 31 gün = 744 saat (Tamamen ücretsiz).
    - 2 Sunucu = Ayın yarısında ücretsiz kotanız dolar, sonraki günler ücret yazar.
2.  **Bölge (Region) Önemlidir:** Her zaman `us-east-1` (N. Virginia), `us-east-2` (Ohio), `eu-central-1` (Frankfurt) gibi ucuz ve popüler bölgeleri seçin. Bazı bölgelerde (örn: Sao Paulo) fiyatlar daha yüksektir.

## 1. Launch Instance (Adım Adım)

**EC2 Dashboard > Launch Instances** butonuna basın. Karşınıza uzun bir form gelecek. İşte bölüm bölüm yapmanız gerekenler:

### A. Name and Tags (İsim)

- **Name:** Sunucuyu tanımanız için bir isim verin. (Örn: `Project-Main-Server`)

### B. Application and OS Images (İşletim Sistemi)

- **Seçim:** **Ubuntu** kutusuna tıklayın.
- **AMI:** `Ubuntu Server 24.04 LTS (HVM), SSD Volume Type` seçili olduğundan emin olun.
- **Architecture:** `64-bit (x86)` seçin. (ARM seçmeyin, birçok paket uyumsuzluk çıkarabilir).

### C. Instance Type (Güç)

- **Seçim:** `t2.micro` veya `t3.micro`.
- **Kontrol:** Yanında yeşil renkte **Free tier eligible** yazısını mutlaka görün.

### D. Key Pair (Login Anahtarı)

Burası sunucunun kapı anahtarıdır. Şifre yerine dosya kullanırız.

- **Create new key pair** linkine tıklayın.
- **Name:** `aws-2026-key` (İsim verin).
- **Key pair type:** `ED25519` (Daha modern ve kısa) veya `RSA` (Eski ama her yerde çalışır).
- **Format:** `.pem` (Mac/Linux için) veya `.ppk` (Windows PuTTY için).
- **Create key pair** butonuna basın ve inen dosyayı **ASLA SİLMEYİN.**

### E. Network Settings (Ağ Ayarları)

- **VPC / Subnet:** Varsayılan (Default) ayarlarda bırakın. AWS sizin için ayarlamıştır.
- **Auto-assign Public IP:** **Enable** olduğundan emin olun. Yoksa sunucuya internetten erişemezsiniz.
- **Firewall (Security Groups):**
  - `Create security group` seçin.
  - **SSH (22):** Source kısmını `Anywhere` yerine **`My IP`** yapın. (Sadece sizin evinizden erişilsin).
  - **HTTP (80) / HTTPS (443):** "Allow HTTP traffic from the internet" kutucuklarını işaretleyin.

### F. Configure Storage (Disk)

AWS Free Tier, 30GB'a kadar EBS depolama verir. Varsayılan genelde 8GB gelir.

- **Boyut:** `8` yerine `30` Gb yapabilirsiniz (Tek sunucu olacaksa).
- **Volume Type:** `gp3` seçin. (Daha ucuz ve performanslıdır).
- **Delete on termination:** `Yes` (Varsayılan). Sunucuyu silerseniz diski de siler, çöp bırakmaz.

## 2. Advanced Details (İleri Düzey Ayarlar)

Çoğu kullanıcı burayı kafası karışıp kapatır, ama önemli iki ayar vardır:

### A. IAM Instance Profile (Kimlik Rolü)

**Soru:** _Bunu seçmek zorunda mıyım?_
**Cevap:** %90 Hayır. Basit bir web sunucusu için (Nginx, Docker vb.) gerekmez.

**Ne zaman gerekir?**
Eğer sunucunuzun içinden `aws s3 cp yedek.zip s3://bucketim` gibi komutlarla AWS servislerini kullanacaksanız gerekir.

- Eğer yoksa boş bırakın. Sonradan da eklenebilir.

### B. User Data (Otomatik Kurulum scripti)

Sunucu ilk açıldığı an (daha siz bağlanmadan) çalışacak komutlardır. Buraya update komutlarını yazmak zaman kazandırır:

```bash
#!/bin/bash
apt update && apt upgrade -y
apt install -y docker.io docker-compose
usermod -aG docker ubuntu
```

## 3. Bağlantı ve Son Kontroller

**Launch Instance** butonuna bastıktan 1-2 dakika sonra sunucu `Running` durumuna geçer.

Bağlanmak için (Terminal):

```bash
# Anahtara izin ver (Sadece ilk sefer)
chmod 400 aws-2026-key.pem

# Bağlan
ssh -i "aws-2026-key.pem" ubuntu@SUNUCU-PUBLIC-IP
```

> [!TIP] > **Sabit IP (Elastic IP):** Sunucuyu kapatıp açarsanız IP değişir. Üretim ortamı (Production) için mutlaka **Elastic IP** alıp sunucuya bağlayın. (Sunucu açıkken Elastic IP ücretsizdir).

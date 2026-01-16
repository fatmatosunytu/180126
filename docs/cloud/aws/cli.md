# AWS CLI (Command Line Interface)

AWS'yi web arayüzünden yönetmek (Console) yavaş kalabilir. **AWS CLI**, sunucularınızı (EC2), depolama alanlarınızı (S3) ve ağ ayarlarınızı terminalden hızlıca yönetmenizi sağlar.

## 1. Kurulum (Linux/Ubuntu)

Resmi AWS CLI v2 kurulumu için aşağıdaki adımları takip edin:

```bash
# Gerekli araçları kurun (unzip)
sudo apt update && sudo apt install -y unzip curl

# Kurulum paketini indirin
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Paketi açın ve kurun
unzip awscliv2.zip
sudo ./aws/install
```

Kurulumun başarılı olduğunu doğrulayın:

```bash
aws --version
# aws-cli/2.x.x ... çıktısını görmelisiniz.
```

## 2. Kimlik Ayarları (Configuration)

AWS CLI'ın hesabınıza erişebilmesi için önce IAM (Identity and Access Management) üzerinden bir "Access Key" oluşturmalısınız.

### A. AWS Console Üzerinden Key Alma

1. **IAM > Users** menüsüne gidin.
2. Bir kullanıcı oluşturun (örn: `developer`).
3. Kullanıcı detaylarında **Security credentials** sekmesine gelin.
4. **Access keys** bölümünden "Create access key" deyin.
5. "Command Line Interface (CLI)" seçeneğini seçin.
6. Size verilen **Access Key ID** ve **Secret Access Key**'i güvenli bir yere kaydedin.

### B. CLI Yapılandırması

Terminalinize dönün ve şu komutu çalıştırın:

```bash
aws configure
```

Sırasıyla şunları girin:

- **AWS Access Key ID:** (Panelden aldığınız)
- **AWS Secret Access Key:** (Panelden aldığınız)
- **Default region name:** (Örn: `eu-central-1`)
- **Default output format:** `json` (veya tablo isterseniz `table`)

## 3. Pratik Komutlar

### Sunucuları Listeleme (EC2)

Tüm çalışan sunucularınızın isimlerini ve IP'lerini tablo şeklinde görün:

```bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`].Value | [0], State:State.Name, PublicIP:PublicIpAddress}' --output table
```

### S3 Dosya Yönetimi

Bir dosyayı buluta yüklemek veya indirmek için:

```bash
# Bucket oluşturma
aws s3 mb s3://benim-ozel-yedek-klasorum

# Dosya yükleme
aws s3 cp yedek.tar.gz s3://benim-ozel-yedek-klasorum/
```

### Sunucu Durdurma/Başlatma

```bash
# Instance ID'sini kullanarak
aws ec2 stop-instances --instance-ids i-0123456789abcdef0
```

## 4. OCI CLI vs AWS CLI Karşılaştırması

| Özellik              | AWS CLI                           | OCI CLI                        |
| :------------------- | :-------------------------------- | :----------------------------- |
| **Kimlik Doğrulama** | Access Key / Secret Key           | API RSA Keypair (Config setup) |
| **Sözdizimi**        | `aws <servis> <aksiyon>`          | `oci <servis> <aksiyon>`       |
| **Popülerlik**       | Çok yüksek, topluluk desteği bol. | Kurumsal, spesifik kullanım.   |

> [!TIP] > **Profil Yönetimi:** Eğer birden fazla AWS hesabınız varsa `aws configure --profile is-hesabi` diyerek farklı profiller oluşturabilir ve komutların sonuna `--profile is-hesabi` ekleyerek kullanabilirsiniz.

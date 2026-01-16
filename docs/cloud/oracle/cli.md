# OCI CLI (Command Line Interface)

Oracle Cloud paneli bazen yavaş veya karmaşık olabilir. **OCI CLI**, terminalden sunucularınızı yönetmenizi, port açmanızı veya restart atmanızı sağlar. En önemlisi, "Infrastructure as Code" mantığına ilk adımdır.

## Kurulum

OCI CLI, Python tabanlıdır. En kolay kurulum yöntemi:

```bash
# Otomatik kurulum scripti (Linux/Mac)
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
```

Kurulum bittikten sonra versiyonu kontrol edin:

```bash
oci --version
```

## Konfigürasyon (Auth)

CLI'ın hesabınıza erişmesi için API Key oluşturmanız gerekir.

1.  **Config Başlat:**

    ```bash
    oci setup config
    ```

    Bu komut size şunları soracak:

    - User OCID (Oracle panelinde User Settings altında)
    - Tenancy OCID (Oracle panelinde Tenancy Details altında)
    - Region (örn: `eu-frankfurt-1`)
    - Yeni RSA Keypair oluşturulsun mu? (**Y** deyin)

2.  **API Key'i Yükle:**
    Komutun sonunda size bir `Public Key` içeriği verecek (veya dosya yolunu söyleyecek).

    - Oracle Panel -> User Settings -> **API Keys** -> "Add API Key" -> "Paste Public Key" diyerek bu anahtarı yapıştırın.

3.  **Test:**
    ```bash
    oci iam availability-domain list
    ```
    Hata vermeden JSON çıktısı veriyorsa bağlantı tamamdır.

## Pratik Komutlar

### 1. Sunucu Listeleme (Instance List)

```bash
# Compartment OCID'nizi bir değişkene atayın (kolaylık olsun)
export C=ocid1.compartment.oc1..aaaaaaa...

oci compute instance list --compartment-id $C --output table --query "data[*].{Name:\"display-name\", State:\"lifecycle-state\", IP:\"public-ip\"}"
```

### 2. Sunucuyu Yeniden Başlatma (Reboot)

Panel çalışmıyorsa hayat kurtarır.

```bash
# İlk komuttan Instance OCID'sini alın
oci compute instance action --action RESET --instance-id ocid1.instance.oc1...
```

### 3. Security List'e Port Ekleme (Hızlı Firewall)

Web panelde tıklayarak port açmak yerine:

```bash
# Security List ID'sini bulmanız gerekir
oci network security-list list --compartment-id $C

# 8080 Portunu Aç (Ingress Rule)
oci network security-list update --security-list-id ocid1.securitylist... --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "6", "tcp-options": {"destination-port-range": {"min": 8080, "max": 8080}}}]'
```

> [!WARNING] > `update` komutu mevcut kuralları **EZEBİLİR**. Port eklerken `create` değil `update` içinde liste vermek gerektiği için, production ortamında JSON dosyası ile çalışmak daha güvenlidir.

## JSON ile Yönetim (Önerilen)

Komut satırında uzun JSON yazmak yerine dosyadan okutun:

`rules.json`:

```json
[
  {
    "source": "0.0.0.0/0",
    "protocol": "6",
    "tcpOptions": {
      "destinationPortRange": {
        "max": 443,
        "min": 443
      }
    }
  }
]
```

Komut:

```bash
oci network security-list update ... --ingress-security-rules file://rules.json
```

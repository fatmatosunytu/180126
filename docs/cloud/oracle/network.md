# Oracle Cloud Network (VCN)

Oracle Cloud'da bir "Compute Instance" (Sunucu) açtığınızda, Linux işletim sisteminden bağımsız olarak çalışan bir **Dış Ağ Katmanı** vardır. Bu katmanı doğru yapılandırmazsanız, sunucudaki firewall'u komple kapatsanız bile erişim sağlayamazsınız.

## 1. VCN (Virtual Cloud Network)

VCN, sunucularınızın içinde yaşadığı sanal veri merkezidir.

### Hızlı Kurulum (VCN Wizard)

Oracle panelinde "Networking -> Virtual Cloud Networks" menüsüne gidin.
**"Start VCN Wizard"** butonunu kullanın ve **"Create VCN with Internet Connectivity"** seçeneğini seçin.
Bu sihirbaz sizin için şunları otomatik kurar:

- **VCN:** Ana ağ bloğu (örn: 10.0.0.0/16)
- **Public Subnet:** İnternete açık sunucular için.
- **Private Subnet:** Dışarıya kapalı (veritabanı vb.) sunucular için.
- **Internet Gateway:** İnternete çıkış kapısı.
- **Route Table:** Trafik yönlendirme kuralları.

> [!TIP]
> Yeni başlıyorsanız mutlaka **Wizard** kullanın. Manuel kurulumda Route Table veya Gateway unutulursa sunucu internete çıkamaz.

## 2. Security Lists (Oracle'ın Firewall'u)

En çok karıştırılan nokta burasıdır: **Linux içindeki UFW ile Oracle'ın Security List'i farklıdır!**
Bir paketin sunucunuza ulaşması için **İKİ** duvardan da geçmesi gerekir:

1.  **OCI Security List** (Bulut Duvarı)
2.  **Ubuntu UFW** (İşletim Sistemi Duvarı)

### Port Açma (Ingress Rules) - Adım Adım

Açık portları görmek ve yönetmek için **Security List**'e gitmeniz gerekir. En kolay yol şudur:

1.  **Instance (Sunucu)** sayfasındasınız (Attığınız ekran).
2.  Sayfada **"Primary VNIC"** veya **"Attached VNICs"** bölümünü bulun.
3.  Orada **"Subnet: subnetpublic"** (veya benzeri) yazan bir link göreceksiniz. O linke tıklayın.
4.  Açılan "Subnet Details" sayfasında, sol menüden (veya Resources altından) **"Security Lists"**e tıklayın.
5.  Listelenen (genelde ismi `Default Security List...` olandır) güvenlik listesine tıklayın.
6.  Karşınıza **"Ingress Rules"** (Gelen Kuralları) çıkar. İşte portlar burada!

**"Add Ingress Rules"** diyerek şu portları açın:

| Source CIDR | Protocol | Port Range         | Açıklama                          |
| :---------- | :------- | :----------------- | :-------------------------------- |
| `0.0.0.0/0` | TCP      | `22` (veya `2222`) | SSH Erişimi                       |
| `0.0.0.0/0` | TCP      | `80`               | HTTP (Web)                        |
| `0.0.0.0/0` | TCP      | `443`              | HTTPS (SSL)                       |
| `0.0.0.0/0` | ICMP     | -                  | Ping atmak isterseniz (Opsiyonel) |

> [!WARNING]
> Eğer SSH portunuzu değiştirdiyseniz (örn: 2222 yaptıysanız), buradaki Security List'te de 2222'yi açmayı unutmayın! Yoksa sunucuya bağlanamazsınız.

## 3. Route Tables & Internet Gateway

Eğer sunucunuz internete çıkamıyorsa (örn: `apt update` hata veriyorsa), Route Table ayarı bozuktur.

1.  **Internet Gateway**'in "Available" durumda olduğundan emin olun.
2.  **Route Table** kurallarını kontrol edin:
    - **Destination:** `0.0.0.0/0` (Tüm dünya)
    - **Target Type:** Internet Gateway
    - **Target:** (Sizin oluşturduğunuz gateway)

Bu kural, "Sunucunun bilmediği IP adreslerine (Google, GitHub vb.) gitmek için Internet Gateway'i kullan" demektir.

## 4. Statik IP (Reserved Public IP)

Oracle'da sunucuyu yeniden başlatırsanız bazen Public IP değişebilir. Bunu sabitlemek için:

1.  Instance detaylarına gidin.
2.  **"Attached VNICs"** menüsüne tıklayın (Sol altta).
3.  VNIC ismine tıklayın -> **"IPv4 Addresses"**.
4.  Mevcut IP'nin yanındaki üç noktaya tıklayın -> **"Edit"**.
5.  **"No Public IP"** seçip kaydedin (IP silinir).
6.  Tekrar **"Edit"** deyin -> **"Reserved Public IP"** seçin ve "Create New Reserved Public IP" diyerek kalıcı bir IP oluşturun.

## Sorun Giderme

**Soru:** UFW'de portu açtım (`ufw allow 80`) ama siteye giremiyorum?
**Cevap:** %99 ihtimalle **Oracle Security List**'te 80 portunu açmadınız. Oraya gidip Ingress Rule ekleyin.

**Soru:** `apt update` çalışmıyor, bağlantı yok?
**Cevap:**

1.  DNS sorunu olabilir (`/etc/resolv.conf`).
2.  **Route Table**'da Internet Gateway (0.0.0.0/0) kuralı eksik veya silinmiş olabilir.

**Soru:** SSH portumu 2222 yaptım, bağlanamıyorum?
**Cevap:** Hem UFW'de (`ufw allow 2222`) hem de Oracle Security List'te (`TCP 2222`) kural eklediniz mi? İkisinden biri eksikse çalışmaz.

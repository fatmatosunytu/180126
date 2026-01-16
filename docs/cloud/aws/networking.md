# AWS Ağ Mimarisi ve Güvenlik Sunucu Kapıları

AWS'de ağ güvenliği, sunucunun içindeki UFW'den önce daha dış bir katmanda, **Security Group (SG)** seviyesinde başlar.

## 1. Security Group (Güvenlik Grubu) Nedir?

Security Group, sunucunuzun önüne konan sanal bir ağ duvarıdır. Oracle'daki **Security List** veya **Network Security Group (NSG)** ile neredeyse aynıdır.

### Temel Özellikler

- **Stateful (Durumlu):** Bir porttan girmeye izin verirseniz, o bağlantının cevabı için otomatik olarak çıkış izni verilir. (UFW'de de genellikle böyledir).
- **Whitelist Mantığı:** Varsayılan olarak her şey kapalıdır. Sadece sizin eklediğiniz kurallar geçebilir.

## 2. Inbound (Giriş) Kuralları

Sunucunuza hangi portlardan kimler gelebilir?

| Protokol       | Port   | Kaynak (Source) | Açıklama                             |
| :------------- | :----- | :-------------- | :----------------------------------- |
| **Custom TCP** | `2222` | `My IP`         | Güvenli SSH Erişimi (Bizim ayarımız) |
| **HTTPS**      | `443`  | `0.0.0.0/0`     | Web trafiği (Tüm dünya)              |
| **HTTP**       | `80`   | `0.0.0.0/0`     | Web trafiği (Tüm dünya)              |

> [!IMPORTANT] > **Neden UFW Varken SG Kullanıyoruz?**  
> Güvenlik katmanlı olmalıdır (Defense in Depth). SG, kötü niyetli trafiği daha sunucunuzun CPU'su ve Network kartı yorulmadan bulut seviyesinde engeller.

## 3. Outbound (Çıkış) Kuralları

Sunucunuz dışarıya nereye gidebilir?

- AWS'de varsayılan olarak **"All Traffic (0.0.0.0/0)"** açıktır.
- Eğer [Firewall (UFW) Rehberimizde](../../security/firewall.md) yaptığımız gibi "çıkışı da kapatmak" (egress filtering) istiyorsanız, AWS SG üzerinde de bu kuralları daraltabilirsiniz. Ancak genellikle varsayılanın açık kalması, güncellemelerin (apt get update) sorunsuz çalışması için bırakılır.

## 4. VPC (Virtual Private Cloud) Temelleri

AWS'de her şey bir VPC içindedir. Bu, sizin buluttaki izole edilmiş özel ağınızdır.

- **Subnet:** VPC içindeki alt ağlar. Sunucular genelde bir Public Subnet içinde bulunur.
- **Internet Gateway (IGW):** Subnet'inizin internete çıkmasını sağlayan kapı. AWS bunu sizin için otomatik ayarlar ama silerseniz sunucuya erişemezsiniz.

## 5. Pratik Uygulama: 2222 Portunu Açmak

Eğer bu rehberi takip ederek SSH portunuzu **2222** yaptıysanız, AWS tarafında da şu ayarı yapmalısınız:

1. EC2 sayfasında sunucunuzu seçin.
2. Alt sekmelerden **Security** > **Security Groups**'a tıklayın.
3. **Inbound Rules** > **Edit Inbound Rules** butonuna basın.
4. **Add Rule** diyerek:
   - Type: `Custom TCP`
   - Port Range: `2222`
   - Source: `My IP` (Kendi güvenliğiniz için)
5. **Save Rules** diyerek kaydedin.

> [!TIP] > **Test:** Eğer hem SG'de portu açtınız hem sunucuda `ufw allow 2222/tcp` yaptınız ama hala giremiyorsanız, sunucudaki SSH servisinin (`sshd`) gerçekten o portu dinlediğinden emin olun:  
> `sudo ss -lntp | grep 2222`

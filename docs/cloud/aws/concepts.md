# Bulut Temelleri ve Karşılaştırma

Farklı bulut sağlayıcıları (AWS, Oracle, Google, Yandex) aynı temel teknolojileri farklı isimlerle pazarlar. Bu bölüm, "bulut dilini" çözmenize ve platformlar arası geçiş yapmanıza yardımcı olur.

## 1. Bulut Terimleri Sözlüğü (Mapping)

Bulut dünyasında her şey temelde bir sunucu, bir disk ve bir ağ kablosudur. İşte devlerin isimlendirmeleri:

| Özellik             | **AWS**        | **Oracle (OCI)**    | **Google (GCP)** | **Azure**        | **DigitalOcean** | **Hetzner**  | **OVHcloud**    |
| :------------------ | :------------- | :------------------ | :--------------- | :--------------- | :--------------- | :----------- | :-------------- |
| **Sanal Sunucu**    | EC2            | Compute Instance    | Compute Engine   | Virtual Machines | Droplets         | Cloud Server | Public Cloud    |
| **Özel Sanal Ağ**   | VPC            | VCN                 | VPC Network      | VNet             | VPC              | Network      | vRack           |
| **Disk (Blok)**     | EBS            | Block Volume        | Persistent Disk  | Managed Disks    | Block Storage    | Volumes      | Block Storage   |
| **Obje Depolama**   | S3             | Object Storage      | Cloud Storage    | Blob Storage     | Spaces           | -            | Object Storage  |
| **Güvenlik Duvarı** | Security Group | Security List / NSG | Firewalls        | NSG              | Cloud Firewalls  | Firewalls    | Security Groups |
| **Sabit IP**        | Elastic IP     | Reserved Public IP  | Static IP        | Static Public IP | Reserved IP      | Floating IP  | Public IP       |

## 2. Neden Birden Fazla Sağlayıcı? (Multi-Cloud)

Tek bir yere bağlı kalmak yerine (Vendor Lock-in), her sağlayıcının en iyi/ucuz yanını kullanmak mantıklıdır.

### Oracle Cloud

- **Artısı:** "Always Free" paketi rakipsizdir (ARM sunucular + 200GB disk bedava).
- **Eksisi:** UI biraz karmaşık olabilir, global ekosistemi AWS kadar büyük değildir.

### AWS (Amazon Web Services)

- **Artısı:** Endüstri standardıdır. Her döküman AWS ile başlar. Kredi (Credit) almak daha kolaydır.
- **Eksisi:** "Egress" (dışarı giden trafik) fiyatlandırması sürprizler yaratabilir.

### Google Cloud (GCP)

- **Artısı:** Global ağı çok hızlıdır (Youtube altyapısı). Kubernetes (GKE) için en iyisidir.
- **Eksisi:** Servisleri çok hızlı öldürebiliyorlar (deprecate) ve arayüzü çok kalabalık.

### Yandex Cloud

- **Artısı:** Yerel bölgelerde (Örn: Rusya, Kazakistan vb.) çok hızlıdır. Kullanım kolaylığı AWS'ye yakındır.
- **Eksisi:** Global varlığı sınırlıdır, bazı ileri düzey servisleri (Managed DB vb.) diğer devler kadar olgun olmayabilir.

### Microsoft Azure

- **Artısı:** Kurumsal şirketlerin (Active Directory, Office 365) merkezidir. Hibrit bulut için en güçlüsüdür.
- **Eksisi:** Arayüzü (Portal) bazen çok yavaş ve karmaşık olabilir.

### DigitalOcean & Linode (Akamai)

- **Artısı:** "Developer-First". Sadelik ve sabit fiyatlandırma (Droplets). Karmaşa sıfıra yakındır.
- **Eksisi:** Kurumsal ölçekte (çok karmaşık networking) kısıtlı kalabilir.

### Hetzner Cloud

- **Artısı:** Fiyat/Performans kralıdır. Avrupa (Almanya/Finlandiya) lokasyonlu, çok ucuz ve çok hızlı sunucular verir.
- **Eksisi:** Global yayılımı (ABD hariç) azdır, sadece temel servisleri sağlar.

### OVHcloud & Scaleway

- **Artısı:** Avrupa'nın en büyükleridir. Veri gizliliği (GDPR) odaklıdırlar. OVH'nin "Bare Metal" sunucuları meşhurdur.
- **Eksisi:** Arayüzleri AWS/GCP kadar akıcı değildir.

### Alibaba Cloud

- **Artısı:** Asya pazarının lideridir. AWS'ye çok benzer bir ekosistemi vardır.
- **Eksisi:** Batılı kullanıcılar için dökümantasyon ve destek bazen zayıf kalabilir.

## 3. Temel Kavramlar

### Region vs. Availability Zone (AZ)

- **Region (Bölge):** Fiziksel bir şehir/ülke (Örn: `eu-central-1` / Frankfurt).
- **AZ / AD (Kullanılabilirlik Bölgesi):** Bir Region içindeki, birbirinden bağımsız çalışan veri merkezleri. Bir AD su altında kalsa bile diğeri çalışmaya devam eder.

### IaaS vs. PaaS vs. SaaS

- **IaaS (Altyapı):** Boş sunucu alırsınız, her şeyi siz kurarsınız (EC2, OCI Compute). Bizim rehberimiz buna odaklanır.
- **PaaS (Platform):** Sunucuyu görmezsiniz, sadece kodunuzu atarsınız (Heroku, AWS Lambda).
- **SaaS (Yazılım):** Direkt bir hizmeti kullanırsınız (Google Drive, Slack).

## 4. Kritik Fark: "Always Free" vs. "Cloud Credits"

- **Oracle Always Free:** Sunucu sonsuza kadar ücretsizdir (siz silmedikçe). Prototip ve kişisel bloglar için idealdir.
- **AWS Credits:** Hesabınıza örn. 1000$ tanımlanır. Bu para bitene kadar veya süresi (genelde 1-2 yıl) dolana kadar ücretsiz kullanırsınız. Para bitince fatura gelmeye başlar.

> [!TIP] > **Strateji:** Daimi çalışan küçük servisleri Oracle Always Free'de, yüksek performans gerektiren veya krediniz varken maliyetli olan işleri AWS'de tutmak en mantıklı harekettir.

# Gereksiz Servislerin Temizliği (Multi-Cloud)

Sanal sunucular (VPS), genellikle çok amaçlı imajlardan türetilir. Bu imajlar, "her duruma uysun" diye ihtiyacınız olmayan onlarca servisle yüklü gelir.

Bu rehber **Oracle Cloud, Google Cloud (GCP), Alibaba Cloud** ve **AWS** üzerindeki **Ubuntu, Debian ve CentOS** sistemleri için geçerlidir.

---

## 1. Analiz: Neyin Çalıştığını Gör

Körlemesine servis kapatmayın. Önce neyin çalıştığını görün.

=== "Debian / Ubuntu"
`bash
    systemctl list-units --type=service --state=running
    `

=== "CentOS / RHEL"
`bash
    systemctl list-units --type=service --state=running
    `

## 2. Evrensel Gereksizler (Bloatware)

Hangi bulut sağlayıcısında olursanız olun, bir sunucuda bunlara ihtiyacınız yoktur.

### Yazıcı ve Çevre Birimleri

Sunucunun yazıcısı, tarayıcısı veya ses kartı (genelde) yoktur.

- **cups:** Linux yazdırma servisi (Common Unix Printing System).
- **bluetooth:** Bluetooth donanımı yönetimi.
- **alsa / pulseaudio:** Ses yönetimi.

=== "Temizlik Komutu"

````bash # Servisleri durdur
sudo systemctl stop cups cups-browsed bluetooth
sudo systemctl disable cups cups-browsed bluetooth

    # Paketleri tamamen sil (Ubuntu/Debian)
    sudo apt purge -y cups* bluez* alsa-utils
    sudo apt autoremove -y
    ```

### Masaüstü Kalıntıları

Eğer "Minimal" olmayan bir imaj kullandıysanız şunlar olabilir:

- **ModemManager:** USB Modem/SIM kart yönetimi (Sunucuda 4G modül yoksa gereksiz).
- **udisks2:** Masaüstü ortamları için disk otomatik bağlama aracı.

```bash
sudo systemctl stop ModemManager udisks2
sudo systemctl disable ModemManager udisks2
````

---

## 3. Depolama ve Ağ Servisleri

### Multipath Tools (`multipathd`) Nedir?

**Durum:** Oracle Cloud ve Enterprise RHEL/CentOS imajlarında sıkça görülür.
**Ne Yapar?** Sunucuya bağlı bir diske giden birden fazla kablo/yol (path) varsa, biri koparsa diğerinden devam etmeyi sağlar.
**Kapatmalı mıyım?** **EVET:** Eğer sunucunuz standart bir VM ise ve sadece **Boot Volume** kullanıyorsanız. Veya ek diskiniz (`/dev/sdb`) olsa bile `/dev/mapper` altında görünmüyorsa.

- **HAYIR:** Kurumsal SAN/iSCSI yapısında, diski `/dev/mapper/mpatha` gibi bir isimle kullanıyorsanız.

**Kontrol (Emin Değilseniz):**

```bash
lsblk
# Çıktıda diskler "sdb -> sdb1" şeklindeyse Multipath YOKTUR -> Kapatın.
# Çıktıda "sdb -> mpatha" görüyorsanız Multipath VARDIR -> Dokunmayın.
```

**Kapatma:**

```bash
sudo systemctl stop multipathd
sudo systemctl disable multipathd
```

### RPC Bind (`rpcbind`)

**Durum:** Her yerde çıkabilir.
**Ne Yapar?** NFS (Dosya paylaşımı) için port haritalaması yapar.
**Kapatmalı mıyım?** Başka bir sunucudan klasör bağlamıyorsanız (`mount nfs...`) kapatın. Güvenlik riski oluşturur (DDoS tetikleyicisi olabilir).

```bash
sudo systemctl stop rpcbind
sudo systemctl stop rpcbind.socket
sudo systemctl disable rpcbind
sudo systemctl disable rpcbind.socket
```

---

## 4. Dağıtıma Özel Notlar

### Ubuntu / Debian

- **snapd:** Canonical'ın paket yöneticisi. Bazı kullanıcılar _Snap_ paketlerini yavaş ve "bloat" bulur. Eğer `docker` veya `apt` kullanıyorsanız Snap'i tamamen silebilirsiniz.
  - _Uyarı:_ `certbot` kuracaksanız Ubuntu bazen snap ile kurmayı önerir. Alternatifini (`pip` veya `apt`) bildiğinizden emin olun.
- **unattended-upgrades:** **SİLMEYİN.** Güvenlik güncellemelerini yapar.
- **fwupd:** Firmware update. Sanal sunucuda gereksizdir, silebilirsiniz.

### CentOS / RHEL / Fedora

- **postfix:** RHEL tabanında varsayılan yüklü gelir (Sadece local mail için). Dışarıya mail atmıyorsanız silebilirsiniz veya `inet_interfaces = localhost` yaptığınızdan emin olun.
- **firewalld:** Eğer bizim rehberdeki gibi **UFW** kuracaksanız, `firewalld` servisini mutlaka kapatın. İkisi çakışır.
  ```bash
  sudo systemctl stop firewalld && sudo systemctl disable firewalld
  ```
- **tuned:** Performans profili aracıdır. **Silmeyin**, "virtual-guest" profilinde çalıştığından emin olun (`tuned-adm active`).

---

## 5. Bulut Ajanları (Cloud Agents) - DOKUNMAYIN!

Bulut sağlayıcıları, sunucuyu yönetmek (şifre sıfırlama, metrik izleme, IP atama) için kendi ajanlarını yükler. Bunları silmek risklidir.

- **Genel:** `cloud-init` (İlk açılış ayarları - **ASLA SİLMEYİN**)
- **Oracle:** `oracle-cloud-agent` (Monitoring ve yönetim için, genelde kalsın).
- **Google Cloud:** `google-guest-agent`, `google-oslogin-agent` (SSH anahtarlarını yönetir. Silerseniz panele erişemeyebilirsiniz!).
- **Alibaba:** `aliyun-service` (Aliyun Assist). Alibaba'nın yönetim aracıdır.

> [!WARNING]
> Bu ajanları "casusluk yapıyor" diye silenler olur ancak sildiğinizde sunucu yönetim panelindeki "Reboot", "Reset Password" veya "Graphs" özellikleri çalışmayabilir. Ne yaptığınızdan %100 emin değilseniz dokunmayın.

---

## Özet Kontrol Listesi

Temizlik sonrası son bir kontrol için şu komutu çalıştırıp "kırmızı bayrak" listedekiler var mı bakın:

```bash
# Şüphelileri ara
sudo systemctl list-units --type=service --state=running | grep -E "cups|blue|Modem|rpcbind|postfix|exim4|multipath"
```

Çıktı boşsa sunucunuz fit ve güvenli demektir. 🚀

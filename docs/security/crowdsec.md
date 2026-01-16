# CrowdSec ile Modern Koruma

**CrowdSec**, "kitlesel istihbarat" (crowd-sourced intelligence) kullanan modern bir güvenlik aracıdır. Fail2ban'in "yeni nesil" halefi olarak düşünülebilir.

> [!CAUTION] > **Önce Fail2ban'i Silin:** CrowdSec kurmadan önce sunucunuzda Fail2ban varsa mutlaka durdurun ve kaldırın. İkisi aynı anda **çalışmamalıdır**.
>
> ```bash
> sudo systemctl stop fail2ban
> sudo apt remove fail2ban
> ```

## Neden CrowdSec?

Fail2ban sadece **sizin** loglarınızı okur. CrowdSec ise **herkesin** deneyiminden faydalanır.

Dünyanın bir ucundaki saldırgan başka bir CrowdSec kullanıcısına saldırdığında, IP adresi "kötü niyetli" olarak işaretlenir ve bu bilgi anında (veya kısa sürede) sizin sunucunuza da gelir. Böylece saldırgan daha kapınıza gelmeden engellenmiş olur.

| Özellik        | Fail2ban                   | CrowdSec                                     |
| :------------- | :------------------------- | :------------------------------------------- |
| **Mantık**     | Log okur, Regex ile banlar | Log okur, Senaryo (Scenario) ile karar verir |
| **İstihbarat** | Yok (Sadece yerel)         | Var (Küresel IP veritabanı)                  |
| **Hız**        | Hızlı                      | Çok Hızlı (Golang ile yazılmış)              |
| **Yönetim**    | Dosya tabanlı (Basit)      | CLI + Web Konsol (Modern)                    |

---

## 1. Kurulum (Debian/Ubuntu)

Kurulumu oldukça basittir. Script, gerekli repoları ekler.

```bash
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
sudo apt install -y crowdsec
```

Kurulum sırasında CrowdSec, sunucunuzdaki servisleri (SSH, Nginx, Docker vb.) otomatik algılar ve uygun koleksiyonları (Collection) kurar.

### Firewall Bouncer Kurulumu

CrowdSec tek başına sadece "tespit" yapar (Detect). Engelleme yapması (Remediate) için bir "Bouncer" kurmalısınız. En yaygını `iptables` bouncer'ıdır.

```bash
sudo apt install -y crowdsec-firewall-bouncer-iptables
```

_(Eğer `nftables` kullanıyorsanız `crowdsec-firewall-bouncer-nftables` kurun.)_

## 2. Temel Komutlar (cscli)

Yönetim için `cscli` komutunu kullanırız.

### Durum Kontrolü

```bash
# Servisler çalışıyor mu?
systemctl status crowdsec
systemctl status crowdsec-firewall-bouncer

# Bouncer listesi ve durumu
sudo cscli bouncers list
```

### Kararlar (Decisions) ve Banlama

```bash
# Kimler banlı? (Mevcut kararlar)
sudo cscli decisions list

# Bir IP'yi manuel banla (4 saatliğine)
sudo cscli decisions add --ip 1.2.3.4 --duration 4h --reason "Supheli hareket"

# Banı kaldır
sudo cscli decisions delete --ip 1.2.3.4
```

### Metrikler

```bash
sudo cscli metrics
```

## 3. Koleksiyonlar ve Senaryolar

CrowdSec, "Hub" mantığıyla çalışır. İhtiyacınız olan koruma paketlerini indirirsiniz.

```bash
# Mevcut koleksiyonları listele
sudo cscli collections list

# Yeni bir koleksiyon kur (Örn: Nginx)
sudo cscli collections install crowdsecurity/nginx
sudo systemctl reload crowdsec
```

> [!TIP] > `crowdsecurity/linux` koleksiyonu (SSH ve Systemd için) varsayılan olarak gelir.

## 4. Docker Entegrasyonu

Docker konteynerlerini korumak için CrowdSec'in loglara erişmesi gerekir. İki ana yöntem vardır:

### Yöntem 1: Host Üzerinden (Önerilen)

CrowdSec'i host makineye kurduysanız (yukarıdaki gibi), Docker konteynerlerinin loglarını okuması yeterlidir.

`/etc/crowdsec/acquis.yaml` dosyasını düzenleyip Docker loglarını ekleyin:

```yaml
filenames:
  - /var/lib/docker/containers/*/*.log
labels:
  type: docker
```

Ve `crowdsec` servisini yeniden başlatın.

### Yöntem 2: Docker Container Olarak

CrowdSec'i de bir Docker konteyneri olarak çalıştırabilirsiniz. Bu durumda diğer konteynerlerin loglarını okuyabilmesi için `docker.sock` dosyasını bind etmeniz gerekir.

_Detaylı Docker-Compose kurulumu için proje dokümantasyonuna bakınız._

## 5. Web Konsol (Zorunlu Değil Ama Harika)

CrowdSec'in sunduğu [app.crowdsec.net](https://app.crowdsec.net) adresinden ücretsiz hesap açıp sunucunuzu bağlayabilirsiniz.

- Saldırıları grafiksel olarak görürsünüz.
- Hangi ülkeden, hangi IP'den saldırı geldiğini haritada izlersiniz.
- Birden çok sunucunuz varsa hepsini tek ekrandan yönetirsiniz.

**Sunucuyu Konsola Bağlama:**

```bash
sudo cscli console enroll <KODUNUZ>
```

_(Kodu, web panelden "Add Instance" diyerek alabilirsiniz.)_

# Lynis (Güvenlik Denetimi)

Lynis, sunucuda hızlı bir güvenlik denetimi yapıp, sisteminizi 100 üzerinden puanlayan ve eksikleri raporlayan bir araçtır. Bir "Antivirüs" değildir; bir "Müfettiş"tir.

## 1. Kurulum

```bash
sudo apt update
sudo apt install -y lynis
```

## 2. Tarama Başlatma

Taramayı başlatın:

```bash
sudo lynis audit system
```

_(Enter'a basarak ilerleyebilirsiniz. Hızlı geçmek için `-Q` parametresini kullanabilirsiniz: `sudo lynis audit system -Q`)_

## 3. Yaygın Uyarılar ve Çözümleri

Tarama sonucunda muhtemelen şunları göreceksiniz:

### ⚠️ Malware scanner not found

**Anlamı:** Lynis, sistemde virüs veya rootkit tarayıcısı (ClamAV, Rkhunter) bulamadı.
**Çözüm:** Bu bir "hata" değil, eksikliktir. Linux sunucularda antivirüs şart değildir ama "Rootkit Hunter" kurmak iyi bir pratiktir.
**Çözüm:** Bu bir "hata" değil, eksikliktir. Linux sunucularda antivirüs şart değildir ama "Rootkit Hunter" kurmak iyi bir pratiktir.
**Kurulum (Opsiyonel):**

Detaylı kurulum ve yapılandırma için [Malware & Rootkit Taraması](malware.md) sayfasını inceleyin.

### ⚠️ Security repository not found (PKGS-7388)

**Anlamı:** Lynis, Ubuntu 24.04'ün yeni kaynak formatını (`.sources`) bazen tanıyamaz ve güvenlik deposu yok sanır.
**Çözüm:** Bu bir **False Positive** (Yanlış Alarm) durumudur. Eğer `apt-cache policy` çıktısında `-security` görüyorsanız bu uyarıyı görmezden gelebilirsiniz.

## 4. Sık Kullanılan Parametreler 🛠️

Lynis'i daha efektif kullanmak için şu parametreleri bilmenizde fayda var:

| Parametre        | Ne İş Yapar?                                     | Örnek                                          |
| :--------------- | :----------------------------------------------- | :--------------------------------------------- |
| **`-Q` (Quick)** | Hiçbir tuşa basmanızı beklemez, otomatik tarar.  | `lynis audit system -Q`                        |
| **`--pentest`**  | Root olmayan (non-privileged) bir tarama yapar.  | `lynis audit system --pentest`                 |
| **`--verbose`**  | Ekrana daha detaylı çıktı (kırmızı/yeşil) basar. | `lynis audit system --verbose`                 |
| **`--log-file`** | Raporu özel bir dosyaya kaydeder.                | `lynis audit system --log-file=/tmp/lynis.log` |

### ⚠️ Old version / Update available

**Anlamı:** Lynis'in kendi sürümü eski olabilir (`apt` depolarındaki sürüm bazen resmi siteden geriden gelir).
**Çözüm:** Güvenlik açığı değildir, sadece tool'un güncel olmadığını söyler. Önemli değildir.

### ⚠️ Firewall not active

**Anlamı:** UFW veya Iptables aktif değil.
**Çözüm:** Firewall bölümündeki ayarları yapın. (Docker kullanıyorsanız bu uyarı bazen yanıltıcı olabilir, `nft list ruleset` ile kontrol edin).

### ⚠️ Banner / Issue file

**Anlamı:** SSH ile bağlanırken ekranda "Ubuntu 22.04" gibi versiyon bilgisi yazıyor. Saldırganlara bilgi vermemek için bunu gizlemenizi önerir.
**Çözüm:** `/etc/issue.net` dosyasının içeriğini temizleyebilirsiniz.

## 4. Raporu Okuma

Tarama bitince size bir **Hardening Index** (Örn: 65/100) verir.

- **60 altı:** Güvenlik zayıf, acil önlem lazım.
- **70-80 arası:** Gayet iyi, standart bir sunucu için yeterli.
- **90 üstü:** Çok sıkı (Hardened), bazen kullanımı zorlaştırabilir.

Detaylı rapor `/var/log/lynis.log` dosyasındadır.

## 5. Otomatik Tarama (Cron)

Ayda bir sistemin sağlık durumunu kontrol etmek için:

```bash
echo "0 3 1 * * root /usr/bin/lynis audit system -Q" | sudo tee /etc/cron.d/lynis-audit
```

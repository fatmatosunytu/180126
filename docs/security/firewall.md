# Firewall (UFW) Yönetimi

Linux çekirdeğindeki (Kernel) paket filtresini yönetmek için **UFW (Uncomplicated Firewall)** kullanıyoruz.

> [!IMPORTANT] > **Altın Kural:** "Her şeyi kapat, sadece ihtiyacı aç." (Default Deny)

## 1. Kritik Uyarı: Docker ve UFW

> [!WARNING] > **Docker kullananlar dikkat!**  
> Docker, varsayılan olarak `iptables` kurallarını kendisi yönetir ve UFW'yi **bypass eder**. Yani UFW ile bir portu kapatsanız bile, Docker konteyneri o portu (örn: 8080) host'a bind ettiyse, dış dünyadan erişilebilir!

### "Manuel Iptables Ayarı Yapmalı mıyım?" (Hayır!)

Docker, kendi kurallarını `iptables` zincirinin en başına yazar. Bunu engellemek için kuralları `DOCKER-USER` zincirine manuel ekleyebilirsiniz ANCAK:

1.  **Zordur:** `iptables` komutları karmaşıktır (`-I DOCKER-USER -i eth0 ! -s 127.0.0.1 -j DROP` gibi).
2.  **Kalıcı Değildir:** Sunucu yeniden başlayınca kurallar silinebilir (`iptables-save` yapılmazsa).
3.  **Hata Kaldırmaz:** Yanlış bir kural Docker ağını komple bozabilir.

**Bu yüzden `ufw-docker` aracını kullanın.** Bu araç, o karmaşık `iptables` kurallarını sizin yerinize güvenli şekilde yönetir.

> [!TIP] > **Mimari Çözüm:** Portları hiç açmamak en iyisidir!  
> Docker'da güvenli "Gateway Modeli" kurmak için [Docker Gateway Mimarisi](docker-gateway.md) rehberini mutlaka okuyun.

### Önerilen Çözüm: ufw-docker

Üretim ortamı için en temiz çözüm `ufw-docker` utility'sini kullanmaktır:

```bash
# Aracı indir ve kur
sudo wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
sudo chmod +x /usr/local/bin/ufw-docker

# Docker'ın iptables manipülasyonunu düzelt
ufw-docker install
```

## 2. Hazırlık ve IPv6

Önce IPv6 desteğinin açık olduğundan emin olun (çoğu modern sunucuda varsayılan açıktır):

```bash
nano /etc/default/ufw
# IPV6=yes olduğundan emin olun
```

Sıfırdan başlıyorsanız temizleyin:

```bash
ufw disable
ufw reset
```

## 3. Varsayılan Politikalar (Default Policies)

Çoğu rehber sadece girişi kapatır. Biz **çıkışı da** kapatarak (egress filtering) güvenliği artıracağız. Bu, sunucunun hacklenmesi durumunda dışarıya veri kaçırılmasını veya sunucunun bir botnet parçası olmasını zorlaştırır.

```bash
# Giren her şeyi engelle (Standart)
ufw default deny incoming

# Çıkan her şeyi engelle (Hardening)
ufw default deny outgoing
```

## Operasyon ve Bakım (SSS)

### "Status: inactive" Nedir?

UFW kurulduğunda varsayılan olarak **kapalıdır**. `sudo ufw enable` komutunu çalıştırdığınızda hem şimdi açılır hem de açılışta (boot) otomatik başlaması için `systemd` servisini ayarlar. Yani bir kere etkinleştirmeniz yeterlidir, sunucu kapanıp açılsa da çalışır.

### IPv6 Kuralları (v6)

`ufw status` çıktısında `(v6)` ibareli kurallar görürsünüz. Bu normaldir.
Eğer sunucunuzda IPv6 kullanmıyorsanız ve bu kuralları kapatmak isterseniz:

1.  `/etc/default/ufw` dosyasını açın.
2.  `IPV6=yes` satırını `IPV6=no` yapın.
3.  `sudo ufw reload` yapın.

> [!NOTE]
> Zararı yoktur, açık kalması güvenlik riski oluşturmaz (tabii porta izin vermediyseniz).

### Kural Tekrarı (80 vs 80/tcp)

`ufw allow 80` yazarsanız hem TCP hem UDP protokolüne izin verir.
`ufw allow 80/tcp` yazarsanız sadece TCP'ye izin verir.
Listede iki kuralın da görünmesi normaldir. Web sunucular genelde sadece TCP kullanır, bu yüzden `80/tcp` daha temizdir ama `80` de sorun çıkarmaz.

### Yeni Port Nasıl Eklenir?

Gelecekte yeni bir servis (örn: Port 5000) açmak isterseniz **İKİ ADIM** gereklidir:

1.  **Sunucu İçi:** `sudo ufw allow 5000/tcp`
2.  **Oracle/Bulut Paneli:** Security List > Ingress Rules > Port 5000 Ekle

Sadece birini yaparsanız erişemezsiniz!

## 4. Kural Silme ve Port Kapatma

Bir portu kapatmanın iki yolu vardır. En temiz yöntem **kuralı silmektir**.

### Yöntem 1: Kuralı Silmek (Önerilen)

Mevcut izni kaldırırsınız. Varsayılan politikamız `deny incoming` olduğu için, izin silinince port otomatikman kapanır.

En kolay yol **numaralı liste** kullanmaktır:

1.  Numaraları listeleyin:
    ```bash
    sudo ufw status numbered
    ```
2.  İstediğiniz numarayı silin (Örn: 1 numaralı kuralı silmek için):
    ```bash
    sudo ufw delete 1
    ```
    _Dikkat: Bir kuralı silince alttakilerin numarası yukarı kayar! Her silme işleminden sonra tekrar `status numbered` yapın._

### Yöntem 2: "Deny" Kuralı Eklemek

Kuralı silmeden, o porta özel bir "yasak" kuralı eklersiniz.

```bash
sudo ufw deny 22/tcp
```

_Bu yöntem listenizi kalabalıklaştırır. Genellikle belirli bir IP'yi engellemek (`deny from 1.2.3.4`) için kullanılır, port kapatmak için `delete` daha temizdir._

## 5. Temel Kurallar ve Hizmetler

> [!TIP]
> Kuralları eklerken `comment` parametresini kullanmak, ileride `ufw status` çıktısını okurken hayat kurtarır.

### SSH (Öncelikli)

SSH portunuz varsayılan (22) değilse, kendi portunuzu yazın. Sadece `allow` yerine `limit` kullanarak basit brute-force saldırılarını yavaşlatın.

```bash
# Rate limiting ile SSH izni (Son 30 saniyede 6 başarısız denemede IP'yi banlar)
ufw limit 2222/tcp comment 'SSH Port'
```

### Web Sunucusu (HTTP/HTTPS)

```bash
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
```

### Kritik Giden Trafik (Outbound)

Çıkışı kapattığımız (`default deny outgoing`) için, sunucunun çalışması için hayati olan portlara izin vermeliyiz:

```bash
# DNS Sorguları (Domain çözümlemek için şart)
ufw allow out 53 comment 'DNS'

# HTTP/HTTPS (Update yapmak, curl ile dosya çekmek, webhook çağırmak için)
ufw allow out 80/tcp comment 'HTTP Out'
ufw allow out 443/tcp comment 'HTTPS Out'

# NTP (Zaman senkronizasyonu)
ufw allow out 123/udp comment 'NTP'
```

## 5. İleri Seviye Güvenlik

### Loglama (Logging)

Lynis gibi denetim araçları firewall loglarını kontrol eder. Loglamayı açın ancak diski doldurmamak için "low" seviyesinde tutun.

```bash
ufw logging on
ufw logging low
```

_Loglar `/var/log/ufw.log` dosyasına yazılır._

### IP Bazlı Kısıtlamalar

SSH veya yönetim panelleri gibi hassas servisleri tüm dünyaya açmak yerine sadece ofis/VPN IP'nize açın.

```bash
# Mevcut genel kuralı sil
ufw delete limit 2222/tcp

# Sadece ofis IP'sine izin ver (Whitelisting)
ufw allow from 198.51.100.4 to any port 2222 proto tcp comment 'SSH Office IP'
```

### IP Banlama (Blacklisting)

```bash
# Tek bir IP'yi engelle
ufw deny from 203.0.113.4

# Tüm bir subnet'i engelle
ufw deny from 203.0.113.0/24
```

## 6. Yönetim ve Kontrol

### Kuralları Silme

Komutları hatırlamak yerine numaralı listeyi kullanın:

```bash
ufw status numbered
# Çıktıdaki numaraya göre sil (Örn: 2 numarayı sil)
ufw delete 2
```

### Aktifleştirme ve Doğrulama

**DİKKAT:** SSH kuralının ekli olduğundan %100 emin olun yoksa sunucuya erişiminizi kaybedersiniz.

```bash
ufw enable
```

Durumu detaylı kontrol edin:

```bash
ufw status verbose
```

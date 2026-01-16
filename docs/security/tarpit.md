# Aktif Savunma: Hacker Tuzaklama (Tarpit)

> [!TIP] > **Eğlence Zamanı!** 🎣
> Bu bölüm zorunlu değildir ama yapması çok zevklidir. Sunucunuzu boş boş tarayan botlardan intikam almak istiyorsanız doğru yerdesiniz.

## Tarpit Nedir?

SSH portunuzu **2222**'ye taşıdınız. Peki boş kalan **22** portuna ne olacak?
Genelde "Connection Refused" (Kapalı) hatası döner. Bot gelir, kapalı olduğunu görür ve gider.

**Ama biz gitmesini istemiyoruz.** Biz istiyoruz ki bot o kapıda **sonsuza kadar** beklesin.

İşte **Endlessh** (Endless SSH) tam olarak bunu yapar.

1.  Port 22'yi dinler.
2.  Gelen bota "Merhaba, ben SSH sunucusuyum... biraz bekle..." der.
3.  Ve sonra saniyede bir harf göndererek (`H.... e.... l.... l....`) botu hattın ucunda tutar.
4.  Bot, "Bağlantı koptu kopacak" diye beklerken günler geçer.

## Kurulum (Docker ile)

En temiz yöntem Docker kullanmaktır. (Sunucunuzda henüz Docker yoksa kurulum bölümüne geçin veya `apt install endlessh` deneyin).

```bash
docker run -d \
  --name endlessh \
  --restart always \
  -p 22:2222 \
  stored/endlessh
```

_Not: İçeride 2222 portunda çalışır ama biz onu dışarıya (host'a) 22 olarak veririz._

## Kurulum (Ubuntu Native)

Eğer Docker kullanmadan kurmak isterseniz:

1.  Paketi kurun:

    ```bash
    sudo apt update
    sudo apt install -y endlessh
    ```

2.  Ayarlarını düzenleyin:

    ```bash
    sudo nano /etc/endlessh/config
    ```

    İçeriği şöyle yapın:

    ```ini
    # Port 22'de dinle (Dikkat: Aşağıdaki ayar gereklidir)
    Port 22
    Delay 10000
    MaxLineLength 32
    MaxClients 4096
    LogLevel 1
    ```

3.  Port 22 (Privileged Port) izni verin:
    Endlessh normal kullanıcı yetkisiyle çalıştığı için 1024 altındaki portları (22) dinleyemez. İzin verelim:

    ```bash
    sudo setcap 'cap_net_bind_service=+ep' /usr/bin/endlessh
    ```

4.  Servisi aktif edin:
    ```bash
    # Systemd dosyasında "AmbientCapabilities" ayarı gerekebilir,
    # ama setcap genelde çözer.
    sudo systemctl enable endlessh
    sudo systemctl restart endlessh
    ```

## İzleme (Eğlenceli Kısım) 🍿

Kimler tuzağa düşmüş görmek için loglara bakın:

```bash
# Native kurulum için:
journalctl -fu endlessh

# Docker için:
docker logs -f endlessh
```

Şuna benzer şeyler göreceksiniz:
`ACCEPT host=192.168.1.50 port=54321`
`CLOSE host=192.168.1.50 ... time=340.523s`

Gördüğünüz gibi, botu 340 saniye (5 dakika) boyunca boşuna bekletmişsiniz. Kaynak tüketimi? **Sıfıra yakın.**

> [!WARNING] > **Firewall Ayarı:**
> Bunu yaptıktan sonra UFW'de veya Oracle Security List'te **Port 22**'yi tekrar açmalısınız ki botlar içeri girebilsin! (Kendi gerçek SSH'ınızın 2222'de olduğundan %100 emin olun).

## Diğer Aktif Savunma Konseptleri (Teori)

Tarpit (batağa saplama) sadece bir yöntemdir. "Deception" (Aldatma) dünyasında başka ilginç teknikler de vardır:

### 1. Honeyport / Canary Port

Gerçekte servis çalıştırmadığınız bir portu (örn: 1234) izlersiniz. Oraya biri dokunduğu an "Alarm" çalar veya o IP anında tüm portlardan banlanır.
_Mantık: "Bu portu kimse bilmemeli, dokunan kesinlikle dost değildir."_

### 2. Fake Banner (Servis Yanıltma)

Aslında Nginx kullanıyorsunuzdur ama sunucu kendini "Apache 2.4" diye tanıtır. Saldırgan Apache açığı ararken boşa zaman harcar.
_Amaç: Profil çıkarmayı (Reconnaissance) bozmak._

### 3. Canary Tokens (Yemler)

Sunucunun içine "password.txt" diye sahte bir dosya veya veritabanına sahte bir "admin" kullanıcısı koyarsınız.
Biri bu dosyayı açarsa veya bu kullanıcıyla giriş yaparsa sistem size "Biri içeride!" diye haber verir.
_Bu, saldırı engellemekten çok, içeri sızanı tespit etmek (Detection) içindir._

### 4. High vs Low Interaction Honeypot

- **Low-Interaction:** Sadece login ekranı gösterir (Endlessh gibi). Daha güvenlidir.
- **High-Interaction:** Gerçek bir Linux gibi davranır, hacker komut çalıştırabilir. Çok risklidir, sadece araştırma (Research) için kullanılır.

> [!TIP] > **Production İçin Öneri:**
> Sadece **Endlessh** (Tarpit) ve **Honeyport** (IP Banlama) production için güvenli ve az kaynak tüketen yöntemlerdir. Diğerleri laboratuvar ortamında denenmelidir.

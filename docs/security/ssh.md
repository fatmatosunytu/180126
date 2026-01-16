# SSH Güvenli Port Değiştirme (adim-adim)

Bu rehber, SSH portunu **22**'den **2222**'ye taşırken "içeride kilitli kalmamanız" için en güvenli yöntemi anlatır.

## Hazırlık: Mevcut Durumu Gör

Önce şu an hangi portun dinlediğini ve UFW durumunu kontrol edin:

```bash
sudo ufw status verbose
# Çıktı "Status: active" ise kurallar işliyor demektir.
# "Inactive" ise firewall kapalıdır, yine de aşağıdakileri yapın.

sudo ss -lntp | grep sshd
# Çıktıda ":22" görüyorsanız şu an standart porttasınız. ok.
```

## Adım 1: Firewall Sigortası (UFW)

SSH ayarını değiştirmeden önce, Firewall'da hem mevcut kapıyı hem yeni kapıyı açmalıyız. Bu "sigorta" işlemidir.

1.  **Mevcut portu garantiye al (Sigorta):**

    ```bash
    sudo ufw allow 22/tcp
    ```

2.  **Yeni hedef portu aç:**

    ```bash
    sudo ufw allow 2222/tcp
    ```

3.  **Temel kurallar ve aktifleştirme:**

    ```bash
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw enable
    # "Yes" deyin. Bağlantınız kopmaz çünkü 22'ye izin verdik.
    ```

4.  **Kontrol:**
    ```bash
    sudo ufw status numbered
    # Çıktıda HEM 22/tcp HEM 2222/tcp "ALLOW" olarak görünmeli.
    ```

> [!WARNING] > **Oracle Cloud Kullanıcıları:**
> Sadece UFW yetmez! Oracle panelinden (VCN > Security List) de **2222** portuna Ingress Rule eklemelisiniz. Yoksa sunucu 2222'den gelen paketi daha UFW'ye gelmeden reddeder.

## Adım 2: Konfigürasyon Değişikliği

Şimdi SSH servisine "Artık 2222'den dinle" diyeceğiz.

Dosyayı açın:

```bash
sudo nano /etc/ssh/sshd_config
```

Şunları düzenleyin (satırın başında `#` varsa kaldırın):

```ssh
Port 2222
PermitRootLogin no
PasswordAuthentication no
```

Kaydet ve çık (`Ctrl+O`, `Enter`, `Ctrl+X`).

## Adım 3: Ubuntu 22.04+ Socket Sorunu (Kritik)

Ubuntu 22.04 ve sonrasında SSH, varsayılan olarak **"Socket Activation"** ile çalışır. Yani `sshd_config` dosyasında portu değiştirseniz bile, `systemd` (ssh.socket) 22. portu dinlemeye devam eder ve değişikliği görmezden gelir.

**Bu sorunu çözmek ve standart moda geçmek için:**

1.  Socket'i durdurun ve iptal edin:

    ```bash
    sudo systemctl stop ssh.socket
    sudo systemctl disable ssh.socket
    ```

2.  Klasik servisi aktif edin:
    ```bash
    sudo systemctl enable ssh.service
    ```

> [!NOTE]
> Bu işlem CentOS/RHEL veya Debian'da gerekmez, onlar zaten standart modda çalışır. Ama Ubuntu'da **şarttır**.

## Adım 4: Test ve Restart

Hatayı restart atmadan önce yakalamalıyız.

1.  **Config syntax testi:**

    ```bash
    sudo sshd -t
    ```

    _(Çıktı yoksa her şey yolunda demektir. Hata varsa düzeltin!)_

2.  **Servisi yeniden başlat:**
    ```bash
    sudo systemctl restart ssh
    ```
    _(Bağlantınız hala kopmadı, korkmayın.)_

## Adım 4: İçeriden Bağlantı Testi (Localhost)

Yeni terminal açmadan önce, sunucunun kendi kendine 2222'den bağlanabildiğini doğrulayın:

```bash
ssh -p 2222 localhost
```

_Şifre veya key soruyorsa (veya "Permission denied" diyorsa) port çalışıyor demektir. "Connection refused" diyorsa servis kalkmamıştır._

## Adım 5: Dışarıdan Bağlantı Testi

1.  Mevcut terminali **KAPATMAYIN**.
2.  Bilgisayarınızdan **yeni bir terminal** açın.
3.  Bağlanmayı deneyin:
    ```bash
    ssh -p 2222 kullanici@sunucu-ip
    ```

## Adım 6: Temizlik (Eski Kapıyı Kapat)

Başarıyla girdiyseniz artık 22'ye ihtiyacınız yok.

```bash
sudo ufw delete allow 22/tcp
sudo ufw reload
```

Artık sadece 2222 açık! 🔒

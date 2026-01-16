# Script Çalıştırma Standartları

Scripti yazdık, peki nasıl çalıştıracağız? "Arkaplanda çalışsın" veya "Her gece çalışsın" dediğimizde aklımıza gelen ilk yöntemler (`nohup`, `cron`) genelde en iyi yöntemler değildir.

## 1. Zamanlanmış Görevler: Cron vs Systemd Timers

Prodüksiyon sunucularında **Cron kullanmayı önermiyoruz.** Neden?

- Cron hatayı sessizce yutar (Loglamazsa göremezsiniz).
- Bağımlılık yönetemez (Network gelmeden çalışırsa patlar).

### Önerilen: Systemd Timers

Bir işi her gece 03:00'te yapmak için iki dosya oluşturuyoruz:

#### A. Service Dosyası (`/etc/systemd/system/myscript.service`)

Gerçek işi yapan tanım.

```ini
[Unit]
Description=My Backup Script

[Service]
Type=oneshot
ExecStart=/opt/scripts/backup.sh
User=deployer
```

#### B. Timer Dosyası (`/etc/systemd/system/myscript.timer`)

Zamanlayıcı tanımı.

```ini
[Unit]
Description=Run backup every night

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

**Aktifleştirme:**

```bash
systemctl daemon-reload
systemctl enable --now myscript.timer
```

## 2. Arkaplan İşlemleri (Background Execution)

Bir scripti SSH'ı kapattıktan sonra da çalışsın diye `nohup script.sh &` ile çalıştırmak "amatörce"dir. Süreç yönetilemez, öldürülemez, logları karışır.

### Çözüm: Systemd Service (Type=simple)

Eğer bir bot veya sürekli çalışan bir scriptiniz varsa, onu daima Systemd servisi yapın.

[Rehber: Kendi Systemd Servisini Yaz](../how-to/systemd-service.md)

## 3. Loglama Yönetimi

Script çıktılarını (`stdout`) yönetmek önemlidir.

### Kötü Yöntem

```bash
./script.sh >> /var/log/app.log 2>&1
```

Bu dosya sonsuza kadar büyür ve diski doldurur (**Disk Full** vakalarının 1 numaralı sebebidir).

### İyi Yöntem (Logrotate veya Journald)

Systemd ile çalıştırırsanız, çıktılar otomatik olarak `journalctl` tarafından yönetilir ve sıkıştırılır.

Logları izlemek için:

```bash
journalctl -u myscript.service -f
```

# Guvenlik Guncellemeleri

Bu bolum, otomatik guvenlik guncellemelerini etkinlestirir.

## Gereksinimler

- Root veya sudo yetkisi

## Kurulum

```bash
apt update
apt install -y unattended-upgrades
```

## Konfigurasyon

## Konfigürasyon

Ana yapılandırma dosyası: `/etc/apt/apt.conf.d/50unattended-upgrades`.

Dosyayı açın ve aşağıdaki satırların başındaki `//` yorum işaretlerini kaldırarak düzenleyin:

```javascript
/* KRITİK: Sadece güvenlik güncellemelerini al */
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    // "${distro_id}:${distro_codename}-updates"; // Opsiyonel: Normal güncellemeler
};

/* E-posta bildirimi (mailx veya postfix kuruluysa) */
Unattended-Upgrade::Mail "admin@example.com";
Unattended-Upgrade::MailReport "on-change"; // Sadece değişiklik olunca yaz

/* Gereksiz kernel ve paketleri temizle */
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";

/* Otomatik Yeniden Başlatma (Production İçin Kritik) */
/* Kernel güncellemesi gelirse sunucuyu gece 04:00'te yeniden başlat */
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
```

Aktifleştirmek için öncelik ayarını yapın:

```bash
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

## Bakim notlari

- Ayda bir planli guncelleme penceresi belirle.
- Kritik yamalar icin acil prosedur tanimla.
- Eski paketleri periyodik temizle:

```bash
apt autoremove -y
```

## Dogrulama

- `/etc/apt/apt.conf.d/20auto-upgrades` dosyasi olustu mu?
- Guncelleme zamanlayicisi aktif mi?

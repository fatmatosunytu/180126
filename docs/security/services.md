# Gereksiz Servislerin Temizliği

Bulut sunucuları (VPS/Cloud) genellikle "headless" (monitörsüz) çalışır. Ancak Ubuntu imajları bazen masaüstü veya fiziksel laptoplarda kullanılan servislerle yüklü gelebilir. Bu servisleri kapatmak hem RAM kazandırır hem de saldırı yüzeyini küçültür.

> [!NOTE]
> Bu öneriler "Generic Cloud Server" (VPS) içindir. Fiziksel bir sunucu (Bare Metal) veya masaüstü kullanıyorsanız dikkatli olun.

## 1. ModemManager

LTE/3G modemleri yönetmek içindir. Sunucunuzda SIM kart takılı değilse (ki %99.99 değildir) kesinlikle gereksizdir.

```bash
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
```

## 2. Disk Yönetimi (udisks2)

GNOME disk utility ve diğer masaüstü araçları için arka planda çalışır. Headless sunucuda gereksizdir.

```bash
sudo systemctl stop udisks2
sudo systemctl disable udisks2
```

## 3. Firmware Update (fwupd)

Donanım firmware güncellemelerini yönetir. Cloud ortamında firmware hypervisor tarafından yönetildiği için genellikle işlevsizdir veya gereksiz kaynak tüketir.

```bash
sudo systemctl stop fwupd
sudo systemctl disable fwupd
```

## 4. RPC Bind (rpcbind)

Eğer **NFS** (Network File System) kullanmıyorsanız (yani başka bir sunucudan klasör bağlamıyorsanız), `rpcbind` servisine ihtiyacınız yoktur. Port tarayıcıların sevdiği bir servistir.

> [!WARNING] > **Oracle Cloud Agent** veya bazı cloud-init servisleri nadiren buna ihtiyaç duyabilir. Kapatmadan önce sistem loglarını kontrol edin veya test ortamında deneyin.

```bash
sudo systemctl stop rpcbind
sudo systemctl disable rpcbind
# Soketi de kapatmak gerekebilir:
sudo systemctl stop rpcbind.socket
sudo systemctl disable rpcbind.socket
```

## 5. Bluetooth

Sanal sunucuda Bluetooth donanımı yoktur. Varsa kapatın:

```bash
sudo systemctl stop bluetooth
sudo systemctl disable bluetooth
```

## Toplu Kontrol

Hangi servisler aktif ve başarısız (failed) durumda görmek için:

```bash
systemctl list-units --type=service --state=running
systemctl list-units --type=service --state=failed
```

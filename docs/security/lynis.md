# Lynis

Lynis, sunucuda hizli bir guvenlik denetimi yapip pratik iyilestirme onerileri veren hafif bir arac. Zorunlu degil; temel amac, guvenlik hijyenini hizli bir sekilde gorunur yapmak ve eksikleri takip etmek.

## Ne zaman kullanilir?

- Yeni kurulumdan sonra temel guvenlik durumunu gormek icin.
- Periyodik saglik kontrolu yapmak icin.
- Hardening backlog'u cikarmak icin.

## Alternatif var mi?

- **CIS-CAT / OpenSCAP**: Daha formal, politika tabanli denetim (kurumsal ortamlarda tercih edilebilir).
- **osquery + kural setleri**: Surekli gorme ve sorgulama icin.
- **Lynis**: En hizli ve hafif baslangic, rapor okumasi kolay.

Kisa karsilastirma:

- **CIS-CAT**: CIS benchmark uyumlulugu raporlamak isteyen ekipler icin.
- **OpenSCAP**: Regulator/uyumluluk odakli ortamlarda (STIG, CIS profilleri).
- **Lynis**: Hizli, hafif, tek sunucu veya kucuk filolar icin pratik.

## OS farkliliklari (Ubuntu/Debian vs CentOS/RHEL)

- Lynis ayni sekilde calisir; fark paket yoneticisidir.
- Log/rapor dosyalari varsayilan olarak yine `/var/log/` altinda olur.

## Varsayimlar ve gereksinimler

- `sudo` yetkisi.
- Uretimde degisiklik yapmadan once staging/test ortami.

## Kurulum

Ubuntu/Debian:

```bash
apt update
apt install -y lynis
```

CentOS/RHEL:

```bash
yum install -y lynis
# veya
dnf install -y lynis
```

## Tarama

Raporun nereye kaydedileceğini kesinleştirmek için `--report-file` parametresini kullanmak en iyisidir:

```bash
sudo lynis audit system --report-file /var/log/lynis-report.dat
```

Eğer sadece rapor üretilsin, ekrana bir şey basmasın istiyorsanız:

```bash
sudo lynis audit system --quiet --report-file /var/log/lynis-report.dat
```

> [!NOTE] > **Uyarılar Hakkında:**
>
> - `Test CRYP-7902 had a long execution`: Genelde önemsizdir, şifreleme testleri yavaş çalışabilir.
> - `pgrep: pattern ... too long`: Lynis'in bazı süreçleri kontrol ederken kullandığı komutun yan etkisidir, genellikle yoksayılabilir.
> - `--quiet` modu sonuç özeti (footer) basmaz, bu yüzden raporun nerede olduğunu yazmaz. O yüzden `--report-file` ile yolu siz belirleyin.

## Yaygin parametreler (istege bagli)

```bash
sudo lynis audit system --verbose
sudo lynis audit system --no-colors
sudo lynis audit system --pentest
```

- `--quiet`: Sessiz cikti (Rapor konumu ekranda yazmaz!).
- `--verbose`: Daha fazla detay.
- `--no-colors`: Renkli cikti kapatir.
- `--pentest`: Pentest odakli ipuclari.
- `--forensics`: Canli veya mount edilmis sistemde forensics modu.

## Raporlama ve bulgu takibi

!!! tip "Hizli ozet (tek komut)"
`bash
    sudo awk -F= '
      $1=="hardening_index" {hi=$2}
      $1=="score" {score=$2}
      $1 ~ /^warning\[/ {w++}
      $1 ~ /^suggestion\[/ {s++}
      END {printf "hardening_index=%s\nscore=%s\nwarnings=%d\nsuggestions=%d\n", hi, score, w, s}
    ' /var/log/lynis-report.dat
    ` - `hardening_index`: Sertlestirme seviyesi (0-100). - `score`: Genel puan (surume gore bos gelebilir). - `warnings`: Kritik/uyari sayisi. - `suggestions`: Iyilestirme onerisi sayisi.

- Log ve rapor dosyalari:
  ```bash
  sudo tail -n 200 /var/log/lynis.log
  sudo tail -n 200 /var/log/lynis-report.dat
  ```
- Rapor dosyasindan ozet anahtarlar:
  ```bash
  sudo grep -E "hardening_index|score" /var/log/lynis-report.dat
  ```
- Uyari ve oneriler:
  ```bash
  sudo grep -E "warning\\[|suggestion\\[" /var/log/lynis-report.dat
  ```
- Tam tarama ciktisi ekranda listelenir; ozet bolumu en altta gorunur.

!!! note
Lynis surumlerine gore komutlar degisebilir. `lynis report show` gibi komutlar her surumde yoktur. Suphe durumunda `lynis show` ve `man lynis` ile desteklenen komutlari kontrol et, rapor icin `/var/log/lynis-report.dat` dosyasini kullan.

## Rapor dosyasi bulunamadiysa

Lynis varsayilan olarak raporu `/var/log/lynis-report.dat` dosyasina yazar. Dosya bulunamiyorsa, tarama `sudo` ile calismamis veya rapor baska dizine yazilmis olabilir.

- Dosya adini bulmak icin `find` kullanmak daha dogru; `grep` icerik arar.
  ```bash
  sudo find / -name "lynis-report.dat" 2>/dev/null
  ```
- `locate` kuruluysa daha hizlidir:
  ```bash
  sudo updatedb
  locate lynis-report.dat
  ```
  - Ubuntu/Debian: `sudo apt install -y plocate` (veya `mlocate`)
  - CentOS/RHEL: `sudo yum install -y mlocate`
- Son taramayi root olarak calistir:
  ```bash
  sudo lynis audit system
  ```
- Rapor kullanici ev dizinindeyse:
  ```bash
  sudo grep -E "hardening_index|score" /home/ubuntu/lynis-report.dat
  ```

!!! warning
`--no-log` kullanirsan rapor dosyasi uretilmez. Rapor konumu, `sudo` ile calistirma ve Lynis surumune gore degisebilir.

## Oneriler ve uygulama

- Onerileri etki analizinden sonra planla (risk, geri donus, sahiplik).
- Kritik degisiklikleri kontrollu pencerede uygula.

!!! warning
Guvenlik sertlestirme onerileri servis kesintisine veya SSH erisim kaybina neden olabilir. Degisiklikleri once staging ortaminda dene, erisim yedegi (out-of-band/console) planla.

## Periyodik tarama (opsiyonel)

- Aylik tarama icin basit bir cron:
  ```bash
  sudo sh -c 'echo "0 2 1 * * root /usr/bin/lynis audit system --quiet" > /etc/cron.d/lynis-audit'
  ```

## Dogrulama

- Kritik bulgular listelendi mi?
- Uygulanan oneriler dokumante edildi mi?
- Onceki raporla karsilastirma yapildi mi?

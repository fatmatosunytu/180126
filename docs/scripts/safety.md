# Script Güvenliği

Otomasyon harikadır, ancak güvensiz bir script sunucuyu saldırganlara altın tepside sunabilir.

## 1. Sırlar ve Şifreler (Secrets)

❌ **ASLA YAPMA:**
Scriptin içine şifre gömmek. Script git reposuna giderse şifreniz de gider.

```bash
DB_PASSWORD="cokgizlisifre" # YANLIŞ!
```

✅ **DOĞRUSU:**
Şifreleri `.env` dosyasından veya ortam değişkenlerinden okuyun.

```bash
# Script başı
if [ -f .env ]; then
    source .env
fi

if [ -z "${DB_PASSWORD:-}" ]; then
    echo "Hata: DB_PASSWORD ayarlanmamış!"
    exit 1
fi
```

`.env` dosyasını `.gitignore`'a eklemeyi unutmayın!

## 2. Curl | Bash Tehlikesi

İnternetten bulduğunuz scriptleri direkt pipe ederek çalıştırmayın:

```bash
curl http://bilinmeyen-site.com/setup.sh | bash
```

**Risk:** Bağlantı kesilirse script yarım inip çalışabilir veya sunucu tarafında içerik değiştirilebilir.

**Güvenli Yöntem:**

1. İndir (`curl -O ...`)
2. Oku/İncele (`cat script.sh`)
3. Çalıştır (`bash script.sh`)

## 3. Checksum Doğrulama

Kritik bir araç indiriyorsanız (örn: Docker, kubectl), indirdiğiniz dosyanın bütünlüğünü doğrulayın:

```bash
echo "b85f... beklenen_hash  dosya.tar.gz" | sha256sum --check
```

## 4. En Az Yetki Prensibi (Least Privilege)

Her scripti `root` olarak çalıştırmak zorunda değilsiniz.

- Web sunucusu işlemleri için `www-data`.
- Yedekleme için `backup-user`.
- Uygulama için `deployer`.

Script başında `sudo` gerekliyse kontrol edin:

```bash
if [[ $EUID -ne 0 ]]; then
   echo "Bu script root yetkisi gerektirir."
   exit 1
fi
```

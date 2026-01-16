# Script Yazım Standartları

Prodüksiyon ortamında çalışacak bir script, "çalışıp işini yapması" kadar "hata anında düzgün patlaması" ile de ölçülür.

## 1. Altın Kural: Bash Strict Mode

Her Bash scriptinizin ilk satırı (shebang'den sonra) mutlaka şu olmalı:

```bash
#!/bin/bash
set -euo pipefail
```

### Bu ne işe yarar?

- **`set -e` (Exit on Error):** Bir komut hata verirse (exit code != 0), script çalışmaya devam etmez, **anında durur**.
  - _İstisna:_ `mkdir dosya || true` gibi hatayı bilerek yönettiğiniz yerler.
- **`set -u` (Unset Variables):** Tanımlanmamış bir değişken kullanırsanız hata verir. (`rm -rf /$BILINMEYEN_DEGISKEN` faciasını önler).
- **`set -o pipefail`:** Boru hattında (`cmd1 | cmd2`) biri hata verirse tüm işlemi hatalı sayar. Varsayılan davranışta sadece `cmd2` başarısız olursa hata dönerdi.

## 2. Değişken İsimlendirme

- **BÜYÜK_HARF:** Sadece `export` edilen ortam değişkenleri (Environment Variables) ve sabitler (Constants) için.
- **küçük_harf:** Script içi yerel değişkenler için.

```bash
# Doğru
DATABASE_URL="postgres://..."
backup_dir="/tmp/backups"

# Yanlış
BACKUPDIR="/tmp" # Sistem değişkeni sanılabilir
```

## 3. Loglama ve Fonksiyonlar

Her şeyi `echo` ile yazdırmayın. Okunabilir log fonksiyonları kullanın:

```bash
log_info() { echo -e "[\033[34mINFO\033[0m] $1"; }
log_success() { echo -e "[\033[32mOK\033[0m] $1"; }
log_error() { echo -e "[\033[31mERROR\033[0m] $1" >&2; }

# Kullanım
log_info "Yedekleme başlıyor..."
```

## 4. Linting (Kod Denetimi)

Scriptlerinizi commit etmeden önce mutlaka **ShellCheck** ile tarayın. VS Code eklentisi mevcuttur.

```bash
# MacOS Kurulumu
brew install shellcheck

# Kontrol
shellcheck my-script.sh
```

## 5. Şablon (Boilerplate)

Yeni bir script yazarken bu şablonu kopyalayın:

```bash
#!/bin/bash
set -euo pipefail

# --- Konfigürasyon ---
readonly WORK_DIR="/opt/app"
readonly NOW=$(date +%Y%m%d_%H%M%S)

# --- Yardım ---
usage() {
    echo "Kullanım: $0 [options]"
    exit 1
}

# --- Ana Akış ---
main() {
    if [[ $EUID -ne 0 ]]; then
       echo "Bu script root olarak çalıştırılmalıdır."
       exit 1
    fi

    echo "İşlem başladı: $NOW"
    # Kodlar buraya...
}

main "$@"
```

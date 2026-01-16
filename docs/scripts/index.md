# Script Repository & Otomasyon Standartları

Bu bölüm, sunucu yönetiminde kullandığımız scriptlerin (`.sh`, `.py`) nasıl yazılması, çalıştırılması ve korunması gerektiğini anlatan anayasamızdır.

## 1. Yazım Kuralları (Conventions)

[Script Yazım Standartları](conventions.md) sayfasında:

- **Bash Strict Mode** (`set -euo pipefail`) neden zorunludur?
- Değişken isimlendirme ve loglama formatları.
- Kopyala-yapıştır yapabileceğiniz **hazır şablon (boilerplate)**.

## 2. Çalıştırma Yöntemleri (Execution)

[Script Çalıştırma Standartları](execution.md) sayfasında:

- Neden **Cron** yerine **Systemd Timers** kullanmalıyız?
- Arkaplan işlemleri ve log yönetimi.

## 3. Güvenlik (Safety)

[Script Güvenliği](safety.md) sayfasında:

- Şifre yönetimi (`.env` vs Hardcoded).
- `curl | bash` riskleri.
- **Least Privilege** (En az yetki) kuralı.

## 4. Otomasyon Vizyonu

[Otomasyon Vizyonu](automation.md) sayfasında:

- Terraform vs Ansible karşılaştırması.
- Gelecekteki "Server Setup as a Service" mimarisi.

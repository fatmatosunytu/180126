# Sunucu Güvenliği (Hardening)

Bu bölüm, sunucunuzu "Production Ready" hale getirmek için uygulamanız gereken **Derinlemesine Savunma (Defense in Depth)** stratejisini anlatır.

Güvenlik tek bir ayar değildir; saldırganı her adımda yavaşlatan bir **katmanlar bütünüdür**.

## Güvenlik Mimarisi

Aşağıdaki tablo, bu rehberde uyguladığımız güvenlik katmanlarını özetler:

| Katman                     | Rehber                           | Amaç                                                               |
| :------------------------- | :------------------------------- | :----------------------------------------------------------------- |
| **1. Ağ & Firewall**       | [Firewall (UFW)](firewall.md)    | Kapıları kilitlemek. Giriş/Çıkış trafiğini denetlemek.             |
| **2. Erişim**              | [SSH Hardening](ssh.md)          | Anahtarı saklamak. Port değiştirmek, şifreyi kapatmak.             |
| **3. Saldırı Engelleme**   | [Fail2ban](fail2ban.md)          | Bekçi dikmek. Zorlayanları (brute-force) otomatik banlamak.        |
| **4. Sistem Sıkılaştırma** | [Kernel (Sysctl)](sysctl.md)     | Çekirdeği sertleştirmek. Network stack saldırılarını önlemek.      |
| **5. Temizlik**            | [Servis Yönetimi](services.md)   | Fazlalıkları atmak. Gereksiz servisleri (ModemManager vb.) silmek. |
| **6. Süreklilik**          | [Oto. Güncellemeler](updates.md) | Aşılanmak. Güvenlik yamalarını beklemeden almak.                   |
| **7. Aktif Savunma**       | [Hacker Tuzaklama](tarpit.md)    | **(Opsiyonel)** Tuzak kurmak. Saldırganı oyalamak (Tarpit).        |
| **8. Denetim**             | [Lynis Audit](lynis.md)          | Check-up. Eksikleri raporlamak.                                    |

## Uygulama Sırası

Sıfırdan bir sunucu kuruyorsanız şu sırayı takip edin:

1.  **Güncelle:** [Otomatik Güncellemeler](updates.md) ile sistemi kendi kendini yamalayan hale getirin.
2.  **Temizle:** [Servis Temizliği](services.md) ve [Kernel Hardening](sysctl.md) ile zemini sağlamlaştırın.
3.  **Kilitle:** [SSH Güvenliği](ssh.md) ve [Firewall (UFW)](firewall.md) ile kapıları kapatın (Sıraya dikkat!).
4.  **Koru:** [Fail2ban](fail2ban.md) ile aktif korumayı başlatın.
5.  **Eğlen:** İsterseniz [Hacker Tuzaklama](tarpit.md) ile port 22'ye tuzak kurun.
6.  **Kontrol Et:** En son [Lynis](lynis.md) ile tarama yapıp puanınızı görün.

# Sunucu Güvenliği (Hardening) 🛡️

Tebrikler! Bu rehberdeki adımları tamamladıysanız, sunucunuz artık sıradan bir Linux kutusu değil, **Katmanlı Savunma (Defense in Depth)** ile korunan bir kaledir.

Aşağıdaki liste, uyguladığımız tüm güvenlik katmanlarının özetidir.

## 🧱 15 Katmanlı Güvenlik Mimarisi

| #      | Katman            | Rehber                                            | Amaç                                                              |
| :----- | :---------------- | :------------------------------------------------ | :---------------------------------------------------------------- |
| **1**  | **Temel Hijyen**  | [Servis Temizliği](services.md)                   | Gereksiz servisleri sil, saldırı yüzeyini küçült.                 |
| **2**  | **Süreklilik**    | [Oto. Güncellemeler](updates.md)                  | Yazılımları (ve Kernel'i) güvenlik açıklarına karşı yamala.       |
| **3**  | **Çekirdek**      | [Kernel (Sysctl)](sysctl.md)                      | Network stack (IPv6, ICMP, TCP) saldırılarını engelle.            |
| **4**  | **Erişim**        | [SSH Hardening](ssh.md)                           | Portu değiştir, Root girişini kapat, Anahtar kullan.              |
| **5**  | **Kimlik**        | [SSH 2FA](2fa.md)                                 | Anahtar çalınsa bile telefon onayı iste (Google Auth).            |
| **6**  | **Duvar**         | [Firewall (UFW)](firewall.md)                     | Sadece gereken portları aç, **çıkış trafiğini (egress)** kısıtla. |
| **7**  | **Aktif Koruma**  | [CrowdSec](crowdsec.md) / [Fail2ban](fail2ban.md) | Brute-force deneyenleri otomatik banla.                           |
| **8**  | **Dosya Sistemi** | [Tmp Hardening](tmp-hardening.md)                 | `/tmp` klasöründe script çalıştırılmasını (`noexec`) engelle.     |
| **9**  | **Bütünlük**      | [FIM (AIDE)](fim.md)                              | "Biri sistem dosyalarını değiştirdi mi?" kontrolü yap.            |
| **10** | **Kısıtlama**     | [Derleyici Kısıtlama](compilers.md)               | Sunucuda `gcc`, `make` gibi derleyicileri yasakla.                |
| **11** | **Kaynak**        | [Resource Limits](resource-limits.md)             | CPU/RAM limiti koy (Crypto Miner'ları boğ).                       |
| **12** | **Sırlar**        | [Secret Yönetimi](secrets.md)                     | Şifreleri koda gömme; `.env`, Vault veya Docker Secrets kullan.   |
| **13** | **Konteyner**     | [Docker Güvenliği](docker.md)                     | Non-root, Read-only FS, UserNS ile konteynerleri izole et.        |
| **14** | **Gözetleme**     | [Monitoring](monitoring.md)                       | CPU, Disk, Ağ anomalileri için alarm kur.                         |
| **15** | **Malware**       | [Antivirüs](malware.md)                           | ClamAV ve Rkhunter ile zararlı taraması yap.                      |

---

## 🚀 Uygulama Sırası (Roadmap)

Sıfırdan kuruluma başladıysanız bu sırayı takip edin:

### Aşama 1: Temel (İlk Kurulum)

1.  [Servisleri Temizle](services.md)
2.  [Güncellemeleri Aç](updates.md)
3.  [SSH Ayarla](ssh.md)
4.  [Firewall Aç](firewall.md)

### Aşama 2: Sıkılaştırma (Hardening)

5.  [Kernel Ayarları](sysctl.md)
6.  [Fail2ban/Crowdsec Kur](crowdsec.md)
7.  [/tmp Hardening](tmp-hardening.md)
8.  [Derleyicileri Kısıtla](compilers.md)

### Aşama 3: İleri Seviye (Paranoya Modu)

9.  [SSH 2FA Ekle](2fa.md)
10. [Docker Hardening Uygula](docker.md)
11. [Monitoring Scriptlerini Kur](monitoring.md)
12. [Her Şeyi Tara (Lynis)](lynis.md)

---

## Hangisini Seçmeliyim: CrowdSec mi Fail2ban mi?

| Kriter        | [Fail2ban](fail2ban.md) 🐍           | [CrowdSec](crowdsec.md) 🐹                                   |
| :------------ | :----------------------------------- | :----------------------------------------------------------- |
| **Teknoloji** | Python (Eski, Güvenilir)             | Go (Modern, Bulut Tabanlı)                                   |
| **Koruma**    | **Reaktif:** Size saldırırsa banlar. | **Proaktif:** Dünyada birine saldıranı size gelmeden banlar. |
| **Öneri**     | 512MB RAM altı sunucular için.       | Modern, 1GB+ RAM sunucular için (**Önerilen**).              |

> [!TIP]
> Güvenlik bir varış noktası değil, yolculuktur. Haftalık [Lynis](lynis.md) taramalarınızı aksatmayın!

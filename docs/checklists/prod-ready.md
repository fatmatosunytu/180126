# Go / No-Go Decision Matrix 🚦

Canlıya çıkış (Go-Live) bir histen ibaret olamaz. Aşağıdaki matris tamamlanmadan **TRAFİK YÖNLENDİRİLEMEZ**.

## 🔴 Blocker (Kesin Engel)

Bu maddelerden **bir tanesi bile** eksikse, deployment iptal edilir.

- [ ] **Data Security:** Veritabanı şifreleri environment variable (env) olarak DEĞİL, Secret File olarak mount edilmiş mi?
- [ ] **Firewall:** `ufw status` -> Sadece 80/443/SSH açık. Docker portları (5432, 6379) dışarı kapalı mı?
- [ ] **Backup:** Dün geceki yedeği geri dönebiliyor muyuz? (Restore Test yapıldı mı?)
- [ ] **SSL:** Sertifika geçerli ve auto-renew (Certbot) aktif mi?
- [ ] **Non-Root:** Uygulama container içinde `root` olarak MI çalışıyor? (Fail. `USER` direktifi şart.)

## 🟡 Warning (Riskli Geçiş)

Bu maddeler eksikse Manager onayı ile geçilebilir ama 24 saat içinde düzeltilmelidir.

- [ ] **Monitoring:** CPU/RAM > %80 olursa Slack'e bildirim geliyor mu?
- [ ] **Logs:** Loglar rotate ediliyor mu? (Disk dolarsa sunucu durur.)
- [ ] **Performance:** Yük altında (Load Test) P99 Latency < 500ms mi?
- [ ] **Fallbacks:** Veritabanı giderse kullanıcıya "Bakımdayız" sayfası çıkıyor mu, yoksa Crash mi oluyor?

## 🟢 Good to Have (İyileştirme)

- [ ] **CDN:** Statik dosyalar Cloudflare/CDN üzerinden mi geliyor?
- [ ] **CI/CD:** Deploy tek tıkla yapılabiliyor mu?
- [ ] **Docs:** Runbook dokümanları güncel mi?

---

## 📝 Karar

| Durum          | Karar               | İmza/Onay |
| :------------- | :------------------ | :-------- |
| ✅ Tümü Yeşil  | **GO** 🚀           | Mühendis  |
| ⚠️ Sarı Var    | **GO with Risk** 🤞 | Team Lead |
| ❌ Kırmızı Var | **NO-GO** 🛑        | -         |

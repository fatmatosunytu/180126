# 🧬 Biyoinformatikçiler İçin Git ve Docker Rehberi

Bu rehber, laboratuvarda veya sunucuda çalışırken hayat kurtaran iki teknolojiyi; **Git** (Yedekleme/Versiyonlama) ve **Docker** (Paketleme/Çalıştırma) sistemlerini anlatır.

---

## Bölüm 1: Git (Zaman Makinesi) 🕰️
Git, kodlarımızda yaptığımız hataları geri almamızı ve projelerimizi internette (GitHub) saklamamızı sağlar.

### 1.1 Git Clone (Projeyi İndirmek)
Başkasına ait bir çalışmayı bilgisayarımıza indirmek için kullanılır.
**Komut:** `git clone <link>`
**Örnek:** `git clone https://github.com/fatmatosunytu/180126.git`

### 1.2 Git Status (Durum Kontrolü)
Hangi dosyalarda değişiklik yaptığımızı gösterir.
*(Buraya kendi denediğin ekran görüntüsünü veya açıklamanı ekle)*

### 1.3 Git İş Akışı: Değişiklikleri Kaydetmek ve Göndermek
Yaptığımız her değişikliği GitHub'a göndermek için üç aşamalı bir yol izleriz. Bu süreci "hazırlanma, mühürleme ve kargolama" olarak düşünebiliriz.

**Adım 1:** git add . (Hazırlık) Değişiklik yaptığımız tüm dosyaları "takip listesine" ekler. Nokta (.) işareti "her şeyi ekle" demektir.

**Adım 2:** git commit -m "mesajınız" (Mühürleme) Hazırlanan değişikliklere bir isim vererek dondurur. Mesaj kısmına ne yaptığınızı (örn: "hata düzeltildi") yazmalısınız.

**Adım 3:** git push (Kargolama) Kendi bilgisayarınızda dondurduğunuz bu paketleri internetteki (GitHub) sunucuya fırlatır.

---

## Bölüm 2: Docker (Sanal Laboratuvar) 🐳
Biyoinformatik araçlarını (Blast, Gromacs vb.) kurmak zordur. Docker, bu araçları "Konteyner" içinde hazır paket olarak getirir. Kurulum derdini bitirir.

### 2.1 Neden Kullanmalıyız?
* "Benim bilgisayarımda çalışıyordu" sorununu çözer.
* Versiyon çakışmalarını önler.

### 2.2 İlk Docker Denemesi
Docker kurulumunu hello-world imajını çalıştırarak doğruladım. Kurulum sürecinde BIOS sanallaştırma hatası, WSL kilitlenmesi ve Docker Hub kimlik doğrulama adımlarını başarıyla geçtim. Sistem şu an biyoinformatik konteynerlerini çalıştırmaya tamamen hazır.

## Bölüm 3: Gerçek Dünya Uygulaması: BLAST
Biyoinformatik araçlarını geleneksel yöntemlerle kurmak zaman kaybıdır. Docker ile NCBI BLAST aracını tek komutla ayağa kaldırdım:

docker pull ncbi/blast ile resmi imajı sisteme dahil ettim.

docker run --rm ncbi/blast blastn -version komutuyla kurulumsuz analiz yeteneğini doğruladım.
# Oracle Cloud Genel Bakış

Oracle Cloud Infrastructure (OCI), sunduğu cömert "Free Tier" (Ücretsiz Katman) ile kişisel sunucu barındırmak için mükemmel bir seçenektir.

## Neden Oracle Cloud?

- **ARM İşlemciler (Ampere):** 4 OCPU ve 24 GB RAM'e kadar tamamen ücretsiz sunucu (VM.Standard.A1.Flex).
- **Public IPv4:** Ücretsiz statik IP sağlar (Reserved IP).
- **Disk:** 200 GB'a kadar Block Volume saklama alanı ücretsizdir.

## Hesap Kurulum İpuçları

1.  **Bölge (Region) Seçimi:** Hesabı açarken seçtiğiniz "Home Region" (örn: Frankfurt, Amsterdam) kalıcıdır ve değiştirilemez. Türkiye'ye yakın bir bölge (Frankfurt) seçmek latency (gecikme) açısından iyidir.
2.  **Kart Doğrulama:** Kayıt sırasında kredi kartından provizyon çekilir ve iade edilir. Sanal kartlar bazen sorun çıkarabilir.
3.  **SSH Key:** Sunucu oluştururken mutlaka **kendi oluşturduğunuz** SSH Public Key'i (`id_ed25519.pub`) yükleyin. Oracle'ın oluşturduğu anahtarları indirmek yerine kendi anahtarınızı kullanmak daha güvenlidir.

## Servis Yapısı

Bu rehberde Oracle Cloud servislerini şu başlıklar altında inceleyeceğiz:

- [Network (VCN)](network.md): Ağ, Firewall ve IP ayarları.
- [CLI (Komut Satırı)](cli.md): Web panele girmeden yönetim.

# Disk ve Kaynak Yönetimi

"Disk doldu" veya "RAM bitti" durumlarında ilk bakılacak komutlar.

## 1. Disk Kullanımı

Disk neden doldu?

```bash
# Genel disk durumu (Human readable)
df -h
# Çıktıda 'Use%' sütunu %90 üzerindeyse alarm!

# Hangi klasör ne kadar yer kaplıyor?
du -sh *
# Bulunduğunuz dizindeki dosyaların boyutunu özetler.

# En büyük 10 klasörü bul (Sihirli komut)
du -ahx . | sort -rh | head -10
```

## 2. RAM (Bellek) Durumu

```bash
# RAM kullanımı (Megabyte cinsinden)
free -m

# Detaylı bellek özeti (Cache vs görmek için)
# 'available' sütunu önemlidir. 'free' az görünebilir (Linux cache sever).
```

## 3. CPU ve Yük Durumu

```bash
# Anlık sistem izleme (Görev yöneticisi)
htop
# (Yoksa: apt install htop)

# Sistem yük ortalaması (1, 5, 15 dk)
uptime
# Sondaki 3 sayı, işlemci çekirdek sayısını geçmemeli.
```

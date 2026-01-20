#!/bin/bash
# Süleyman'ın Fabrika Hattı: Toplu BLAST Analizi

echo "--- Biyoinformatik Fabrikasi Calisiyor ---"

# Klasördeki 'btd_' ile başlayan tüm .fasta dosyalarını bul ve dön
for dosya in btd_*.fasta; do
    echo "Su an analiz edilen dosya: $dosya"
    
    # Docker penceresini aç ve analizi yap
    MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd)":/data ncbi/blast \
    blastn -query "/data/$dosya" -subject /data/subject.fasta -out "/data/sonuc_$dosya.txt"
    
    echo "$dosya icin analiz tamamlandi. Rapor: sonuc_$dosya.txt"
done

echo "--- Tum işlemler bitti! ---"
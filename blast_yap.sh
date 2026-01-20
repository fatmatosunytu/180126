#!/bin/bash
# Süleyman'ın Ödevi: BLAST Otomasyon Scripti

echo "--- BLAST Analizi Baslatiliyor ---"

# 1. Dosya yollarını Windows/Docker uyumlu hale getirerek çalıştır
MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd)":/data ncbi/blast \
blastn -query /data/query.fasta -subject /data/subject.fasta -task blastn-short -out /data/otomatik_rapor.txt

echo "--- Analiz Bitti! Sonuç 'otomatik_rapor.txt' dosyasına kaydedildi. ---"
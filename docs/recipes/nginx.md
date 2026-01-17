# Nginx Reverse Proxy Hardening 🌐

Bu, uygulamalarınızın (React, .NET) önünde duran, internete açılan **Ana Kapı**dır. En çok saldırı buraya gelir.

## 1. Altın Konfigürasyon (`nginx.conf`) 🏆

Aşağıdaki ayarlar DDoS koruması, SSL güvenliği ve Header sıkılaştırmasını içerir.

```nginx
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # --- GÜVENLİK AYARLARI ---

    # 1. Versiyon gizleme (Saldırgan sürümü bilmesin)
    server_tokens off;

    # 2. Buffer Overflow Koruması
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 2 1k;

    # 3. Timeout Ayarları (Slowloris saldırısı koruması)
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;

    # 4. Gzip (Veri sızmasını önlemek için BREACH attack'a dikkat, kapalı olabilir)
    gzip off;

    # 5. Header Hardening (Browser Güvenliği)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # 6. SSL Hardening (A+ Puan için)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

    include /etc/nginx/conf.d/*.conf;
}
```

## 2. Docker Compose Kurulumu

Nginx'i de root çalıştırmamak mümkündür ancak ana portları (80/443) dinleyeceği için genellikle gateway olarak root başlar, sonra user düşer (`user nginx` ayarı ile).

```yaml
services:
  proxy:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf.d:/etc/nginx/conf.d:ro
      - ./certs:/etc/nginx/certs:ro
    ports:
      - "80:80"
      - "443:443"
    networks:
      - frontend

    # Kaynak limiti (DDoS anında sunucuyu vermemek için)
    deploy:
      resources:
        limits:
          cpus: "0.50"
          memory: 256M

    # Auto-restart (Çökerse kalksın)
    restart: always
```

## 3. Rate Limiting (DDoS Frenleme) 🛑

Belirli bir IP'den çok fazla istek gelirse engellemek için `conf.d/app.conf` içine ekleyin:

```nginx
# IP başına saniyede max 10 istek (10MB hafıza ayır)
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;

server {
    location / {
        # Limiti uygula (Burst 20 isteğe kadar izin ver, sonra reddet)
        limit_req zone=mylimit burst=20 nodelay;

        proxy_pass http://my-app:8080;
    }
}
```

Bu ayar, botnet saldırılarını Nginx seviyesinde keser, uygulamanıza yük bindirmez.

# React & Nginx Docker Hardening ⚛️

React/Vue/Angular gibi SPA (Single Page Application) projelerini sunmak için Nginx kullanırız. Ancak standart Nginx imajı `root` çalışır. Bunu güvenli hale getirelim.

## 1. Güvenli Nginx Konfigürasyonu (`nginx.conf`) ⚙️

Önce projenizin kök dizinine `nginx.conf` dosyasını oluşturun. Bu ayarlar güvenliği artırır.

```nginx
server {
    listen 8080; # Non-root port (80 yerine 8080)
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    # Güvenlik Headerları
    add_header X-Frame-Options "DENY";
    add_header X-CONTENT-TYPE-OPTIONS "nosniff";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # Nginx sürümünü gizle
    server_tokens off;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache ayarları (Opsiyonel)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires 1y;
        add_header Cache-Control "public, no-transform";
    }
}
```

## 2. Multi-Stage Dockerfile 🏗️

```dockerfile
# --- Stage 1: Build (Node.js) ---
FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# --- Stage 2: Serve (Nginx Unprivileged) ---
# Resmi "nginxinc/nginx-unprivileged" imajı root gerektirmez!
FROM nginxinc/nginx-unprivileged:alpine AS production

# Varsayılan user: nginx (UID 101)
# Varsayılan port: 8080

# Kendi config dosyamızı kopyalayalım
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Build aldığımız React dosyalarını kopyalayalım
COPY --from=builder /app/dist /usr/share/nginx/html

# Portu aç (8080)
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
```

## 3. docker-compose.yml Hardening

```yaml
services:
  frontend:
    image: my-react-app
    # Unprivileged image zaten UID 101 ile çalışır
    read_only: true

    # Nginx'in geçici dosyaları için izin ver
    tmpfs:
      - /tmp
      - /var/cache/nginx
      - /var/run

    deploy:
      resources:
        limits:
          cpus: "0.25"
          memory: 128M

    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
```

## Neden "nginx-unprivileged"?

Standart `nginx:alpine` imajı port 80'i dinlemek için `root` yetkisiyle başlar (sonra user değiştirse bile risklidir). `nginxinc/nginx-unprivileged` ise baştan itibaren yetkisiz başlar ve 8080 portunu kullanır. En güvenli yöntem budur.

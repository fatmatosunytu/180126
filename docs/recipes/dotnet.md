# .NET Core Docker Hardening 🔷

Microsoft, .NET 8 ile birlikte konteyner güvenliğinde devrim yaptı. Artık "Chiseled" (yontulmuş) Ubuntu imajları sayesinde, içinde shell (bash/sh) bile olmayan ultra-güvenli image'lar kullanabiliyoruz.

## 1. Önerilen Dockerfile (Chiseled) 🏆

Bu Dockerfile, saldırgan içeri sızsa bile çalıştıracak bir shell bulamaz (`RCE` neredeyse imkansızlaşır).

```dockerfile
# --- Build Stage ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Önce csproj kopyala ve restore yap (Cache avantajı)
COPY ["MyApp.csproj", "./"]
RUN dotnet restore "MyApp.csproj"

# Kalan dosyaları kopyala ve build al
COPY . .
RUN dotnet publish "MyApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- Final Stage (Chiseled Ubuntu) ---
# "jammy-chiseled" etiketi = Shell yok, Package Manager yok, Root yok!
FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy-chiseled AS final
WORKDIR /app

# Dosyaları build stage'den al
COPY --from=build /app/publish .

# .NET 8 Chiseled imajları varsayılan olarak "app" (UID 1654) kullanıcısı ile çalışır.
# USER app  <-- Yazmana gerek bile yok, default böyle!

# Non-root port (80 yerine 8080)
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

## 2. Alpine Versiyonu (Alternatif) 🏔️

Eğer Chiseled size uymuyorsa (örneğin debugging için shell lazımsa), Alpine Linux kullanın ama mutlaka `USER` tanımlayın.

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

WORKDIR /app
COPY --from=build /app/publish .

# Alpine'de kullanıcı oluşturmaya gerek yok, "app" zaten var (veya guest)
# Ancak biz garanti olsun diye özel bir user ile çalışalım
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -D appuser

USER appuser
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

## 3. docker-compose.yml Hardening

```yaml
services:
  api:
    image: my-dotnet-api
    # .NET 8 Chiseled için default user zaten non-root'tur.
    # Ancak "read_only" dosya sistemi şart!
    read_only: true

    # .NET'in temp dosyaları için yazılabilir alan lazım
    tmpfs:
      - /tmp

    deploy:
      resources:
        limits:
          cpus: "0.50"
          memory: 256M

    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true
```

## Kıssadan Hisse

- **Chiseled İmaj Kullan:** Saldırgana `bash` verme.
- **Port 8080 Kullan:** Port 80 root yetkisi ister, 8080 istemez.
- **Read-Only Root:** Uygulamanın diske yazmasına izin verme.

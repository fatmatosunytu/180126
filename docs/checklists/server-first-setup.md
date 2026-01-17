# Server Verification Protocol (Day 0) 🛡️

Bir sunucuyu teslim aldığınızda "yaptım oldu" demek yetmez. **Doğrulamak (Verify)** zorundasınız.

## 1. Access & Identity

| Aksiyon       | Komut                                           | Doğrulama (Verify)                                                          |
| :------------ | :---------------------------------------------- | :-------------------------------------------------------------------------- |
| **Update**    | `apt update && apt upgrade -y`                  | `uptime` (Load artışı yok)                                                  |
| **Hostname**  | `hostnamectl set-hostname <name>`               | `hostname` komutu yeni ismi dönmeli.                                        |
| **Sudo User** | `adduser deployer && usermod -aG sudo deployer` | `getent group sudo` çıktısında `deployer` görünmeli.                        |
| **SSH Key**   | (Local) `ssh-copy-id deployer@<IP>`             | `ssh -o PreferredAuthentications=publickey deployer@<IP>` şifresiz girmeli. |

## 2. SSH Hardening (Kritik) 🔒

Dosya: `/etc/ssh/sshd_config`

| Parametre                | Değer  | Neden?                               | Doğrulama                                                                        |
| :----------------------- | :----- | :----------------------------------- | :------------------------------------------------------------------------------- | --------------------------------- |
| `PermitRootLogin`        | `no`   | Root brute-force engellemek için.    | `ssh root@<IP>` -> **Permission denied** dönmeli.                                |
| `PasswordAuthentication` | `no`   | Sadece Key ile giriş.                | `ssh -o PubkeyAuthentication=no deployer@<IP>` -> Hata vermeli, şifre sormamalı. |
| `PermitEmptyPasswords`   | `no`   | Güvenlik.                            | -                                                                                |
| `Port`                   | `2222` | (Opsiyonel) Log kirliliğini azaltır. | `netstat -tulpn                                                                  | grep sshd` yeni portu göstermeli. |

> **Not:** Değişiklikten sonra `sshd -t` (Test Config) yapmadan servisi restart etmeyin!

## 3. Firewall (UFW) 🧱

Kural: **Default Deny Incoming.**

```bash
# Kurulum
apt install ufw
ufw default deny incoming
ufw default allow outgoing

# İzinler
ufw allow ssh  # Veya port 2222
ufw allow 80/tcp
ufw allow 443/tcp

# Aktifleştir
ufw enable
```

**✅ Verify Step:**

```bash
ufw status verbose
# Çıktı: "Status: active" ve "Default: deny (incoming)" OLMALIDIR.
```

## 4. System Hardening ⚙️

| Ayar            | Dosya/Komut                                                         | Verify                                                                |
| :-------------- | :------------------------------------------------------------------ | :-------------------------------------------------------------------- |
| **Timezone**    | `timedatectl set-timezone Europe/Istanbul`                          | `date` komutu doğru saati göstermeli.                                 |
| **Swapiness**   | `/etc/sysctl.conf` -> `vm.swappiness=10`                            | `cat /proc/sys/vm/swappiness` -> 10 olmalı.                           |
| **TCP BBR**     | `net.core.default_qdisc=fq` + `net.ipv4.tcp_congestion_control=bbr` | `sysctl net.ipv4.tcp_congestion_control` -> bbr olmalı.               |
| **Auto Update** | `apt install unattended-upgrades`                                   | `systemctl status unattended-upgrades` -> Active olmalı.              |
| **Fail2Ban**    | `apt install fail2ban`                                              | `fail2ban-client status sshd` -> Hapisteki (Jail) IP'leri göstermeli. |

## 5. Final Smoke Test 🚬

1.  Sunucuya `reboot` atın.
2.  Bilgisayarınızdan `ping` atın (Açıldı mı?).
3.  `ssh deployer@<IP>` ile bağlanın.
4.  `sudo docker ps` çalıştırın (Hata vermemeli).

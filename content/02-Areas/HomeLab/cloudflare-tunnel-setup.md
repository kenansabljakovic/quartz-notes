# Cloudflare Tunnel Setup

Pristup kućnom serveru bez otvaranja portova na routeru, koristeći Cloudflare Tunnel.

## Preduvjeti

- Cloudflare nalog (besplatno na cloudflare.com)
- Domen dodat u Cloudflare (ili kupi jeftin `.xyz` na Cloudflare Registrar za ~1$/god)
- `cloudflared` instaliran na serveru

---

## 1. Instalacija cloudflared

```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
cloudflared --version
```

---

## 2. Login

```bash
cloudflared tunnel login
```

- Otvori URL koji se pojavi u terminalu
- Uloguj se na Cloudflare nalog
- **Klikni na domen** sa liste → Authorize
- Terminal ispisuje: `You have successfully logged in.`
- Cert se čuva u `~/.cloudflared/cert.pem`

---

## 3. Kreiraj tunel

```bash
cloudflared tunnel create moj-tunel
```

Ispisuje UUID tunela — sačuvaj ga, treba ti za config.

---

## 4. Poveži tunel s domenom

```bash
# Za web aplikaciju
cloudflared tunnel route dns moj-tunel app.tvoj-domen.com

# Za SSH pristup (opciono)
cloudflared tunnel route dns moj-tunel ssh.tvoj-domen.com
```

Ovo automatski dodaje CNAME zapise u Cloudflare DNS.

---

## 5. Config fajl

```bash
nano ~/.cloudflared/config.yml
```

```yaml
tunnel: moj-tunel
credentials-file: /home/keon/.cloudflared/<UUID>.json

ingress:
  - hostname: app.tvoj-domen.com
    service: http://localhost:3100
  - hostname: ssh.tvoj-domen.com
    service: ssh://localhost:22
  - service: http_status:404
```

Zamijeni `<UUID>` sa UUID-om iz koraka 3.

---

## 6. Pokretanje tunela

```bash
cloudflared tunnel run moj-tunel
```

Testiraj: otvori `https://app.tvoj-domen.com` u browseru.

---

## 7. Pokretanje kao systemd servis (automatski start)

```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
sudo systemctl status cloudflared
```

---

## 8. Zero Trust zaštita (opciono)

Dodaje login stranicu ispred aplikacije — samo ovlašteni korisnici mogu pristupiti.

1. Idi na **one.dash.cloudflare.com** → **Zero Trust**
2. **Access** → **Applications** → **Add an Application**
3. Odaberi **Self-hosted**
4. Application domain: `app.tvoj-domen.com`
5. **Policies** tab → Add policy:
   - Action: `Allow`
   - Include: Selector = `Emails` → unesi svoj email
6. Save

### Ako OTP email ne stiže

- Provjeri spam folder (pošiljalac: `no-reply@notify.cloudflare.com`)
- Zero Trust → Settings → Authentication → provjeri da je **One-time PIN** dodan kao login metoda
- Probaj drugi email provajder

---

## 9. SSH pristup s radnog računara (bez admin prava)

Za SSH pristup serveru kroz Cloudflare Tunnel s računara na kojem nemaš admin prava.

### Na radnom računaru

Preuzmi `cloudflared.exe` — **ne treba instalacija, samo jedan .exe fajl**:
- Preuzmi `cloudflared-windows-amd64.exe` s GitHub releases
- Preimenuj u `cloudflared.exe`

Pokreni u CMD-u:
```cmd
cloudflared.exe access ssh --hostname ssh.tvoj-domen.com --url localhost:2222
```

### U PuTTY

- Host: `localhost`
- Port: `2222`
- Connection → SSH → Tunnels → **Dynamic** → port `1080` → Add

### Browser proxy

- Firefox: Settings → Network Settings → Manual proxy → SOCKS5 `127.0.0.1:1080`
- Chrome: instaliraj **FoxyProxy** ekstenziju → SOCKS5 `127.0.0.1:1080`

Provjera: otvori `https://whatismyip.com` — treba prikazati IP ovog servera.

---

## 10. Privremeni tunel (bez domena, za testiranje)

```bash
cloudflared tunnel --url http://localhost:3100
```

Daje privremeni URL poput `https://xxx.trycloudflare.com` — bez naloga, bez domena. URL se mijenja pri svakom pokretanju.

---

## Korisne komande

```bash
# Status tunela
sudo systemctl status cloudflared

# Restart
sudo systemctl restart cloudflared

# Logovi
sudo journalctl -u cloudflared -f

# Lista tunela
cloudflared tunnel list

# Brisanje tunela
cloudflared tunnel delete moj-tunel
```

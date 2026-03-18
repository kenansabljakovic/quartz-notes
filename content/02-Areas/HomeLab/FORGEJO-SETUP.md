# Forgejo Self-Hosted Setup — keonsrv (192.168.1.200)

## Kontekst

Self-hosted Git server na homelab računaru sa automatskim CI/CD deploymentom. Push koda na `main` → automatski build i deploy Docker kontejnera na istom serveru.

**Server:** `keonsrv`, `192.168.1.200`, Ubuntu, 6 CPU, 7.5GB RAM
**Već zauzeti portovi:** 3000 (Grafana), 8086 (InfluxDB), itd.
**Forgejo:** port `3001`
**Aplikacije:** deployaju se na slobodne portove (npr. wear-app na `3100`)

---

## Fajlovi

```
/home/keon/forgejo/
├── docker-compose.yml
├── runner-config.yaml
└── SETUP.md
```

---

## 1. docker-compose.yml

```yaml
services:
  forgejo:
    image: codeberg.org/forgejo/forgejo:11
    container_name: forgejo
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - FORGEJO__server__ROOT_URL=http://192.168.1.200:3001
      - FORGEJO__server__SSH_DOMAIN=192.168.1.200
      - FORGEJO__server__SSH_PORT=2222
    restart: unless-stopped
    volumes:
      - forgejo-data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3001:3000"
      - "2222:22"

  runner:
    image: code.forgejo.org/forgejo/runner:6.3.1
    container_name: forgejo-runner
    depends_on:
      forgejo:
        condition: service_started
    environment:
      DOCKER_HOST: tcp://docker-proxy:2375
    volumes:
      - runner-data:/data
      - ./runner-config.yaml:/etc/runner-config.yaml:ro
    command: forgejo-runner daemon --config /etc/runner-config.yaml
    restart: unless-stopped

  docker-proxy:
    image: tecnativa/docker-socket-proxy
    container_name: forgejo-docker-proxy
    environment:
      CONTAINERS: 1
      IMAGES: 1
      NETWORKS: 1
      VOLUMES: 1
      BUILD: 1
      EXEC: 1
      POST: 1
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    restart: unless-stopped

volumes:
  forgejo-data:
  runner-data:
```

**Napomena:** Image je `codeberg.org/forgejo/forgejo:11` — ne `codeberg/forgejo:11` (Docker Hub nema ovaj image).

---

## 2. runner-config.yaml

Generisati default config pa urediti:

```bash
docker run --rm code.forgejo.org/forgejo/runner:6.3.1 forgejo-runner generate-config > /home/keon/forgejo/runner-config.yaml
```

Urediti sljedeće vrijednosti:

```yaml
runner:
  file: /data/.runner    # putanja do registration fajla u volumeu

container:
  network: "forgejo_default"           # da job kontejneri mogu dosegnuti docker-proxy
  docker_host: "tcp://docker-proxy:2375"  # koristiti proxy umjesto socketa
```

---

## 3. Pokretanje

```bash
cd /home/keon/forgejo
docker compose up -d
```

---

## 4. Initial Setup (web UI)

Otvoriti `http://192.168.1.200:3001` i podesiti:

| Polje | Vrijednost |
|---|---|
| Database type | SQLite3 (default) |
| Server domain | `192.168.1.200` (promijeniti iz `localhost`) |
| SSH server port | `2222` |
| HTTP listen port | `3000` (interni, ne dirati) |
| Base URL | `http://192.168.1.200:3001/` (auto-popunjeno) |
| Disable self-registration | ✓ checked |

Obavezno otvoriti **Administrator account settings** i kreirati admin račun (nije obavezno, ali preporučeno — inače prvi registrovani user postaje admin).

Kliknuti **Install Forgejo**.

---

## 5. Registracija Runner-a

Runner se mora registrovati nakon što Forgejo bude pokrenut. Runner kontejner se restartuje dok nema registration fajla — to je normalno.

**Registracija putem privremenog kontejnera** (runner kontejner mora biti stopped ili restarting):

```bash
docker run --rm \
  -v forgejo_runner-data:/data \
  --network forgejo_default \
  code.forgejo.org/forgejo/runner:6.3.1 \
  forgejo-runner register \
  --instance http://forgejo:3000 \
  --token <TOKEN> \
  --name local-runner \
  --labels docker:docker://node:20-bookworm,ubuntu-latest:docker://node:20-bookworm \
  --no-interactive
```

**Gdje dobiti token:**
`http://192.168.1.200:3001/-/admin/runners` → Create new runner → kopiraj token

**Nakon registracije** restartovati runner:

```bash
docker compose restart runner
```

Provjera da runner radi:

```bash
docker compose logs runner --tail=15
# Treba vidjeti: "runner: local-runner ... declared successfully" i "[poller 0] launched"
```

---

## 6. SSH ključ za push s dev mašine

Na dev mašini (kubethink):

```bash
ssh-keygen -t ed25519 -C "keon@kubethink" -N "" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Dodati u Forgejo: `http://192.168.1.200:3001/user/settings/keys` → Add Key

---

## 7. Push postojeće aplikacije

```bash
cd /path/to/my-app

# Ako je branch master, preimenuj u main
git branch -m master main

# Dodaj Forgejo remote
git remote add forgejo ssh://git@192.168.1.200:2222/keon/my-app.git

# Push (--force ako repo nije prazan nakon inicijalizacije na Forgejo)
git push forgejo main --force
```

---

## 8. CI/CD Workflow

Kreirati `.forgejo/workflows/deploy.yml` u svakoj aplikaciji:

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: docker
    env:
      DOCKER_HOST: tcp://docker-proxy:2375
    steps:
      - uses: actions/checkout@v4

      - name: Install Docker CLI
        run: |
          apt-get update -qq
          apt-get install -y -qq ca-certificates curl
          install -m 0755 -d /etc/apt/keyrings
          curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
          echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list
          apt-get update -qq
          apt-get install -y -qq docker-ce-cli

      - name: Build Docker image
        run: docker build --load -t my-app:latest .

      - name: Deploy
        env:
          MY_SECRET: ${{ secrets.MY_SECRET }}
          # ... ostali secreti
        run: |
          docker stop my-app || true
          docker rm my-app || true
          docker run -d --name my-app --restart unless-stopped -p PORT:PORT \
            -e MY_SECRET \
            my-app:latest
```

### Važne napomene za workflow

1. **`DOCKER_HOST: tcp://docker-proxy:2375`** mora biti na nivou `jobs.deploy.env` (ne koraka) da bi i Build i Deploy imali pristup Dockeru.

2. **`docker build --load`** — obavezno, inače buildx ne učita image u daemon.

3. **Secreti sa `$` znakovima** (npr. bcrypt hashevi) — nikad ih ne prosljeđivati direktno kao `-e "VAR=${{ secrets.VAR }}"`. Shell interpretira `$` znakove. Ispravno:
   ```yaml
   - name: Deploy
     env:
       MY_HASH: ${{ secrets.MY_HASH }}  # Forgejo postavlja kao env var
     run: |
       docker run ... -e MY_HASH ...    # -e VAR bez = čita iz okruženja
   ```

4. **Port 3000 je zauzet od Grafane** — koristiti drugi port (npr. `3100`).

5. **`docker-ce-cli`** (iz oficijalne Docker registry) — ne koristiti `docker.io` iz Debian repoa, ta verzija je prestar (v20.10) i nije kompatibilna s Docker daemonom na hostu. Minimalna verzija API-ja na hostu je 1.44.

6. **Stari `docker.io`** instalira se ako koristiš `apt-get install docker.io` bez prethodnog dodavanja Docker oficijalne registry.

---

## 9. Secrets u Forgejo

Repo → Settings → Actions → Secrets → Add Secret

Za wear-app:
- `NEXTAUTH_SECRET`
- `ADMIN_USERNAME`
- `ADMIN_PASSWORD_HASH`
- `INFLUXDB_V2_TOKEN`
- `INFLUXDB_V1_PASSWORD`

---

## 10. Wear-app specifični deploy.yml

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: docker
    env:
      DOCKER_HOST: tcp://docker-proxy:2375
    steps:
      - uses: actions/checkout@v4
      - name: Install Docker CLI
        run: |
          apt-get update -qq
          apt-get install -y -qq ca-certificates curl
          install -m 0755 -d /etc/apt/keyrings
          curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
          echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list
          apt-get update -qq
          apt-get install -y -qq docker-ce-cli
      - name: Build Docker image
        run: docker build --load -t wear-app:latest .
      - name: Deploy
        env:
          NEXTAUTH_SECRET: ${{ secrets.NEXTAUTH_SECRET }}
          NEXTAUTH_URL: http://192.168.1.200:3100
          ADMIN_USERNAME: ${{ secrets.ADMIN_USERNAME }}
          ADMIN_PASSWORD_HASH: ${{ secrets.ADMIN_PASSWORD_HASH }}
          INFLUXDB_V2_URL: http://192.168.1.200:8086
          INFLUXDB_V2_TOKEN: ${{ secrets.INFLUXDB_V2_TOKEN }}
          INFLUXDB_V2_ORG: openhab
          INFLUXDB_V2_OURA_BUCKET: oura
          INFLUXDB_V2_ZEPP_BUCKET: zepp
          INFLUXDB_V1_HOST: 192.168.1.200
          INFLUXDB_V1_PORT: "8087"
          INFLUXDB_V1_GARMIN_DB: GarminStats
          INFLUXDB_V1_USERNAME: garmin_user
          INFLUXDB_V1_PASSWORD: ${{ secrets.INFLUXDB_V1_PASSWORD }}
        run: |
          docker stop wear-app || true
          docker rm wear-app || true
          docker run -d --name wear-app --restart unless-stopped -p 3100:3000 -e NEXTAUTH_SECRET -e NEXTAUTH_URL -e ADMIN_USERNAME -e ADMIN_PASSWORD_HASH -e INFLUXDB_V2_URL -e INFLUXDB_V2_TOKEN -e INFLUXDB_V2_ORG -e INFLUXDB_V2_OURA_BUCKET -e INFLUXDB_V2_ZEPP_BUCKET -e INFLUXDB_V1_HOST -e INFLUXDB_V1_PORT -e INFLUXDB_V1_GARMIN_DB -e INFLUXDB_V1_USERNAME -e INFLUXDB_V1_PASSWORD wear-app:latest
```

**Aplikacija dostupna na:** `http://192.168.1.200:3100`

---

## Troubleshooting

### Runner se stalno restartuje
Normalno prije registracije. Nakon registracije i restarta treba biti `Up`.

### `pull access denied for codeberg/forgejo`
Pogrešan image naziv. Koristiti `codeberg.org/forgejo/forgejo:11`.

### `client version 1.41 is too old`
`docker.io` iz Debian repoa je prestara verzija. Instalirati `docker-ce-cli` iz oficijalne Docker registry.

### `Cannot connect to the Docker daemon at unix:///var/run/docker.sock`
`DOCKER_HOST` nije postavljen na nivou joba. Dodati:
```yaml
jobs:
  deploy:
    env:
      DOCKER_HOST: tcp://docker-proxy:2375
```

### `invalid reference format` pri docker run
Uzrok: secreti sa `$` znakovima (bcrypt, base64) se pogrešno interpretiraju u shellu.
Rješenje: koristiti `env:` blok na nivou stepa, pa `-e VARNAME` bez vrijednosti.

### `Bind for 0.0.0.0:3000 failed: port is already allocated`
Port 3000 zauzet od Grafane. Koristiti `-p 3100:3000`.

### `NO_SECRET` greška u next-auth
Secret nije stigao do kontejnera. Provjeri:
```bash
docker inspect wear-app --format='{{range .Config.Env}}{{println .}}{{end}}' | grep NEXTAUTH
```
Ako je prazan — secret nije dodan u Forgejo ili je pogrešno imenovan.

---

## 11. Push Mirror na GitHub

Automatski push kod na GitHub nakon svakog pusha na Forgejo.

**Setup:**

1. Idi na Forgejo repo → **Settings** → **Mirror Settings**
2. Klikni **Add Push Mirror**
3. Popuni:
   - **Remote URL:** `https://github.com/keon/wear-app.git`
   - **Authorization:** GitHub username + Personal Access Token
   - **Sync when commits are pushed:** ✓ checked

**Kako dobiti GitHub Personal Access Token:**

1. GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. **Generate new token**
3. Scope: `repo` (full control of private repositories)
4. Kopiraj token i koristi kao password u Mirror Settings

Nakon toga, svaki push na Forgejo automatski se zrcali na GitHub.

**Napomena:** GitHub Personal Access Token je kao password — čuva se kao secret u Forgejo, ne prikazuje se u UI.

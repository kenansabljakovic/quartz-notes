# Quartz 4 Mobile Notes Setup

This document describes the complete setup for accessing second-brain notes on mobile devices using Quartz 4, with automatic deployment when pushing to GitHub.

## Overview

The system consists of two separate repositories that work together:

- **second-brain** - Contains only markdown notes organized using PARA method
- **quartz-notes** - Fork of Quartz 4 that builds and serves the notes as a static website

This separation keeps the notes repository clean for AI tools (Codex, Claude Code) without confusion from Quartz configuration files.

## Architecture

```
┌─────────────────┐     push      ┌──────────────────┐
│  second-brain   │──────────────►│  GitHub Actions  │
│  (notes repo)   │               │  trigger-quartz  │
└─────────────────┘               └────────┬─────────┘
                                           │
                                           │ repository_dispatch
                                           ▼
┌─────────────────┐     push      ┌──────────────────┐
│    Dokploy      │◄──────────────│  quartz-notes    │
│  (deployment)   │               │  sync & commit   │
└────────┬────────┘               └──────────────────┘
         │
         │ build & deploy
         ▼
┌─────────────────┐
│  notes.keon.ba  │
│  (Quartz site)  │
└─────────────────┘
```

## Repository Structure

### second-brain (Notes Repository)

```
kenansabljakovic/second-brain
├── index.md                 ← Homepage for Quartz
├── 00-Inbox/
├── 01-Projects/
├── 02-Areas/
├── 03-Resources/
│   ├── code-server-docker-setup.md
│   └── quartz-4-mobile-notes-setup.md  ← This file
├── 04-Archives/
└── .github/
    └── workflows/
        └── trigger-quartz.yml   ← Triggers quartz-notes rebuild
```

### quartz-notes (Quartz Repository)

```
kenansabljakovic/quartz-notes (fork of jackyzha0/quartz)
├── content/                 ← Synced from second-brain via GitHub Actions
│   ├── index.md
│   ├── 00-Inbox/
│   ├── 01-Projects/
│   └── ...
├── quartz/                  ← Quartz source code
├── quartz.config.ts         ← Site configuration
├── quartz.layout.ts         ← Layout configuration
├── package.json
├── Dockerfile               ← Docker build for deployment
├── nginx.conf               ← Static file server config
└── .github/
    └── workflows/
        └── update-content.yaml  ← Syncs content and triggers deploy
```

## GitHub Actions Workflows

### Trigger Workflow (second-brain)

**File:** `.github/workflows/trigger-quartz.yml`

```yaml
name: Trigger Quartz Rebuild

on:
  push:
    branches: [main]

jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger quartz-notes rebuild
        run: |
          curl -X POST \
            -H "Authorization: token ${{ secrets.QUARTZ_TRIGGER_TOKEN }}" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/kenansabljakovic/quartz-notes/dispatches \
            -d '{"event_type":"content-update"}'
```

**Required Secret:** `QUARTZ_TRIGGER_TOKEN` - A Personal Access Token with `repo` scope.

### Sync Workflow (quartz-notes)

**File:** `.github/workflows/update-content.yaml`

```yaml
name: Sync Content and Deploy

on:
  repository_dispatch:
    types: [content-update]
  workflow_dispatch:
  push:
    branches: [main]

jobs:
  sync-and-build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout quartz-notes
        uses: actions/checkout@v4

      - name: Checkout second-brain content
        uses: actions/checkout@v4
        with:
          repository: kenansabljakovic/second-brain
          token: ${{ secrets.CONTENT_PAT }}
          path: content-source

      - name: Sync content
        run: |
          rm -rf content/*
          cp -r content-source/* content/
          rm -rf content/.git content/.github

      - name: Commit content changes
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add content
          git diff --staged --quiet || git commit -m "Sync content from second-brain"
          git push
```

**Required Secret:** `CONTENT_PAT` - A Personal Access Token with `repo` scope to access the private second-brain repository.

## Quartz Configuration

**File:** `quartz.config.ts`

Key configuration options:

```typescript
const config: QuartzConfig = {
  configuration: {
    pageTitle: "Kenan's Second Brain",
    pageTitleSuffix: " | Notes",
    enableSPA: true,
    enablePopovers: true,
    analytics: null,
    locale: "en-US",
    baseUrl: "notes.keon.ba",
    ignorePatterns: ["private", "templates", ".obsidian", ".git", ".gitkeep"],
    defaultDateType: "modified",
    theme: {
      // ... theme configuration
    },
  },
  plugins: {
    // ... plugin configuration
  },
}
```

## Docker Configuration

**File:** `Dockerfile`

```dockerfile
FROM node:22-slim AS builder
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./
RUN npm ci

# Copy all source files (content is synced via GitHub Actions)
COPY . .

# Build Quartz static site
RUN npx quartz build

# Production stage - serve with nginx
FROM nginx:alpine

# Copy built static files
COPY --from=builder /app/public /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**Important:** Uses `node:22-slim` instead of `node:22-alpine` because Alpine's BusyBox `env` doesn't support the `-S` flag used in Quartz's shebang.

**File:** `nginx.conf`

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri.html $uri/ =404;
    }

    # Enable gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
}
```

## Dokploy Deployment

### Application Settings

- **Source:** GitHub repository `kenansabljakovic/quartz-notes`
- **Branch:** `v4`
- **Build Type:** Dockerfile
- **Dockerfile Path:** `./Dockerfile`
- **Auto Deploy:** Enabled (rebuilds on push)

### Domain Configuration

- **Domain:** `notes.keon.ba`
- **Port:** `80` (nginx internal port)
- **HTTPS:** Enabled (Let's Encrypt)
- **Basic Auth:** Enabled for password protection

## GitHub Secrets Setup

### In second-brain repository

| Secret Name | Description |
|-------------|-------------|
| `QUARTZ_TRIGGER_TOKEN` | PAT with `repo` scope to trigger quartz-notes workflow |

### In quartz-notes repository

| Secret Name | Description |
|-------------|-------------|
| `CONTENT_PAT` | PAT with `repo` scope to checkout private second-brain repo |

### Creating a Personal Access Token (PAT)

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: `quartz-content-sync`
4. Select scope: `repo` (Full control of private repositories)
5. Generate and copy the token
6. Add to repository secrets in Settings → Secrets and variables → Actions

## Workflow: Adding/Editing Notes

### From Desktop (code-server)

1. Open `code.keon.ba` in browser
2. Edit markdown files in second-brain folder
3. Commit and push:
   ```bash
   git add -A
   git commit -m "Add new note"
   git push
   ```
4. GitHub Actions automatically syncs and rebuilds Quartz
5. Changes appear on `notes.keon.ba` within 2-3 minutes

### Reading Notes (Mobile)

1. Open `https://notes.keon.ba` in mobile browser
2. Enter basic auth credentials
3. Browse notes with full search, graph view, and backlinks

## Manual Content Sync (Fallback)

If GitHub Actions fail, you can manually sync content:

```bash
cd /home/keon/code-server/quartz-notes

# Sync content from second-brain
rm -rf content/*
cp -r /home/keon/code-server/second-brain/* content/
rm -rf content/.git content/.github

# Commit and push
git add -A
git commit -m "Manual content sync"
git push
```

## Troubleshooting

### Build fails with "env: unrecognized option: S"

**Cause:** Using Alpine-based Node image which has BusyBox with limited `env` command.

**Solution:** Use `node:22-slim` instead of `node:22-alpine` in Dockerfile.

### "Bad Gateway" error after deployment

**Cause:** Traefik can't reach the container, usually port misconfiguration.

**Solution:** In Dokploy Domains tab, ensure port is set to `80`.

### Default nginx page instead of Quartz

**Cause:** Quartz build failed or `index.md` is missing.

**Solution:**
1. Check build logs for errors
2. Ensure `index.md` exists in second-brain root
3. Verify content was properly synced

### GitHub Actions billing error

**Cause:** Private repositories require a payment method on file.

**Solution:**
1. Add payment method at https://github.com/settings/billing
2. Or make the quartz-notes repository public (notes stay private via basic auth)

### SSL certificate not valid

**Cause:** Let's Encrypt certificate not issued.

**Solution:**
1. Verify DNS for domain points to correct IP
2. Enable HTTPS in Dokploy domain settings
3. Wait a few minutes for certificate issuance

## Cost

- **GitHub Actions:** Free for public repos, 2000 min/month for private repos
- **Dokploy/VPS:** Depends on your hosting
- **Domain:** Depends on registrar
- **SSL:** Free (Let's Encrypt)

## References

- [Quartz 4 Documentation](https://quartz.jzhao.xyz/)
- [Quartz GitHub Repository](https://github.com/jackyzha0/quartz)
- [Dokploy Documentation](https://docs.dokploy.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

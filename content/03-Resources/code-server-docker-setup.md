# Code-Server Docker Setup with AI Coding Tools

> Complete guide for setting up a persistent code-server environment with Codex, Claude Code, OpenCode, and PARA-based note organization.

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Architecture Overview](#architecture-overview)
3. [Custom Dockerfile](#custom-dockerfile)
4. [Docker Compose Configuration](#docker-compose-configuration)
5. [PARA Folder Structure](#para-folder-structure)
6. [SSH & Git Setup](#ssh--git-setup)
7. [Authentication](#authentication)
8. [Adding VS Code Extensions](#adding-vs-code-extensions)
9. [Daily Workflow](#daily-workflow)
10. [Troubleshooting](#troubleshooting)

---

## Problem Statement

When using the default `codercom/code-server` Docker image:

- **Installed packages don't persist** - Every `docker compose up -d` wipes Node.js, npm packages, and CLI tools
- **VS Code extensions are lost** - Extensions installed via UI disappear after container recreation
- **AI tools need re-authentication** - Codex, Claude Code require re-setup each time

### Solution

Build a **custom Docker image** that bakes in all required tools, and use **volume mounts** for configuration/authentication persistence.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        HOST VPS                              │
│  /home/keon/code-server/                                     │
│  ├── Dockerfile              # Custom image definition       │
│  ├── docker-compose.yml      # Container configuration       │
│  ├── config/                 # → /home/coder/.config         │
│  ├── second-brain/           # → /home/coder/second-brain    │
│  ├── codex/                  # → /home/coder/.codex          │
│  ├── claude/                 # → /home/coder/.claude         │
│  └── ~/.ssh/ (read-only)     # → /home/coder/.ssh            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    DOCKER CONTAINER                          │
│  - Node.js 20.x                                              │
│  - OpenAI Codex CLI                                          │
│  - Anthropic Claude Code                                     │
│  - OpenCode AI                                               │
│  - Foam extension                                            │
│  - Git (for version control)                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       TRAEFIK                                │
│  - HTTPS termination (Let's Encrypt)                         │
│  - Routes code.keon.ba → container:8080                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Custom Dockerfile

**Location:** `/home/keon/code-server/Dockerfile`

```dockerfile
FROM codercom/code-server:latest

USER root

# Install Node.js 20.x and git
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install global npm packages
RUN npm install -g \
    @openai/codex \
    @anthropic-ai/claude-code \
    opencode-ai

# Install code-server extensions
RUN code-server --install-extension foam.foam-vscode

USER 1000

# Default port (code-server)
EXPOSE 8080
```

### Adding New Tools

To add a new npm package:

1. Edit `Dockerfile`, add to `npm install -g` line
2. Rebuild: `docker compose build`
3. Restart: `docker compose up -d`

---

## Docker Compose Configuration

**Location:** `/home/keon/code-server/docker-compose.yml`

```yaml
services:
  code-server:
    build:
      context: .
      dockerfile: Dockerfile
    image: code-server-custom:latest
    container_name: code-server
    restart: unless-stopped
    user: "1000:1000"
    environment:
      - TZ=Europe/Sarajevo
      - PASSWORD=your-password-here
      - DEFAULT_WORKSPACE=/home/coder/second-brain
    volumes:
      - ./config:/home/coder/.config
      - ./second-brain:/home/coder/second-brain
      - ./codex:/home/coder/.codex
      - ./claude:/home/coder/.claude
      - ~/.ssh:/home/coder/.ssh:ro
      - ~/.gitconfig:/home/coder/.gitconfig:ro
    networks:
      - dokploy-network
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=dokploy-network"
      - "traefik.http.routers.code-http.rule=Host(`code.keon.ba`)"
      - "traefik.http.routers.code-http.entrypoints=web"
      - "traefik.http.routers.code-http.middlewares=redirect-to-https@file"
      - "traefik.http.routers.code.rule=Host(`code.keon.ba`)"
      - "traefik.http.routers.code.entrypoints=websecure"
      - "traefik.http.routers.code.tls=true"
      - "traefik.http.routers.code.tls.certresolver=letsencrypt"
      - "traefik.http.services.code.loadbalancer.server.port=8080"

networks:
  dokploy-network:
    external: true
```

### Key Configuration Points

| Setting | Purpose |
|---------|---------|
| `DEFAULT_WORKSPACE` | Opens second-brain folder by default |
| `~/.ssh:ro` | Read-only SSH keys for Git |
| `~/.gitconfig:ro` | Git user configuration |
| `user: "1000:1000"` | Run as non-root user |

---

## PARA Folder Structure

Based on [Tiago Forte's PARA Method](https://fortelabs.com/blog/para/):

```
second-brain/
├── 00-Inbox      # Quick capture, process later
├── 01-Projects   # Active projects with deadlines
├── 02-Areas      # Ongoing responsibilities (no deadline)
├── 03-Resources  # Reference materials, articles
└── 04-Archives   # Completed/inactive items
```

### Why Numbered Prefixes?

- Keeps folders sorted by "actionability" (most → least)
- Works consistently across all platforms
- Hyphen format (`00-Inbox`) is CLI-friendly (no quotes needed)

---

## SSH & Git Setup

### 1. Generate SSH Key (on host)

```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519 -N ""
```

### 2. Add Key to GitHub

```bash
cat ~/.ssh/id_ed25519.pub
# Copy output and add to: https://github.com/settings/keys
```

### 3. Configure Git User (on host)

```bash
git config --global user.name "yourusername"
git config --global user.email "your-email@example.com"
```

### 4. Test Connection (inside container)

```bash
ssh -T git@github.com
# Expected: "Hi username! You've successfully authenticated..."
```

> **Note:** The `known_hosts` warning is normal because `.ssh` is mounted read-only.

---

## Authentication

### OpenAI Codex

Codex uses OAuth tokens stored in `~/.codex/auth.json`.

**To transfer from host to container:**

```bash
# On host:
cp /home/keon/.codex/auth.json /home/keon/code-server/codex/
chown 1000:1000 /home/keon/code-server/codex/auth.json
```

**Test:**
```bash
docker exec code-server codex -p "hello"
```

### Anthropic Claude Code

Claude Code uses OAuth tokens stored in `~/.claude/.credentials.json`.

**To transfer from host to container:**

```bash
# On host:
cp /home/keon/.claude/.credentials.json /home/keon/code-server/claude/
chown 1000:1000 /home/keon/code-server/claude/.credentials.json
```

**First-time interactive setup (inside container terminal):**

1. Run `claude` in code-server terminal
2. Select theme
3. Choose "Claude Code subscription" for auth
4. You'll get a `localhost:45219/callback?code=XXX` URL
5. **This won't open in browser** (localhost = container)

**The trick - complete OAuth manually:**

```bash
# In code-server terminal, run:
curl "http://localhost:45219/callback?code=XXX&state=YYY"
```

This sends the callback to Claude's local OAuth server inside the container.

**Test:**
```bash
claude -p "hello"
```

---

## Adding VS Code Extensions

### Method 1: Add to Dockerfile (Permanent)

```dockerfile
RUN code-server --install-extension publisher.extension-name
```

Then rebuild:
```bash
docker compose build && docker compose up -d
```

### Method 2: Install via UI (Temporary)

1. Open code-server in browser
2. Extensions panel (Ctrl+Shift+X)
3. Search and install

> **Warning:** UI-installed extensions are lost after container rebuild.

### Popular Extensions

```dockerfile
# Python
RUN code-server --install-extension ms-python.python

# Prettier
RUN code-server --install-extension esbenp.prettier-vscode

# GitLens
RUN code-server --install-extension eamodio.gitlens

# Markdown
RUN code-server --install-extension yzhang.markdown-all-in-one

# Foam (for Zettelkasten/PKM)
RUN code-server --install-extension foam.foam-vscode
```

### Note on Open VSX

code-server uses [Open VSX Registry](https://open-vsx.org/) instead of Microsoft's marketplace. Some extensions may not be available.

---

## Daily Workflow

### Backup Notes to GitHub

```bash
cd ~/second-brain
git add .
git commit -m "Add notes"
git push
```

Or use the Git panel in code-server sidebar.

### Using AI Tools

```bash
# OpenAI Codex
codex "write a function that..."

# Anthropic Claude Code
claude -p "explain this code..."

# OpenCode
opencode
```

### Rebuild After Dockerfile Changes

```bash
cd /home/keon/code-server
docker compose build
docker compose up -d
```

---

## Troubleshooting

### Claude asks for authentication even though credentials exist

The `-p` flag (print mode) uses existing credentials without onboarding. Interactive mode has a first-run flow.

**Solution:** Complete OAuth via curl (see Authentication section).

### Git push fails with "repository not found"

The repository doesn't exist on GitHub yet.

**Solution:** Create it at https://github.com/new

### Extensions disappear after restart

Extensions installed via UI don't persist.

**Solution:** Add to Dockerfile and rebuild.

### "Permission denied" errors

File ownership mismatch.

**Solution:**
```bash
chown -R 1000:1000 /home/keon/code-server/second-brain
```

### SSH "known_hosts read-only" warning

Normal behavior - `.ssh` is mounted read-only for security.

**Can be ignored** - authentication still works.

---

## File Locations Summary

| File | Purpose |
|------|---------|
| `/home/keon/code-server/Dockerfile` | Custom image definition |
| `/home/keon/code-server/docker-compose.yml` | Container config |
| `/home/keon/code-server/second-brain/` | PARA notes (Git repo) |
| `/home/keon/code-server/codex/auth.json` | Codex OAuth tokens |
| `/home/keon/code-server/claude/.credentials.json` | Claude OAuth tokens |
| `~/.ssh/id_ed25519` | SSH private key |
| `~/.gitconfig` | Git user config |

---

## References

- [code-server Documentation](https://coder.com/docs/code-server)
- [PARA Method by Tiago Forte](https://fortelabs.com/blog/para/)
- [Claude Code Setup](https://docs.anthropic.com/claude-code)
- [OpenAI Codex CLI](https://github.com/openai/codex)
- [Foam for VS Code](https://foambubble.github.io/foam/)

---

*Last updated: January 28, 2026*

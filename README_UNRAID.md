# AgenticSeek für Unraid

Diese Anleitung erklärt, wie Sie AgenticSeek auf Ihrem Unraid-Server einrichten.

## 🚀 Schnellstart

### 1. Repository klonen
```bash
git clone https://github.com/Fosowl/agenticSeek.git
cd agenticSeek
git checkout docker_deployement
```

### 2. Umgebungsvariablen konfigurieren
Kopieren Sie `.env.example` zu `.env` und passen Sie die Werte an:

```bash
cp .env.example .env
nano .env
```

**Wichtige Einstellungen für Unraid:**
```env
# Ports (an Ihren Server anpassen)
FRONTEND_PORT=3000
BACKEND_PORT=8000
REDIS_PORT=6379
SEARXNG_PORT=8080

# Unraid-spezifische Pfade
UNRAID_APPDATA_PATH=/mnt/user/appdata/agenticseek

# API-Keys (ersetzen Sie 'xxxxx' mit echten Keys)
OPENAI_API_KEY='your_openai_key_here'
DEEPSEEK_API_KEY='your_deepseek_key_here'
OPENROUTER_API_KEY='your_openrouter_key_here'

# LLM-Provider URLs (falls lokal auf Unraid)
OLLAMA_URL=http://192.168.1.100:11434  # Ihre Unraid-IP
LM_STUDIO_URL=http://192.168.1.100:1234
```

### 3. Verzeichnisse erstellen
Erstellen Sie die notwendigen Verzeichnisse auf Unraid:
```bash
mkdir -p /mnt/user/appdata/agenticseek/{workdir,logs,config,screenshots,redis,searxng}
```

### 4. Container starten
```bash
docker compose up -d
```

## 📊 Service-Übersicht

| Service | Port | Beschreibung |
|---------|------|--------------|
| Frontend | 3000 | React-Web-Interface |
| Backend | 8000 | Python-API mit Agenten |
| Redis | 6379 | Datenbank für Sessions |
| SearxNG | 8080 | Suchmaschinen-Proxy |

## 🔧 Unraid-spezifische Konfiguration

### Docker-Compose Template für Unraid

Wenn Sie die Container manuell in Unraid einrichten möchten:

#### AgenticSeek Frontend
- **Repository:** `agenticseek-frontend` (build from source)
- **Network Type:** Custom: agenticseek-net
- **Port:** `3000:3000`
- **Volumes:**
  - `/mnt/user/appdata/agenticseek/screenshots:/app/screenshots`

#### AgenticSeek Backend
- **Repository:** `agenticseek-backend` (build from source)
- **Network Type:** Custom: agenticseek-net
- **Port:** `8000:8000`
- **Volumes:**
  - `/mnt/user/appdata/agenticseek/workdir:/app/workdir`
  - `/mnt/user/appdata/agenticseek/logs:/app/logs`
  - `/mnt/user/appdata/agenticseek/config:/app/config`
- **Environment Variables:**
  - `REDIS_URL=redis://agenticseek-redis:6379/0`
  - `SEARXNG_URL=http://agenticseek-searxng:8080`

#### Redis (Valkey)
- **Repository:** `valkey/valkey:8-alpine`
- **Network Type:** Custom: agenticseek-net
- **Port:** `6379:6379`
- **Volumes:**
  - `/mnt/user/appdata/agenticseek/redis:/data`

#### SearxNG
- **Repository:** `searxng/searxng:latest`
- **Network Type:** Custom: agenticseek-net
- **Port:** `8080:8080`
- **Volumes:**
  - `/mnt/user/appdata/agenticseek/searxng:/etc/searxng`

## 🔍 Überwachung & Logs

### Container-Status prüfen
```bash
docker ps
```

### Logs anzeigen
```bash
docker logs agenticseek-backend
docker logs agenticseek-frontend
docker logs agenticseek-redis
docker logs agenticseek-searxng
```

### Health-Checks
- Frontend: `http://YOUR_UNRAID_IP:3000`
- Backend: `http://YOUR_UNRAID_IP:8000/health`
- SearxNG: `http://YOUR_UNRAID_IP:8080`
- Redis: Intern via Backend

## 🚨 Troubleshooting

### Häufige Probleme

**1. ChromeDriver-Fehler im Backend:**
```bash
# Container neu bauen
docker compose down
docker compose build --no-cache backend
docker compose up -d
```

**2. Berechtigungsprobleme:**
```bash
# Verzeichnisse richtig berechtigen
sudo chown -R 1000:1000 /mnt/user/appdata/agenticseek
```

**3. Netzwerk-Probleme:**
```bash
# Netzwerk prüfen
docker network ls
docker network inspect agenticseek_agentic-seek-net
```

**4. LLM-Provider nicht erreichbar:**
- Prüfen Sie die URLs in der `.env`
- Stellen Sie sicher, dass Ollama/LM Studio läuft
- Verwenden Sie die richtige Unraid-IP

### Log-Verzeichnisse
- Backend-Logs: `/mnt/user/appdata/agenticseek/logs/`
- Docker-Logs: `docker logs [container_name]`

## 🔄 Updates

```bash
cd agenticSeek
git pull origin docker_deployement
docker compose down
docker compose build --no-cache
docker compose up -d
```

## 💾 Backup

Wichtige Verzeichnisse für Backups:
- `/mnt/user/appdata/agenticseek/workdir` (Agent-Arbeitsverzeichnisse)
- `/mnt/user/appdata/agenticseek/config` (Konfigurationen)
- `/mnt/user/appdata/agenticseek/redis` (Sessions und Cache)

## 🔐 Sicherheit

1. **API-Keys sicher aufbewahren**
   - Verwenden Sie starke, einzigartige Keys
   - Teilen Sie die `.env`-Datei nicht

2. **Netzwerk-Sicherheit**
   - Verwenden Sie Firewalls für externe Zugriffe
   - Erwägen Sie Reverse-Proxy (nginx/Traefik)

3. **Container-Updates**
   - Regelmäßige Updates der Base-Images
   - Überwachung von Sicherheitsupdates

## 📞 Support

Bei Problemen:
1. Prüfen Sie die Logs (`docker logs [container]`)
2. Überprüfen Sie die `.env`-Konfiguration
3. Stellen Sie sicher, dass alle Ports verfügbar sind
4. Öffnen Sie ein Issue im GitHub-Repository

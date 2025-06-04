# AgenticSeek Installation auf Unraid 7

Diese Anleitung führt Sie durch die Installation von AgenticSeek auf Unraid 7.

## 🔧 **Voraussetzungen**

1. **Unraid 7** mit aktiviertem Docker
2. **Community Applications Plugin** installiert
3. **Terminal-Zugang** zu Ihrem Unraid-Server (SSH oder Web-Terminal)

## 📋 **Schritt-für-Schritt Installation**

### **Schritt 1: Terminal-Zugang**
Verbinden Sie sich mit Ihrem Unraid-Server:
- **Web-Terminal**: Unraid WebUI → Terminal
- **SSH**: `ssh root@YOUR_UNRAID_IP`

### **Schritt 2: Repository klonen**
```bash
# Wechseln Sie ins Appdata-Verzeichnis
cd /mnt/user/appdata

# Repository klonen
git clone https://github.com/Fosowl/agenticSeek.git
cd agenticSeek

# Auf Docker-Branch wechseln
git checkout docker_deployement
```

### **Schritt 3: Umgebungsvariablen konfigurieren**
```bash
# .env erstellen
cp .env.example .env

# .env bearbeiten
nano .env
```

**Wichtige Änderungen in der .env:**
```env
# Unraid-spezifische Pfade
UNRAID_APPDATA_PATH=/mnt/user/appdata/agenticseek

# Ihre echten API-Keys eintragen
OPENAI_API_KEY='sk-your-real-openai-key-here'
DEEPSEEK_API_KEY='your-deepseek-key-here'
OPENROUTER_API_KEY='your-openrouter-key-here'

# Falls Sie Ollama lokal auf Unraid laufen haben
OLLAMA_URL=http://192.168.1.XXX:11434  # Ihre Unraid-IP
```

**Speichern mit:** `Ctrl + X` → `Y` → `Enter`

### **Schritt 4: Setup-Script ausführen**
```bash
# Script ausführbar machen
chmod +x unraid-setup.sh

# Installation starten
./unraid-setup.sh
```

Das Script wird automatisch:
- Verzeichnisse erstellen
- Docker Images bauen
- Container starten
- Health-Checks durchführen

### **Schritt 5: Services prüfen**
Nach etwa 2-3 Minuten sollten alle Services laufen:

```bash
# Container-Status prüfen
docker ps

# Logs bei Problemen
docker logs agenticseek-backend
docker logs agenticseek-frontend
```

## 🌐 **Zugriff auf AgenticSeek**

Nach erfolgreicher Installation erreichen Sie AgenticSeek über:
- **Frontend**: `http://YOUR_UNRAID_IP:3000`
- **Backend-API**: `http://YOUR_UNRAID_IP:8000`
- **SearxNG**: `http://YOUR_UNRAID_IP:8080`

## 🔧 **Alternative: Manuelle Container-Einrichtung in Unraid**

Falls das Script nicht funktioniert, können Sie die Container auch manuell in der Unraid WebUI erstellen:

### **1. Netzwerk erstellen**
```bash
docker network create agenticseek_agentic-seek-net
```

### **2. Redis Container**
**Docker Hub:** `valkey/valkey:8-alpine`
- **Name:** `agenticseek-redis`
- **Network:** `agenticseek_agentic-seek-net`
- **Port:** `6379:6379`
- **Volume:** `/mnt/user/appdata/agenticseek/redis:/data`

### **3. SearxNG Container**
**Docker Hub:** `searxng/searxng:latest`
- **Name:** `agenticseek-searxng`
- **Network:** `agenticseek_agentic-seek-net`
- **Port:** `8080:8080`
- **Volume:** `/mnt/user/appdata/agenticseek/searxng:/etc/searxng`

### **4. Backend Container**
**Repository:** Aus Source-Code bauen
```bash
cd /mnt/user/appdata/agenticseek
docker build -f Dockerfile.backend -t agenticseek-backend .
```
- **Image:** `agenticseek-backend`
- **Name:** `agenticseek-backend`
- **Network:** `agenticseek_agentic-seek-net`
- **Port:** `8000:8000`
- **Volumes:**
  - `/mnt/user/appdata/agenticseek/workdir:/app/workdir`
  - `/mnt/user/appdata/agenticseek/logs:/app/logs`
  - `/mnt/user/appdata/agenticseek/config:/app/config`

### **5. Frontend Container**
```bash
cd /mnt/user/appdata/agenticseek
docker build -f frontend/Dockerfile.frontend -t agenticseek-frontend ./frontend
```
- **Image:** `agenticseek-frontend`
- **Name:** `agenticseek-frontend`
- **Network:** `agenticseek_agentic-seek-net`
- **Port:** `3000:3000`

## 🚨 **Troubleshooting**

### **Problem: Git nicht gefunden**
```bash
# Git installieren
opkg update
opkg install git
```

### **Problem: Docker-Compose nicht gefunden**
```bash
# Docker Compose installieren
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### **Problem: Container startet nicht**
```bash
# Logs prüfen
docker logs agenticseek-backend

# Verzeichnisse prüfen
ls -la /mnt/user/appdata/agenticseek/

# Berechtigungen korrigieren
chown -R 1000:1000 /mnt/user/appdata/agenticseek/
```

### **Problem: Ports belegt**
Ändern Sie die Ports in der `.env`:
```env
FRONTEND_PORT=3001
BACKEND_PORT=8001
SEARXNG_PORT=8081
```

## 🔄 **Updates**

```bash
cd /mnt/user/appdata/agenticseek
git pull origin docker_deployement
docker compose down
docker compose build --no-cache
docker compose up -d
```

## 💾 **Backup-Empfehlung**

Sichern Sie regelmäßig:
- `/mnt/user/appdata/agenticseek/workdir`
- `/mnt/user/appdata/agenticseek/config`
- `/mnt/user/appdata/agenticseek/.env`

## 📞 **Support**

Bei Problemen:
1. Logs prüfen: `docker logs [container-name]`
2. .env-Konfiguration überprüfen
3. Issue im GitHub-Repository öffnen

**Logs sammeln für Support:**
```bash
docker logs agenticseek-backend > backend.log 2>&1
docker logs agenticseek-frontend > frontend.log 2>&1

#!/bin/bash

# AgenticSeek Unraid Setup Script
# Führt alle notwendigen Schritte für die Unraid-Installation aus

echo "🚀 AgenticSeek Unraid Setup gestartet..."

# Farben für bessere Lesbarkeit
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funktionen
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# 1. Prüfe ob wir im richtigen Verzeichnis sind
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml nicht gefunden. Bitte führen Sie das Script im AgenticSeek-Verzeichnis aus."
    exit 1
fi

print_success "AgenticSeek-Verzeichnis gefunden"

# 2. Prüfe Docker Installation
if ! command -v docker &> /dev/null; then
    print_error "Docker ist nicht installiert. Bitte installieren Sie Docker zuerst."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose ist nicht installiert."
    exit 1
fi

print_success "Docker und Docker Compose gefunden"

# 3. Erstelle Unraid-Verzeichnisse
print_info "Erstelle Unraid-Verzeichnisse..."
mkdir -p /mnt/user/appdata/agenticseek/{workdir,logs,config,screenshots,redis,searxng}

if [ $? -eq 0 ]; then
    print_success "Unraid-Verzeichnisse erstellt"
else
    print_warning "Konnte Unraid-Verzeichnisse nicht erstellen (möglicherweise bereits vorhanden)"
fi

# 4. Prüfe .env Datei
if [ ! -f ".env" ]; then
    print_warning ".env Datei nicht gefunden. Erstelle aus .env.example..."
    cp .env.example .env
    print_info "Bitte bearbeiten Sie die .env Datei mit Ihren API-Keys und Unraid-Einstellungen"
    print_info "nano .env"
    read -p "Drücken Sie Enter, wenn Sie die .env Datei bearbeitet haben..."
fi

print_success ".env Datei vorhanden"

# 5. Stoppe eventuell laufende Container
print_info "Stoppe eventuell laufende Container..."
docker compose down 2>/dev/null || true

# 6. Baue die Images
print_info "Baue Backend-Image..."
docker compose build backend

if [ $? -eq 0 ]; then
    print_success "Backend-Image erfolgreich gebaut"
else
    print_error "Fehler beim Bauen des Backend-Images"
    exit 1
fi

print_info "Baue Frontend-Image..."
docker compose build frontend

if [ $? -eq 0 ]; then
    print_success "Frontend-Image erfolgreich gebaut"
else
    print_error "Fehler beim Bauen des Frontend-Images"
    exit 1
fi

# 7. Starte die Services
print_info "Starte alle Services..."
docker compose up -d

if [ $? -eq 0 ]; then
    print_success "Alle Services gestartet"
else
    print_error "Fehler beim Starten der Services"
    exit 1
fi

# 8. Warte auf Service-Bereitschaft
print_info "Warte auf Service-Bereitschaft..."
sleep 30

# 9. Prüfe Service-Status
print_info "Prüfe Service-Status..."

# Redis Check
if docker exec agenticseek-redis valkey-cli ping | grep -q PONG; then
    print_success "Redis ist bereit"
else
    print_warning "Redis reagiert nicht"
fi

# Backend Check
if curl -f http://localhost:8000/health 2>/dev/null | grep -q "healthy"; then
    print_success "Backend ist bereit"
else
    print_warning "Backend reagiert nicht auf Health-Check"
fi

# Frontend Check
if curl -f http://localhost:3000 &>/dev/null; then
    print_success "Frontend ist bereit"
else
    print_warning "Frontend reagiert nicht"
fi

# SearxNG Check
if curl -f http://localhost:8080 &>/dev/null; then
    print_success "SearxNG ist bereit"
else
    print_warning "SearxNG reagiert nicht"
fi

echo ""
print_success "🎉 AgenticSeek Setup abgeschlossen!"
echo ""
print_info "Zugriff auf die Services:"
echo "  Frontend: http://$(hostname -I | awk '{print $1}'):3000"
echo "  Backend:  http://$(hostname -I | awk '{print $1}'):8000"
echo "  SearxNG:  http://$(hostname -I | awk '{print $1}'):8080"
echo ""
print_info "Container-Status prüfen:"
echo "  docker ps"
echo ""
print_info "Logs anzeigen:"
echo "  docker logs agenticseek-backend"
echo "  docker logs agenticseek-frontend"
echo ""
print_info "Services stoppen:"
echo "  docker compose down"
echo ""
print_warning "Vergessen Sie nicht, Ihre API-Keys in der .env Datei zu konfigurieren!"

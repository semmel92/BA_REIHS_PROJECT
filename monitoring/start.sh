#!/bin/bash

echo ""
echo "🔍 Überprüfe Voraussetzungen..."

# Prüfe ob docker installiert ist
if ! command -v docker &> /dev/null
then
    echo "❌ Docker ist nicht installiert oder nicht im PATH."
    exit 1
fi

# Prüfe ob docker-compose installiert ist
if ! command -v docker-compose &> /dev/null
then
    echo "❌ docker-compose ist nicht installiert oder nicht im PATH."
    exit 1
fi

echo "✅ Voraussetzungen erfüllt."

# Docker Umgebung beenden, falls noch alte Container laufen
echo ""
echo "🧹 Beende evtl. laufende Container..."
docker-compose down

# Spring Boot Projekte bauen
echo ""
echo "🛠️ Baue Spring Boot Projekte über Root-Wrapper..."
(cd .. && ./gradlew clean :myservice:bootJar :backend-a:bootJar)


# Compose starten
echo ""
echo "🔄 Starte Docker-Umgebung neu..."
docker-compose up --build -d

sleep 5

# URLs
PROM_URL="http://localhost:9090"
GRAFANA_URL="http://localhost:3000"
MY_SERVICE_URL="http://localhost:8080/hello"
METRICS_URL="http://localhost:8080/actuator/prometheus"
NODE_EXPORTER_URL="http://localhost:9100/metrics"

echo ""
echo "✅ Umgebung ist aktiv. Die wichtigsten Endpunkte:"
echo "----------------------------------------------"
echo "🔍 Prometheus:     $PROM_URL"
echo "📊 Grafana:        $GRAFANA_URL"
echo "⚙️  MyService:      $MY_SERVICE_URL"
echo "📈 Metriken:       $METRICS_URL"
echo "🧠 Node Exporter:  $NODE_EXPORTER_URL"
echo ""

# Browser-Tabs öffnen (nur unter Windows/WSL)
echo "🌐 Öffne $PROM_URL im Windows-Browser..."
powershell.exe start "$PROM_URL"
echo "🌐 Öffne $GRAFANA_URL im Windows-Browser..."
powershell.exe start "$GRAFANA_URL"
echo "🌐 Öffne $MY_SERVICE_URL im Windows-Browser..."
powershell.exe start "$MY_SERVICE_URL"

#!/bin/bash

echo ""
ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

if [ -z "$SPRING_PROFILES_ACTIVE" ]; then
    echo ""
    echo "❓ Welche Resilienzstrategie möchtest du aktivieren?"
    echo "   [1] Keine (Standard)"
    echo "   [2] Retry aktivieren"
    read -p "➡️ Auswahl [1/2]: " choice

    case "$choice" in
        2)
            SPRING_PROFILES_ACTIVE=retry
            ;;
        *)
            SPRING_PROFILES_ACTIVE=""
            ;;
    esac

    # In .env schreiben (neu erstellen oder überschreiben)
    echo "SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE" > "$ENV_FILE"
    echo "💾 Profil wurde in $ENV_FILE gespeichert."
else
    echo "✅ Profil aus .env verwendet: SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE"
fi
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
(cd .. && ./gradlew clean :myservice:bootJar :backend-a:bootJar :backend-b:bootJar)


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
BACKEND_A_URL="http://localhost:8081/data"
BACKEND_B_URL="http://localhost:8082/data"

echo ""
echo "✅ Umgebung ist aktiv. Die wichtigsten Endpunkte:"
echo "----------------------------------------------"
echo "🔍 Prometheus:     $PROM_URL"
echo "📊 Grafana:        $GRAFANA_URL"
echo "⚙️  MyService:      $MY_SERVICE_URL"
echo "📈 Metriken:       $METRICS_URL"
echo "🧠 Node Exporter:  $NODE_EXPORTER_URL"
echo "📦 Backend A:      $BACKEND_A_URL"
echo "📦 Backend B:      $BACKEND_B_URL"
echo ""
echo "----------------------------------------------"


# Browser-Tabs öffnen (nur unter Windows/WSL)
echo "🌐 Öffne $PROM_URL im Windows-Browser..."
powershell.exe start "$PROM_URL"
echo "🌐 Öffne $GRAFANA_URL im Windows-Browser..."
powershell.exe start "$GRAFANA_URL"
echo "🌐 Öffne $MY_SERVICE_URL im Windows-Browser..."
powershell.exe start "$MY_SERVICE_URL"
echo "🌐 Öffne $BACKEND_A_URL im Windows-Browser..."
powershell.exe start "$BACKEND_A_URL"
echo "🌐 Öffne $BACKEND_B_URL im Windows-Browser..."
powershell.exe start "$BACKEND_B_URL"
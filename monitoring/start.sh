#!/bin/bash

echo ""
ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

if [ -z "$SPRING_PROFILES_ACTIVE" ] || [ -z "$SPRING_PROFILES_ACTIVE_BACKEND_A" ]; then
    echo ""
    echo "❓ Welche Resilienzstrategie möchtest du aktivieren?"
    echo "   [1] Keine (Standard)"
    echo "   [2] Retry aktivieren"
    echo "   [3] Circuit Breaker (Clientseitig)"
    echo "   [4] Circuit Breaker (Serverseitig)"
    echo "   [5] Load Balancer aktivieren"
    read -p "➡️ Auswahl [1-5]: " choice

    case "$choice" in
        2)
            SPRING_PROFILES_ACTIVE=retry
            SPRING_PROFILES_ACTIVE_BACKEND_A=serverdefault
            ;;
        3)
            SPRING_PROFILES_ACTIVE=circuitbreaker
            SPRING_PROFILES_ACTIVE_BACKEND_A=serverdefault
            ;;
        4)
            SPRING_PROFILES_ACTIVE=default
            SPRING_PROFILES_ACTIVE_BACKEND_A=serverbreaker
            ;;
        5)
            SPRING_PROFILES_ACTIVE=loadbalancer
            SPRING_PROFILES_ACTIVE_BACKEND_A=loadbalancer
            ;;
        *)
            SPRING_PROFILES_ACTIVE=default
            SPRING_PROFILES_ACTIVE_BACKEND_A=serverdefault
            ;;
    esac

    echo "SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE" > "$ENV_FILE"
    echo "SPRING_PROFILES_ACTIVE_BACKEND_A=$SPRING_PROFILES_ACTIVE_BACKEND_A" >> "$ENV_FILE"
    echo "💾 Profile wurden in $ENV_FILE gespeichert."
else
    echo "✅ Profile aus .env verwendet:"
    echo "   Client (myservice):      SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE"
    echo "   Server (backend-a):      SPRING_PROFILES_ACTIVE_BACKEND_A=$SPRING_PROFILES_ACTIVE_BACKEND_A"
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
echo "🧹 Beende ALLE laufenden Container (systemweit)..."
docker stop $(docker ps -q) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Spring Boot Projekte bauen
echo ""
echo "🛠️ Baue Spring Boot Projekte über Root-Wrapper..."
(cd .. && ./gradlew clean :myservice:bootJar :backend-a:bootJar :backend-b:bootJar :eureka-server:bootJar)


# Compose starten
echo ""
echo "🔄 Starte Docker-Umgebung neu..."
docker compose --profile "$SPRING_PROFILES_ACTIVE" up --build -d

sleep 5

# URLs
PROM_URL="http://localhost:9090"
GRAFANA_URL="http://localhost:3000"
MY_SERVICE_URL="http://localhost:8080/hello"
METRICS_URL="http://localhost:8080/actuator/prometheus"
NODE_EXPORTER_URL="http://localhost:9100/metrics"
BACKEND_A_URL="http://localhost:8081/data"
BACKEND_B_URL="http://localhost:8082/data"
EUREKA_URL="http://localhost:8761"
CADVISOR_URL="http://localhost:8089/metrics" 

echo ""
echo "✅ Umgebung ist aktiv. Die wichtigsten Endpunkte:"
echo "----------------------------------------------"
echo "🔍 Prometheus:     $PROM_URL"
echo "📊 Grafana:        $GRAFANA_URL"
echo "⚙️ MyService:      $MY_SERVICE_URL"
echo "📈 Metriken:       $METRICS_URL"
echo "📈 Cadvisor:       $CADVISOR_URL"
echo "🧠 Node Exporter:  $NODE_EXPORTER_URL"
echo "📦 Backend A:      $BACKEND_A_URL"
echo "📦 Backend B:      $BACKEND_B_URL"
echo "🧭 Eureka Server:  $EUREKA_URL"
echo ""
echo "----------------------------------------------"


echo "🌐 Öffne $PROM_URL im Windows-Browser..."
powershell.exe start "$PROM_URL"
echo "🌐 Öffne $GRAFANA_URL im Windows-Browser..."
powershell.exe start "$GRAFANA_URL"


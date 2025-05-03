#!/bin/bash

echo ""
echo "🚀 Starte Circuit-Breaker-Test mit JMeter + Ressourcenmonitoring"

# 1. Zeiterfassung
start_time=$(date +%s)
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# 2. Ergebnisverzeichnis vorbereiten
RESULT_DIR="results/circuitbreaker_${timestamp}"
mkdir -p "$RESULT_DIR"

# 3. Ressourcen-Monitoring starten (live CSV, alle 0.5s)
echo "📊 Starte Ressourcenüberwachung (intervallbasiert)..."
(
  while true; do
    docker stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}}" >> "$RESULT_DIR/docker_stats_live.csv"
    sleep 0.5
  done
) &
STATS_PID=$!

# 4. JMeter-Test ausführen
echo "🎯 Starte JMeter-Test..."
docker run --rm \
  -v "$(pwd)/circuitbreaker_test.jmx:/test.jmx" \
  -v "$(pwd)/$RESULT_DIR:/results" \
  justb4/jmeter \
  -n -t /test.jmx -l /results/results.jtl -e -o /results/report

# 5. Ressourcen-Monitoring beenden
echo "🛑 Beende Ressourcenüberwachung..."
kill "$STATS_PID" 2>/dev/null

# 6. Dauer anzeigen
end_time=$(date +%s)
duration=$((end_time - start_time))

# 7. Zusammenfassung
echo ""
echo "✅ Test abgeschlossen in ${duration} Sekunden."
echo "📁 Ergebnisse: $RESULT_DIR"
echo "📊 HTML-Report: $RESULT_DIR/report/index.html"
echo "📈 Ressourcenverbrauch: $RESULT_DIR/docker_stats_live.csv"

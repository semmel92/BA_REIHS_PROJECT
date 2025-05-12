#!/bin/bash

echo ""
echo "🚀 Starte DEFAULT-Baseline-Test (backend-a + backend-b) mit JMeter + Ressourcenmonitoring"

# 1. Zeiterfassung
start_time=$(date +%s)
timestamp_full=$(date +"%Y-%m-%d_%H-%M-%S")
timestamp_short=$(date +"%H-%M-%S")

# 2. Ergebnisverzeichnis vorbereiten
RESULT_DIR="results/default_${timestamp_full}"
mkdir -p "$RESULT_DIR"

# 3. Ressourcen-Monitoring starten
STATS_FILE="${timestamp_short}_docker_stats_live.csv"
echo "📊 Starte Ressourcenüberwachung → ${STATS_FILE} ..."
(
  while true; do
    docker stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}}" >> "$RESULT_DIR/$STATS_FILE"
    sleep 0.5
  done
) &
STATS_PID=$!
echo "# --- TEST_START: $(date +%s) ---" >> "$RESULT_DIR/$STATS_FILE"

# 4. JMeter-Test ausführen (angepasst für A und B)
JMETER_RESULTS_FILE="${timestamp_short}_results.jtl"
echo "🎯 Starte JMeter-Test (8081 + 8082) → ${JMETER_RESULTS_FILE} ..."
docker run --rm \
  -v "$(pwd)/default_test.jmx:/test.jmx" \
  -v "$(pwd)/$RESULT_DIR:/results" \
  justb4/jmeter \
  -n -t /test.jmx -l /results/$JMETER_RESULTS_FILE -e -o /results/report

# 5. Ressourcen-Monitoring beenden
echo "🛑 Beende Ressourcenüberwachung..."
echo "# --- TEST_END: $(date +%s) ---" >> "$RESULT_DIR/$STATS_FILE"
kill "$STATS_PID" 2>/dev/null

# 6. Dauer anzeigen
end_time=$(date +%s)
duration=$((end_time - start_time))

# 7. Zusammenfassung
echo ""
echo "✅ Default-Test abgeschlossen in ${duration} Sekunden."
echo "📁 Ergebnisse: $RESULT_DIR"
echo "📊 HTML-Report: $RESULT_DIR/report/index.html"
echo "📈 Ressourcenverbrauch: $RESULT_DIR/$STATS_FILE"
echo "📄 JMeter-Daten: $RESULT_DIR/$JMETER_RESULTS_FILE"

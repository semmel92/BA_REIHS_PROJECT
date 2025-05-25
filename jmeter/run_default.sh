#!/bin/bash

echo ""
echo "🚀 Starte DEFAULT-Baseline-Test (backend-a + backend-b) mit JMeter + Ressourcenmonitoring"

# 1. Zeiterfassung + Test-ID generieren
start_time=$(date +%s)
timestamp_full=$(date +"%Y-%m-%d_%H-%M-%S")
timestamp_short=$(date +"%H-%M-%S")
TEST_ID="default_${timestamp_full}"

# 2. Ergebnisverzeichnis vorbereiten
RESULT_DIR="results/${TEST_ID}"
mkdir -p "$RESULT_DIR"
echo "$TEST_ID" > "$RESULT_DIR/test_id.txt"

# 3. Start-Annotation in Grafana setzen (optional)
echo "📝 Setze Start-Annotation in Grafana..."
curl -s -X POST http://localhost:3000/api/annotations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DEIN_GRAFANA_API_KEY" \
  -d '{
    "tags": ["loadtest", "'"$TEST_ID"'"],
    "text": "Start Test: '"$TEST_ID"'",
    "time": '$(($(date +%s%N)/1000000))'
  }'

# 4. Ressourcen-Monitoring starten
STATS_FILE="${TEST_ID}_docker_stats_live.csv"
echo "📊 Starte Ressourcenüberwachung → ${STATS_FILE} ..."
(
  while true; do
    docker stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}}" >> "$RESULT_DIR/$STATS_FILE"
    sleep 0.5
  done
) &
STATS_PID=$!
echo "# --- TEST_START: $(date +%s) ---" >> "$RESULT_DIR/$STATS_FILE"

# 5. JMeter-Test ausführen
JMETER_RESULTS_FILE="${TEST_ID}_results.jtl"
echo "🎯 Starte JMeter-Test (8081 + 8082) → ${JMETER_RESULTS_FILE} ..."
docker run --rm \
  -v "$(pwd)/default_test.jmx:/test.jmx" \
  -v "$(pwd)/$RESULT_DIR:/results" \
  justb4/jmeter \
  -n -t /test.jmx -l /results/$JMETER_RESULTS_FILE -e -o /results/report

# 6. Ressourcen-Monitoring beenden
echo "🛑 Beende Ressourcenüberwachung..."
echo "# --- TEST_END: $(date +%s) ---" >> "$RESULT_DIR/$STATS_FILE"
kill "$STATS_PID" 2>/dev/null

# 7. End-Annotation in Grafana setzen (optional)
echo "📝 Setze End-Annotation in Grafana..."
curl -s -X POST http://localhost:3000/api/annotations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DEIN_GRAFANA_API_KEY" \
  -d '{
    "tags": ["loadtest", "'"$TEST_ID"'"],
    "text": "Ende Test: '"$TEST_ID"'",
    "time": '$(($(date +%s%N)/1000000))'
  }'

# 8. Dauer anzeigen
end_time=$(date +%s)
duration=$((end_time - start_time))

# 9. Zusammenfassung
echo ""
echo "✅ Default-Test abgeschlossen in ${duration} Sekunden."
echo "🆔 TEST-ID: $TEST_ID"
echo "📁 Ergebnisse: $RESULT_DIR"
echo "📊 HTML-Report: $RESULT_DIR/report/index.html"
echo "📈 Ressourcenverbrauch: $RESULT_DIR/$STATS_FILE"
echo "📄 JMeter-Daten: $RESULT_DIR/$JMETER_RESULTS_FILE"

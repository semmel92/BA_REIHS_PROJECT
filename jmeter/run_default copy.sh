#!/bin/bash

echo ""
echo "Starte Default Test mit JMeter"

# Testkonfiguration
NUM_THREADS=500
RAMP_UP=0
LOOPS=150
TIMER_DELAY=0
TOTAL_REQUESTS=$((NUM_THREADS * LOOPS * 2))

GRAFANA_API_KEY="glsa_7ftdXcd0mmwcU8THUh4l06BLiPZJvv2q_1a2101c0"
GRAFANA_URL="http://localhost:3000"
DASHBOARD_UID="myservice-overview"

# Verzeichnisse
start_time_unix=$(date +%s)
start_time_ms=$(($(date +%s%N)/1000000))
timestamp_full=$(date +"%Y-%m-%d_%H-%M-%S")
test_id="test_${timestamp_full}_default"
export TEST_ID="$test_id"
echo "Test-ID für diesen Lauf: $TEST_ID"
timestamp_short=$(date +"%H-%M-%S")
RESULT_DIR="results/default_${timestamp_full}"
mkdir -p "$RESULT_DIR"
JMETER_RESULTS_FILE="${timestamp_short}_results.jtl"

# Annotation: TESTSTART
echo "Setze Grafana-Annotation: 🟢 Teststart"
curl -s -X POST "$GRAFANA_URL/api/annotations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -d "{
    \"dashboardUID\": \"$DASHBOARD_UID\",
    \"time\": $start_time_ms,
    \"text\": \"🟢 Teststart: Default-Test ($NUM_THREADS × $LOOPS)\",
    \"tags\": [\"default\", \"test\", \"start\"]
  }" > /dev/null

# JMeter-Testausführung
echo "Starte JMeter-Test (8081 + 8082) → ${JMETER_RESULTS_FILE} ..."
docker run --rm \
  -v "$(pwd)/default_test.jmx:/test.jmx" \
  -v "$(pwd)/$RESULT_DIR:/results" \
  justb4/jmeter \
  -n -t /test.jmx \
  -l /results/$JMETER_RESULTS_FILE \
  -JNUM_THREADS=$NUM_THREADS \
  -JLOOPS=$LOOPS \
  -JTIMER_DELAY=$TIMER_DELAY \
  -JRAMP_UP=$RAMP_UP \
  -e -o /results/report

# Annotation: TESTENDE
end_time_ms=$(($(date +%s%N)/1000000))
echo "Setze Grafana-Annotation: 🔴 Testende"
curl -s -X POST "$GRAFANA_URL/api/annotations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -d "{
    \"dashboardUID\": \"$DASHBOARD_UID\",
    \"time\": $end_time_ms,
    \"text\": \"🔴 Testende: Default-Test abgeschlossen\",
    \"tags\": [\"default\", \"test\", \"ende\"]
  }" > /dev/null

# Zusammenfassung
duration=$(( $(date +%s) - start_time_unix ))
echo ""
echo "✅ Test abgeschlossen in ${duration} Sekunden."
echo "📁 Ergebnisse: $RESULT_DIR"
echo "📊 HTML-Report: $RESULT_DIR/report/index.html"
echo "📄 JMeter-Daten: $RESULT_DIR/$JMETER_RESULTS_FILE"
#!/bin/bash

echo "🚀 Starte JMeter-Test in Docker..."

# Zeitstempel erzeugen
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Ergebnisordner anlegen
mkdir -p results/baseline

# Test ausführen
docker run --rm \
  -v "$(pwd)/baseline_test.jmx:/test.jmx" \
  -v "$(pwd)/results/baseline:/results" \
  justb4/jmeter \
  -n -t /test.jmx -l /results/result_$timestamp.jtl -e -o /results/report_$timestamp

echo "✅ Test abgeschlossen. Ergebnisse gespeichert unter results/baseline/result_$timestamp.jtl"
echo "📊 HTML-Report gespeichert unter results/baseline/report_$timestamp"
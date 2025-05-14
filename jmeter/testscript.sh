#!/bin/bash

# Service Account Token (nicht der Benutzer-API-Key!)
GRAFANA_API_KEY="glsa_8UTPS6a6Uy04SaR6o8suEo11hl4Mqfsl_fcf5aece"

# Aktueller Zeitstempel in Millisekunden
NOW=$(date +%s%3N)

# Annotation setzen
curl -X POST http://localhost:3000/api/annotations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -d "{
    \"time\": $NOW,
    \"text\": \"📍 Testmarker über Service Account gesetzt\",
    \"tags\": [\"test\", \"service-account\"]
}"

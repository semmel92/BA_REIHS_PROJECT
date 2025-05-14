#!/bin/bash

# ---------------------- #
# 🔧 Konfiguration
# ---------------------- #

GRAFANA_API_KEY="glsa_8UTPS6a6Uy04SaR6o8suEo11hl4Mqfsl_fcf5aece"
GRAFANA_URL="http://localhost:3000"
DASHBOARD_UID="myservice-overview"  # ⚠️ <- hier UID deines Dashboards eintragen

# ---------------------- #
# ⏱️ Zeitstempel (ms)
# ---------------------- #

NOW=$(date +%s%3N)

# ---------------------- #
# 📤 Annotation senden
# ---------------------- #

RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/response.json \
  -X POST "$GRAFANA_URL/api/annotations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -d "{
    \"dashboardUID\": \"$DASHBOARD_UID\",
    \"panelId\": 0,
    \"time\": $NOW,
    \"text\": \"📍 Testmarker über API\",
    \"tags\": [\"test\", \"automatisch\", \"API\"]
  }")

# ---------------------- #
# ✅ Ergebnis prüfen
# ---------------------- #

if [[ "$RESPONSE" == "200" || "$RESPONSE" == "202" ]]; then
  echo "✅ Annotation erfolgreich gesetzt:"
  cat /tmp/response.json | jq .
else
  echo "❌ Fehler beim Setzen der Annotation (HTTP $RESPONSE)"
  echo "Antwort von Grafana:"
  cat /tmp/response.json
fi

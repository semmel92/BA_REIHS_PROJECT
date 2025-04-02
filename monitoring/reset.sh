#!/bin/bash

echo ""
read -p "❗ Diese Aktion setzt die Umgebung vollständig zurück. Fortfahren? (y/n): " confirm1
if [[ "$confirm1" != "y" ]]; then
    echo "⛔ Vorgang abgebrochen."
    exit 1
fi

echo ""
read -p "⚠️  WARNUNG: Alle Container, Volumes, Dashboards und gespeicherten Metriken werden gelöscht! (y/n): " confirm2
if [[ "$confirm2" != "y" ]]; then
    echo "⛔ Reset abgebrochen."
    exit 1
fi

echo ""
echo "🧨 Setze Umgebung zurück..."
docker-compose down -v --rmi local
echo "✅ Umgebung vollständig entfernt. Alles wurde gelöscht."

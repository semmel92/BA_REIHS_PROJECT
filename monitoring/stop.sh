#!/bin/bash

echo ""
read -p "⚠️  Möchtest du wirklich alle Container stoppen?(Daten bleiben erhalten) (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "⛔ Vorgang abgebrochen."
    exit 1
fi

echo ""
echo "🛑 Stoppe Docker-Umgebung (Daten bleiben erhalten)..."
docker-compose down
echo "✅ Umgebung gestoppt. Daten & Dashboards bleiben bestehen."

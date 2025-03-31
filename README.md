📘 Bachelorarbeit: Microservice Monitoring mit Prometheus & Grafana

✨ Projektübersicht

Dieses Projekt zeigt, wie eine einfache Microservice-Architektur mit Docker orchestriert und mithilfe von Prometheus, Node Exporter und Grafana überwacht werden kann.

Ziel ist es, Metriken wie Antwortzeit, Anfragenrate und Systemressourcen übersichtlich zu erfassen, visuell darzustellen und potenziell auf Resilienzmechanismen wie Retries oder Circuit Breaker auszubauen.

💡 Architektur

[Node Exporter]
     |
     v
[Prometheus] <---- MyService (/actuator/prometheus)
     |
     v
[Grafana]

Service

Port

Zweck

Prometheus

9090

Sammelt Metriken & stellt Query-Interface

Grafana

3000

Visualisierung von Prometheus-Daten

MyService

8080

Spring Boot Microservice mit Prometheus Export

Node Exporter

9100

Systemmetriken des Hosts

📊 Services & Pfade

MyService: Java (Spring Boot) Anwendung

Metriken unter: http://localhost:8080/actuator/prometheus

Beispiel-Endpunkt: http://localhost:8080/hello

Prometheus:

Web UI: http://localhost:9090

Konfiguration: monitoring/prometheus.yml

Grafana:

Web UI: http://localhost:3000

Dashboards: monitoring/grafana/dashboards/*.json

Provisionierung: monitoring/grafana/provisioning/

Node Exporter:

Metriken: http://localhost:9100/metrics

⚙️ Tools im Überblick

Prometheus

Zeitreihendatenbank für Metriken

Zieht Daten von Targets (z. B. MyService, Node Exporter)

Nutzt PromQL für komplexe Auswertungen

Grafana

Dashboard-basierte Visualisierung von Prometheus-Daten

Panels, Alerts, Templates möglich

Node Exporter

Exportiert Host-Metriken (CPU, RAM, Disk, Netzwerk) für Prometheus

🧪 Glossar zentraler Metriken

Begriff / Metrik

Bedeutung

*_count

Wie oft ein Event eingetreten ist

*_sum

Gesamtdauer / Gesamtwert eines Events

rate(metric[1m])

Durchschnitt pro Sekunde über 1 Minute

increase(metric[5m])

Gesamtanstieg in 5 Minuten

avg_over_time(metric[1m])

Durchschnittswert innerhalb eines Zeitraums

http_server_requests_seconds_count

Anzahl der HTTP-Requests

http_server_requests_seconds_sum

Gesamtdauer aller Requests

rate(sum/sum)

Durchschnittliche Dauer pro Request

📖 Nächste Schritte (optional)

Weitere Panels für CPU, RAM, Disk (Node Exporter)

Resilienzmechanismen (Retries, Circuit Breaker) aktivieren und messen

Alerts in Grafana definieren

Vergleich verschiedener Szenarien

🚀 Starten & Stoppen

# Start
./start.sh

# Stoppen
./stop.sh

# Voller Reset (inkl. Volumes!)
./reset.sh

🔗 Hinweis für neue Systeme

Falls das Dashboard nicht automatisch geladen wird:

UID in datasources.yaml und JSON auf "uid": "prometheus" setzen

Datei in: monitoring/grafana/dashboards/

Restart durchführen: ./reset.sh

Bei Fragen: gerne direkt in der README kommentieren oder erweitern. 🙂


# Bachelorarbeit: Monitoring & Resilienz in einer Microservice-Architektur

## 🔧 Projektüberblick

Dieses Projekt stellt eine Microservice-Architektur mit Monitoring-Setup dar. Ziel ist es, Retries, Circuit Breaker und Load Balancing experimentell zu analysieren. Grundlage bildet ein Setup mit Spring Boot, Prometheus, Grafana und Node Exporter.

## 🐳 Container & Dienste

| Container       | Port    | Beschreibung |
|-----------------|---------|--------------|
| `myservice`     | 8080    | Einfacher Spring Boot Service mit Prometheus Metriken |
| `prometheus`    | 9090    | Sammelt und speichert Metriken |
| `grafana`       | 3000    | Visualisiert Metriken aus Prometheus |
| `node-exporter` | 9100    | Exportiert Systemmetriken des Hosts |

## 📁 Projektstruktur

```
BA_REIHS_PROJECT/
├── monitoring/                 
│   ├── docker-compose.yml
│   ├── grafana/
│   │   ├── dashboards/
│   │   └── provisioning/
│   ├── prometheus.yml
├── myservice/                  
│   └── ...
├── start.sh / stop.sh / reset.sh
├── README.md
```

## ✨ Wichtigste Tools

### 🔹 Prometheus
- Open-Source Monitoring & Alerting
- Abfrage via PromQL
- Pull-Modell: Fragt Endpunkte aktiv ab (`/actuator/prometheus`)

### 🔹 Grafana
- Visualisierung der Prometheus-Daten
- Dashboards werden automatisch provisioniert
- Läuft auf: [http://localhost:3000](http://localhost:3000)

### 🔹 Node Exporter
- Exportiert Host-Metriken (CPU, RAM, Disk, Netzwerk)
- Standard-Metrik-Endpoint: [http://localhost:9100/metrics](http://localhost:9100/metrics)

## 📊 Glossar zentraler Prometheus-Metriken

| Metrik              | Bedeutung                                                   |
|---------------------|-------------------------------------------------------------|
| `*_count`           | Anzahl der Aufrufe (z. B. Anfragen)                          |
| `*_sum`             | Summe der gemessenen Werte (z. B. Antwortzeiten)            |
| `*_bucket`          | Für Histogramme: Verteilung über Zeitklassen                |
| `rate(...)`         | Änderung pro Sekunde (über Zeitfenster)                     |
| `increase(...)`     | Absoluter Anstieg innerhalb eines Zeitraums                 |
| `avg_over_time(...)`| Durchschnittlicher Wert über Zeitraum                       |

## 🚀 Starten

```bash
./start.sh   # Startet alle Container & öffnet Browser
```

## 🧹 Stoppen & Zurücksetzen

```bash
./stop.sh    # Beendet Container
./reset.sh   # Setzt Setup inkl. Volumes zurück (mit Warnung!)
```

## 📈 Dashboards

- Werden automatisch aus `grafana/dashboards` geladen
- UID-basiert mit fester Datenquelle (`uid: prometheus`)
- Änderungen am Dashboard bitte regelmäßig exportieren!

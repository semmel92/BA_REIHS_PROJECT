# Bachelorarbeit: Monitoring & Resilienz in einer Microservice-Architektur

## 🔧 Projektüberblick

Dieses Projekt stellt eine Microservice-Architektur mit integriertem Monitoring und vorbereiteten Resilienzstrategien dar. Ziel ist es, **Retries**, **Circuit Breaker** und **Load Balancing** experimentell zu untersuchen. Grundlage bildet ein Setup mit **Spring Boot**, **Prometheus**, **Grafana** und **Node Exporter**.

Die Resilienzstrategien sind bewusst **modular und deaktivierbar** gehalten (z. B. über Profile), um realitätsnahe Tests zu ermöglichen.

## 🐳 Container & Dienste

| Container       | Port    | Beschreibung |
|-----------------|---------|--------------|
| `myservice`     | 8080    | Zentraler Service, der andere Backends aufruft (`/call-a`, `/call-b`) |
| `backend-a`     | 8081    | Simpler Backend-Service A (`/data`) |
| `backend-b`     | 8082    | Simpler Backend-Service B (`/data`) |
| `prometheus`    | 9090    | Sammelt und speichert Metriken |
| `grafana`       | 3000    | Visualisiert Metriken aus Prometheus |
| `node-exporter` | 9100    | Exportiert Systemmetriken des Hosts |

## 📁 Projektstruktur

```
BA_REIHS_PROJECT/
├── backend-a/
├── backend-b/
├── myservice/
│   ├── src/main/java/com/example/myservice/
│   ├── src/main/resources/application.yml
│   └── ...
├── monitoring/
│   ├── docker-compose.yml
│   ├── grafana/
│   │   ├── dashboards/
│   │   └── provisioning/
│   ├── prometheus.yml
│   └── .env (Profilsteuerung für Resilienzstrategien)
├── start.sh / stop.sh / reset.sh
├── README.md
```

## ✨ Wichtigste Tools

### 🔹 Prometheus
- Open-Source Monitoring & Alerting
- Pull-Modell: Fragt Endpunkte aktiv ab (`/actuator/prometheus`)
- Abfragen über PromQL

### 🔹 Grafana
- Visualisiert Metriken aus Prometheus
- Dashboards werden automatisch provisioniert
- Standard-Zugang: [http://localhost:3000](http://localhost:3000)

### 🔹 Node Exporter
- Exportiert Host-Metriken (CPU, RAM, Disk, Netzwerk)
- Endpunkt: [http://localhost:9100/metrics](http://localhost:9100/metrics)

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
./start.sh
```

Das Skript:
- fragt beim ersten Start, ob Retry aktiviert werden soll
- speichert die Auswahl in `.env`
- startet alle Container & öffnet wichtige Endpunkte im Browser

## 🧹 Stoppen & Zurücksetzen

```bash
./stop.sh    # Stoppt alle Container (Daten bleiben erhalten)
./reset.sh   # Löscht Container, Volumes und Dashboards vollständig (mit Warnung)
```

## ⚙️ Konfigurierbare Resilienzstrategien

- Retry kann via Profil aktiviert werden:
  ```bash
  SPRING_PROFILES_ACTIVE=retry ./gradlew bootRun
  ```
- Oder im Docker Compose via `.env`:
  ```env
  SPRING_PROFILES_ACTIVE=retry
  ```

## 📈 Dashboards

- Werden automatisch aus `grafana/dashboards` geladen
- UID-basiert mit fixer Datenquelle (`uid: prometheus`)
- Änderungen an Dashboards sollten regelmäßig exportiert werden

## Settings fürs Jupyter Book

- Aktivieren der Umgebung
source jmeter/.venv/bin/activate

## Testablauf Client und Serverzeitig 

L1 - circuitbreaker_test.jmx || serverbreaker_test.jmx
        <stringProp name="ThreadGroup.num_threads">20</stringProp>
        <stringProp name="ThreadGroup.ramp_time">10</stringProp>
        <stringProp name="LoopController.loops">50</stringProp>

BackendAController.java

    @GetMapping("/unstable")
    public String unstable() {
        double randomValue = Math.random();
        System.out.println("Zufallswert: " + randomValue);
        if (randomValue < 0.0) {
            throw new RuntimeException("Simulierter Fehler");
        }
        return "Stabil genug";
    }

L2 - circuitbreaker_test.jmx
        <stringProp name="ThreadGroup.num_threads">100</stringProp>
        <stringProp name="ThreadGroup.ramp_time">0</stringProp>
        <stringProp name="LoopController.loops">100</stringProp>

BackendAController.java

    @GetMapping("/unstable")
    public String unstable() {
        double randomValue = Math.random();
        System.out.println("Zufallswert: " + randomValue);
        if (randomValue < 0.3) {
            throw new RuntimeException("Simulierter Fehler");
        }
        return "Stabil genug";
    }

L3 - circuitbreaker_test.jmx
        <stringProp name="ThreadGroup.num_threads">500</stringProp>
        <stringProp name="ThreadGroup.ramp_time">0</stringProp>
        <stringProp name="LoopController.loops">150</stringProp>

BackendAController.java

    @GetMapping("/unstable")
    public String unstable() {
        double randomValue = Math.random();
        System.out.println("Zufallswert: " + randomValue);
        if (randomValue < 1) {
            throw new RuntimeException("Simulierter Fehler");
        }
        return "Stabil genug";
    }




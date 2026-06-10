# PV-Logger

Containerisiertes Monitoring-System für einen Photovoltaik-Wechselrichter — gebaut mit n8n, PostgreSQL und Docker auf einem Raspberry Pi.

## Was das System macht

- Liest täglich Produktionsdaten (erzeugt / verbraucht / eingespeist) vom Wechselrichter per HTTP aus
- Speichert die Messwerte in PostgreSQL
- Beantwortet Telegram-Befehle: Strompreise verwalten, Auswertungen abrufen, USt-Berechnung für die Steuererklärung
- Exponiert Webhooks öffentlich über einen Ngrok-Tunnel

```
Wechselrichter (LAN)
  └─ HTTP GET /yields.json
        │
        ▼
  n8n: Dayly_Collector  ──►  PostgreSQL
       (täglich 10:00)

  Telegram-Bot
  └─ Webhook via Ngrok
        │
        ▼
  n8n: HouseControl  ──►  PostgreSQL
```

## Projektstruktur

```
PV-Logger/
├── pv-logger/               # Produktivsystem (läuft auf dem Raspberry Pi)
│   ├── docker-compose.yml
│   ├── Dayly_Collector.json # n8n-Workflow: Wechselrichter-Datenerfassung
│   ├── HouseControl.json    # n8n-Workflow: Telegram-Befehlsverarbeitung
│   ├── dump.sql             # Datenbankschema (Baseline)
│   └── migrations/          # SQL-Migrationen
├── n8nPVMonitoring/         # Demo-Repo: lauffähiges Minimalbeispiel
│   └── n8n-pv-monitor-demo/ # Mock-Wechselrichter + zwei n8n-Workflows + Docker-Setup
├── docs/
│   ├── ENTWICKLER.md        # Technische Dokumentation
│   └── ANWENDER.md          # Telegram-Befehlsreferenz
├── deploy.sh                # Deploy-Skript: Mac → Raspberry Pi
└── pull-backups.sh          # Backups vom Pi synchronisieren
```

## Demo ausprobieren

Das Verzeichnis `n8nPVMonitoring/n8n-pv-monitor-demo/` enthält ein vollständiges, lokal lauffähiges Beispiel mit Mock-Wechselrichter und zwei n8n-Workflows (Basisdatenerfassung + KI-Tagesauswertung via Claude API).

→ [Demo-Anleitung](n8nPVMonitoring/n8n-pv-monitor-demo/README.md)

## Stack

| Komponente | Technologie |
|---|---|
| Workflow-Engine | [n8n](https://n8n.io) |
| Datenbank | PostgreSQL |
| Container | Docker / Docker Compose |
| Hardware | Raspberry Pi |
| Benachrichtigungen | Telegram Bot API |
| KI-Auswertung | Anthropic Claude API |
| Tunnel | Ngrok |

## Dokumentation

- [Entwicklerdokumentation](docs/ENTWICKLER.md) — Architektur, SQL-Schema, JavaScript-Funktionen
- [Anwenderdokumentation](docs/ANWENDER.md) — Telegram-Befehle und Bedienung

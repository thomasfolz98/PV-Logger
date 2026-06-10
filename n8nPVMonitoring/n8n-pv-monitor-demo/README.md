# n8n PV Monitor Demo

Demo-Stack für das YouTube-Video **„n8n als IoT-Datenlogger: PV-Monitoring mit HTTP,
PostgreSQL, Telegram — und KI-Analyse"**.

Simuliert ein vollständiges PV-Monitoring-System — **kein echter Wechselrichter nötig**.
Clone & Run in unter 5 Minuten.

---

## Was läuft hier?

```
Mock-Wechselrichter (FastAPI)
        │
        │  GET /api/realtime  (alle 5 Min.)
        ▼
    n8n Basis-Workflow
        ├── HTTP Request  →  Code (Normalisierung)  →  PostgreSQL INSERT
        └── IF (Leistung < 50 W)  →  Telegram Alert ⚠️

    n8n KI-Workflow  (täglich 21:00 Uhr)
        ├── PostgreSQL  →  stündliche Aggregation
        ├── Code  →  Prompt aufbauen
        ├── HTTP Request  →  Claude API (claude-haiku)
        └── Telegram  →  Tagesauswertung 🌞
```

Der Mock-Wechselrichter simuliert realistische PV-Daten: Gaußkurve mit Peak um 12:00 Uhr,
tägliche Maximalleistung 2500–4200 W, Bewölkungs-Einbrüche, deterministisch pro Minute.

---

## Voraussetzungen

- [Docker](https://docs.docker.com/get-docker/) + Docker Compose (v2)
- Telegram Bot Token + Chat ID — [Anleitung](https://core.telegram.org/bots/tutorial) *(optional für Benachrichtigungen)*
- [Anthropic API Key](https://console.anthropic.com/) *(optional für KI-Auswertung)*

---

## Setup in 3 Schritten

```bash
# 1. Repository klonen
git clone https://github.com/YOUR_USERNAME/n8n-pv-monitor-demo
cd n8n-pv-monitor-demo

# 2. Verzeichnisse + .env anlegen (einmalig)
make setup
# Öffne die .env und trage deine Tokens ein (Telegram, Anthropic)
# Für einen ersten Test kannst du die Felder auch leer lassen.

# 3. Stack starten
make start
```

Nach ~30 Sekunden ist alles bereit:

| Service | URL |
|---------|-----|
| n8n Workflow-Editor | http://localhost:5678 |
| Mock-Wechselrichter Momentanwert | http://localhost:8000/api/realtime |
| Mock-Wechselrichter Verlauf (12 h) | http://localhost:8000/api/history?hours=12 |

---

## Befehle

```bash
make setup      # Einmalig: Datenverzeichnisse + .env anlegen
make start      # Stack starten
make stop       # Stack stoppen (Daten bleiben erhalten)
make restart    # Stack neu starten
make logs       # Live-Logs aller Container
make logs-n8n   # Logs nur von n8n
make status     # Container-Status anzeigen
make clean      # Alles löschen inkl. gespeicherter Daten (unwiderruflich)
```

---

## Telegram einrichten (optional)

Telegram-Nachrichten benötigen zwei Werte in der `.env`:

**1. Bot Token** — einen neuen Bot anlegen:
- In Telegram den Bot `@BotFather` öffnen
- `/newbot` schicken, Namen und Username vergeben
- Den angezeigten Token kopieren → `TELEGRAM_BOT_TOKEN=` in `.env`

**2. Chat ID** — deine persönliche ID herausfinden:
- In Telegram den Bot `@userinfobot` öffnen und `/start` schicken
- Die angezeigte `Id:` kopieren → `TELEGRAM_CHAT_ID=` in `.env`

Danach `make restart` ausführen, damit n8n die neuen Werte übernimmt.

---

## Claude API einrichten (optional, für KI-Auswertung)

Für den KI-Workflow wird ein Anthropic API Key benötigt:

**1. Key erstellen:**
- Auf [console.anthropic.com](https://console.anthropic.com) registrieren / einloggen
- Unter *API Keys* → *Create Key* einen neuen Key anlegen
- Den Key kopieren → `ANTHROPIC_API_KEY=` in `.env` eintragen

**2. Key in n8n hinterlegen:**
- KI-Workflow öffnen → HTTP-Request-Node *"Claude API"* anklicken
- Im Tab *Headers*: Wert des Headers `x-api-key` auf den kopierten Key setzen

Danach `make restart` ausführen.

> **Hinweis:** Die Nutzung der Claude API ist kostenpflichtig (Pay-as-you-go).
> Für diesen Workflow fallen bei täglicher Ausführung Cent-Beträge an.
> Guthaben aufladen unter *console.anthropic.com → Billing*.

---

## Workflows importieren

Nach dem ersten Start von n8n (http://localhost:5678):

1. **Credentials einrichten** (einmalig):
   - Linkes Menü → *Credentials* → *Add Credential*
   - **PostgreSQL**: Host `postgres`, DB `pvmonitor`, User `pv`, Password `pv`
   - **Telegram**: Bot Token aus `.env` eintragen *(nur wenn Telegram gewünscht)*

2. **Basis-Workflow importieren**:
   - Linkes Menü → *Workflows* → *Add Workflow* → Import from File
   - Datei: `n8n-workflows/basis_workflow.json`
   - Credentials zuweisen (PostgreSQL + Telegram Nodes)
   - Workflow aktivieren (Toggle oben rechts)

3. **KI-Workflow importieren** *(optional)*:
   - Gleicher Ablauf mit `n8n-workflows/ki_workflow.json`
   - Zusätzlich: Anthropic API Key als `x-api-key` Header konfigurieren

> **Hinweis:** Alle Workflows werden mit `active: false` importiert — du aktivierst sie
> bewusst selbst, damit kein ungewollter Traffic entsteht.

---

## Was du siehst

Nach Aktivierung des Basis-Workflows:

- Alle 5 Minuten fragt n8n den Mock-Wechselrichter ab
- Die Werte landen in PostgreSQL (Tabelle `pv_readings`)
- Fällt die Leistung zwischen 9–21 Uhr unter 50 W → Telegram-Alert

Der KI-Workflow läuft täglich um 21:00 Uhr und schickt eine natürlichsprachliche
Zusammenfassung per Telegram, generiert von Claude:

> „Heute 18,4 kWh — starker Solartag. Beste Stunde war 12 Uhr mit 3.850 W.
> Kurzer Einbruch um 14–14:45 Uhr (vermutlich Bewölkung). Tag liegt 22% über
> dem bisherigen Monatsdurchschnitt."

---

## Anpassung an einen echten Wechselrichter

Im **Basis-Workflow** den Node *„Wechselrichterdaten holen"* anpassen:

1. URL ändern auf die IP/den Hostname deines Wechselrichters
2. Response-Felder im *„Daten normalisieren"* Code-Node an dein API-Format anpassen
3. Mock-Inverter-Service aus `docker-compose.yml` entfernen

Getestete Wechselrichter: Kostal PLENTICORE, SolarEdge (über Modbus-Proxy), Fronius Symo.

---

## Lizenz

MIT — fork it, build on it, ship it.

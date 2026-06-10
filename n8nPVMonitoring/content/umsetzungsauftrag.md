# Umsetzungsauftrag: n8n-pv-monitor-demo (vollständiges Demo-Repo)

## Kontext

Dieses Repo ist Demo-Material für ein YouTube-Video über n8n als IoT-Datenlogger.
Ziel: Ein Zuschauer klont das Repo, führt `docker compose up -d` aus und sieht
nach wenigen Minuten einen laufenden PV-Monitoring-Stack — ohne echten Wechselrichter.

Das Repo heißt: `n8n-pv-monitor-demo`

---

## Ziel-Verzeichnisstruktur

```
n8n-pv-monitor-demo/
├── .env.example
├── docker-compose.yml
├── README.md
│
├── mock-inverter/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
│
├── db/
│   └── init.sql
│
├── n8n-workflows/
│   ├── basis_workflow.json
│   └── ki_workflow.json
│
└── claude-integration/
    └── prompt_template.txt
```

Baue alle diese Dateien vollständig aus — keine Platzhalter, keine TODOs.

---

## Datei 1: mock-inverter/main.py

FastAPI-Service der einen PV-Wechselrichter simuliert.

**Endpoints:**

`GET /api/realtime` — Momentanwerte
```json
{
  "timestamp": "2026-05-07T11:32:00",
  "power_w": 1842,
  "energy_today_wh": 3240,
  "temperature_c": 38.5,
  "status": "producing"
}
```

`GET /api/history?hours=24` — stündliche Aggregationen
```json
[
  {"hour": "2026-05-07T10:00:00", "avg_power_w": 1650, "energy_wh": 1650},
  {"hour": "2026-05-07T11:00:00", "avg_power_w": 2100, "energy_wh": 2100}
]
```

**Simulationslogik:**
- Leistungskurve (power_w): Gaußkurve, Peak um 12:00 Uhr Ortszeit
- Tagesmaximum: zufällig zwischen 2500–4200 W (täglich neu gesetzt, nicht pro Request)
- Rauschen: ±10–15% auf den Momentanwert
- Bewölkungs-Einbrüche: ~2–3 mal pro Tag, Leistung fällt für 15–45 Min. auf 20–50%
- Vor 06:00 und nach 21:00: power_w = 0
- energy_today_wh: kumulierte Energie seit Mitternacht (Integral der Kurve)
- temperature_c: korreliert mit power_w, Bereich 25–65 °C
- status: "producing" wenn power_w > 0, sonst "standby"
- Kein Datenbankzugriff — alle Werte werden deterministisch zur Laufzeit berechnet

**Stack:** Python 3.11+, FastAPI, Port 8000, kein Auth, kein HTTPS.

## Datei 2: mock-inverter/requirements.txt

```
fastapi
uvicorn[standard]
```

## Datei 3: mock-inverter/Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Datei 4: db/init.sql

```sql
CREATE TABLE IF NOT EXISTS pv_readings (
    id          SERIAL PRIMARY KEY,
    ts          TIMESTAMPTZ NOT NULL DEFAULT now(),
    power_w     INTEGER,
    energy_wh   INTEGER,
    temp_c      NUMERIC(4,1)
);

CREATE INDEX IF NOT EXISTS idx_pv_readings_ts ON pv_readings(ts DESC);
```

---

## Datei 5: .env.example

```env
# Telegram
TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here

# Claude API
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# PostgreSQL (Defaults passen zum docker-compose.yml — nur ändern wenn nötig)
POSTGRES_DB=pvmonitor
POSTGRES_USER=pv
POSTGRES_PASSWORD=pv
```

---

## Datei 6: docker-compose.yml

```yaml
services:
  postgres:
    image: postgres:15
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-pvmonitor}
      POSTGRES_USER: ${POSTGRES_USER:-pv}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-pv}
    volumes:
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-pv}"]
      interval: 5s
      timeout: 5s
      retries: 5

  mock-inverter:
    build: ./mock-inverter
    restart: unless-stopped
    ports:
      - "8000:8000"

  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB:-pvmonitor}
      - DB_POSTGRESDB_USER=${POSTGRES_USER:-pv}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD:-pv}
      - N8N_BASIC_AUTH_ACTIVE=false
      - WEBHOOK_URL=http://localhost:5678
    depends_on:
      postgres:
        condition: service_healthy
      mock-inverter:
        condition: service_started
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  postgres_data:
  n8n_data:
```

---

## Datei 7: n8n-workflows/basis_workflow.json

Exportierbarer n8n-Workflow (JSON, n8n-Format).

**Nodes:**
1. **Schedule Trigger** — alle 5 Minuten
2. **HTTP Request** — GET `http://mock-inverter:8000/api/realtime`
3. **Code Node (JavaScript)** — Felder normalisieren:
   ```js
   return [{
     json: {
       power_w: $input.first().json.power_w,
       energy_wh: $input.first().json.energy_today_wh,
       temp_c: $input.first().json.temperature_c
     }
   }];
   ```
4. **PostgreSQL Node** — INSERT in pv_readings (power_w, energy_wh, temp_c)
5. **IF Node** — Bedingung: `power_w < 50` AND Stunde zwischen 9 und 18
6. **Telegram Node** — Sendet Alert: „⚠️ PV-Anlage: Unerwarteter Ausfall um {{$now}}"

Erzeuge valides n8n-Workflow-JSON (Format wie n8n es beim Export erzeugt,
mit `nodes`, `connections`, `settings`, `id`, `name`, `active: false`).

---

## Datei 8: n8n-workflows/ki_workflow.json

Exportierbarer n8n-Workflow (JSON, n8n-Format).

**Nodes:**
1. **Schedule Trigger** — täglich 21:00 Uhr
2. **PostgreSQL Node** — Abfrage:
   ```sql
   SELECT
     date_trunc('hour', ts) AS hour,
     ROUND(AVG(power_w)) AS avg_power_w,
     MAX(energy_wh) - MIN(energy_wh) AS energy_wh
   FROM pv_readings
   WHERE ts >= CURRENT_DATE
   GROUP BY 1
   ORDER BY 1;
   ```
3. **Code Node (JavaScript)** — Daten als kompakten String für den Prompt zusammenbauen
4. **HTTP Request** — POST `https://api.anthropic.com/v1/messages`
   - Header: `x-api-key: {{$env.ANTHROPIC_API_KEY}}`, `anthropic-version: 2023-06-01`
   - Body: Model `claude-haiku-4-5-20251001`, max_tokens 300, prompt aus Schritt 3
5. **Code Node** — `content[0].text` aus Response extrahieren
6. **Telegram Node** — Auswertungstext senden

Erzeuge valides n8n-Workflow-JSON (gleiche Anforderungen wie basis_workflow.json).

---

## Datei 9: claude-integration/prompt_template.txt

```
Analysiere diese stündlichen PV-Ertragsdaten von heute und schreibe eine kurze
deutsche Zusammenfassung für den Anlagenbesitzer (maximal 5 Sätze).

Daten (stündlich, Format: Uhrzeit | Durchschnittsleistung W | Energie Wh):
{{DATA}}

Gib folgendes an:
- Gesamtertrag des Tages in kWh
- Beste Stunde (Uhrzeit + Leistung)
- Auffällige Einbrüche falls vorhanden
- Kurze Einschätzung ob der Tag gut, durchschnittlich oder schwach war

Schreibe direkt und ohne Einleitung, als würdest du dem Besitzer eine
WhatsApp-Nachricht schicken.
```

---

## Datei 10: README.md

Aufbau:

```markdown
# n8n PV Monitor Demo

Demo-Stack für das YouTube-Video „n8n als IoT-Datenlogger".
Simuliert ein vollständiges PV-Monitoring-System — kein echter Wechselrichter nötig.

## Was läuft hier?

[2–3 Sätze Beschreibung + ASCII-Diagramm des Datenflusses]

## Voraussetzungen

- Docker + Docker Compose
- Telegram Bot Token (optional für Benachrichtigungen)
- Anthropic API Key (optional für KI-Auswertung)

## Setup in 3 Schritten

1. `git clone https://github.com/dein-name/n8n-pv-monitor-demo`
2. `cp .env.example .env` — Tokens eintragen (oder leer lassen für erste Tests)
3. `docker compose up -d`

Dann: Browser → http://localhost:5678 (n8n UI)

## Workflows importieren

[Kurze Anleitung: n8n UI → Import from File → basis_workflow.json]

## Was du siehst

[Beschreibung: Mock-Inverter gibt alle 5 Min. Daten, n8n schreibt in PostgreSQL,
abends kommt KI-Auswertung per Telegram]

## Anpassung an echten Wechselrichter

[1 Paragraph: HTTP Request Node anpassen, eigene API-URL eintragen]

## Lizenz

MIT
```

---

## Hinweise für die Umsetzung

- Alle Secrets kommen aus `.env` — nie direkt im Code
- Die n8n-Workflows sollen als `active: false` exportiert werden (Nutzer aktiviert manuell)
- mock-inverter braucht kein Port-Mapping zwingend, aber Port 8000 nach außen ist für
  Debugging hilfreich (im docker-compose.yml bereits so vorgesehen)
- PostgreSQL-Verbindung im n8n-Workflow als Credential-Referenz — Anleitung im README
- Python-Code in main.py: deterministisch pro Minute (gleiche Uhrzeit = gleicher Wert),
  nicht zufällig pro Request (sonst springen die Werte bei schnellen Reloads)

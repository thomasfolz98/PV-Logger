# GitHub Demo-Repo Plan: n8n PV Monitoring

Stand: 2026-05-07

Repo-Name: `n8n-pv-monitor-demo`
Ziel: Clone & Run ohne echten Wechselrichter — vollständig containerisiert.

---

## Repo-Struktur

```
n8n-pv-monitor-demo/
├── docker-compose.yml          — n8n + PostgreSQL + Mock-Inverter
├── README.md                   — Setup in <5 Min.
│
├── mock-inverter/              — Fake-Wechselrichter-API
│   ├── Dockerfile
│   ├── main.py                 — FastAPI, gibt realistische Zufallsdaten zurück
│   └── requirements.txt
│
├── db/
│   └── init.sql                — PostgreSQL Schema (pv_readings Tabelle)
│
├── n8n-workflows/
│   ├── basis_workflow.json     — Export: Zeittrigger → HTTP → JS → PG → Telegram
│   └── ki_workflow.json        — Export: Abend-Trigger → PG → Claude API → Telegram
│
└── claude-integration/
    └── prompt_template.txt     — Prompt für die KI-Tagesauswertung
```

---

## Mock-Inverter API

FastAPI-Service der den echten Wechselrichter simuliert.

**Endpoint:** `GET /api/realtime`

**Response (realistisch simuliert):**
```json
{
  "timestamp": "2026-05-07T11:32:00",
  "power_w": 1842,
  "energy_today_wh": 3240,
  "temperature_c": 38.5,
  "status": "producing"
}
```

Leistungskurve folgt einer Tagesganglinie (Gaußkurve, Peak um 12:00),
mit zufälligem Rauschen (±15%) und simulierten Bewölkungs-Einbrüchen.

---

## PostgreSQL Schema

```sql
CREATE TABLE pv_readings (
    id          SERIAL PRIMARY KEY,
    ts          TIMESTAMPTZ NOT NULL DEFAULT now(),
    power_w     INTEGER,
    energy_wh   INTEGER,
    temp_c      NUMERIC(4,1)
);

CREATE INDEX idx_pv_readings_ts ON pv_readings(ts DESC);
```

---

## n8n Basis-Workflow (Nodes)

1. **Schedule Trigger** — alle 5 Minuten
2. **HTTP Request** → `http://mock-inverter:8000/api/realtime`
3. **Function Node (JavaScript)** — Daten normalisieren, Felder umbenennen
4. **PostgreSQL Node** — INSERT into pv_readings
5. **IF Node** — power_w < 50 AND Tageszeit > 09:00? (unerwarteter Ausfall)
6. **Telegram Node** — Alert bei Ausfall

---

## n8n KI-Workflow (Nodes)

1. **Schedule Trigger** — täglich 21:00
2. **PostgreSQL Node** — Tageswerte aggregiert (`SUM`, `MAX`, `AVG`, stündlich)
3. **HTTP Request** → Claude API (`/v1/messages`)
4. **Function Node** — Response parsen
5. **Telegram Node** — Auswertungstext senden

---

## docker-compose.yml (Entwurf)

```yaml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: pvmonitor
      POSTGRES_USER: pv
      POSTGRES_PASSWORD: pv
    volumes:
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql

  mock-inverter:
    build: ./mock-inverter
    ports:
      - "8000:8000"

  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_DATABASE=pvmonitor
      - DB_POSTGRESDB_USER=pv
      - DB_POSTGRESDB_PASSWORD=pv
    depends_on:
      - postgres
      - mock-inverter
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

---

## README-Struktur

1. Was ist das? (2 Sätze)
2. Voraussetzungen: Docker, Telegram Bot Token, Claude API Key
3. Setup in 3 Schritten:
   - `git clone ...`
   - `.env` anlegen (Telegram Token, Claude API Key)
   - `docker compose up -d`
4. n8n-Workflows importieren (Screenshot)
5. Was du siehst: n8n UI, Telegram-Nachrichten
6. Anpassung an echten Wechselrichter (kurzer Hinweis)

---

## Offene Punkte

- [ ] Claude API Key Handling: `.env`-Datei, nicht im Repo
- [ ] Telegram Bot für Demo einrichten (separater Test-Bot)
- [ ] n8n Workflow-Export testen (JSON-Format stabil zwischen n8n-Versionen?)
- [ ] Leistungskurve der Mock-API realistisch genug? → Matplotlib-Plot zur Prüfung

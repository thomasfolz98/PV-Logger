# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

A **photovoltaic (solar) monitoring and home control system** that:
- Collects daily solar production data from a local PV inverter via HTTP
- Stores metrics (produced/consumed/grid-injected Wh) in PostgreSQL
- Accepts electricity pricing updates via Telegram commands
- Calculates VAT on self-consumption for the German tax return (Elster)
- Provides production/consumption statistics via Telegram
- Exposes n8n webhooks publicly via an ngrok tunnel

All logic lives in **n8n workflows** (JSON files). There is no application server or build step — everything runs inside Docker containers on a Raspberry Pi.

## Project Layout

```
PV-Logger/
├── CLAUDE.md
├── .gitignore
├── deploy.sh                # Mac → Pi: rsync + Migrationen (Haupt-Deploy-Skript)
├── pull-backups.sh          # Mac-side script: rsync backups from Pi
├── backups/                 # Local backup copies (gitignore)
├── docs/
│   ├── ENTWICKLER.md        # Developer documentation (German)
│   └── ANWENDER.md          # End-user documentation (German)
└── pv-logger/               # Deployable artefacts (lives on Pi at /mnt/ssd/docker/pv-logger/)
    ├── docker-compose.yml
    ├── .env                 # Credentials (not in git)
    ├── backup.sh            # Daily pg_dump script (cron on Pi, 02:00)
    ├── run_migrations.sh    # Migrationen idempotent einspielen (wird von deploy.sh aufgerufen)
    ├── update.sh            # Docker-Images aktualisieren (lokal auf Pi ausführen)
    ├── Dayly_Collector.json # n8n workflow: PV data collection
    ├── HouseControl.json    # n8n workflow: Telegram command handler
    ├── dump.sql             # Initial DB schema (baseline)
    ├── migrations/
    │   └── 001_electricity_prices_v2.sql
    └── docs/
        ├── java_script_functions.js  # All Code-node JS in readable form
        └── pv_output_example.json    # Sample inverter API response
```

## Running the Stack

```bash
cd pv-logger

# Start all services
docker compose up -d

# Stop / update
docker compose down
docker compose pull && docker compose up -d
```

| Service | URL |
|---------|-----|
| n8n workflow editor | http://localhost:5678 |
| pgAdmin (DB GUI) | http://localhost:9081 |
| PostgreSQL direct | localhost:9980 |
| Ngrok dashboard | http://localhost:4040 |

## Architecture

```
PV Inverter (LAN) → HTTP GET /yields.json
    ↓
n8n: Dayly_Collector  (daily 10:00) ──→ PostgreSQL: production_data
                                             ▲
Telegram Bot ──→ Webhook via ngrok           │
    ↓                                        │
n8n: HouseControl ───────────────────────→ PostgreSQL: electricity_prices
```

**Dayly_Collector.json** — Scheduled daily. Queries last stored date, fetches inverter monthly JSON, extracts missing days via JavaScript (reads `MonthCurves.Datasets[].Data[]` by day-index), upserts into `production_data`.

**HouseControl.json** — Webhook-triggered by Telegram. Single "Parse Command" Code node routes to Switch with 5 outputs: error, /preis, /ust, /auswertung, /hilfe. Each branch has dedicated Postgres and Telegram nodes.

## Key Files

| File | Purpose |
|------|---------|
| `deploy.sh` | **Mac → Pi Deploy** (rsync + Migrationen) |
| `pull-backups.sh` | Rsync backups Pi → Mac |
| `pv-logger/docker-compose.yml` | 4-container stack definition |
| `pv-logger/.env` | DB credentials, ngrok token, timezone (not in git) |
| `pv-logger/Dayly_Collector.json` | n8n: inverter data collection workflow |
| `pv-logger/HouseControl.json` | n8n: Telegram command handler |
| `pv-logger/dump.sql` | PostgreSQL baseline schema |
| `pv-logger/migrations/001_electricity_prices_v2.sql` | Constraints + note column for electricity_prices |
| `pv-logger/run_migrations.sh` | Migrationen idempotent einspielen (Pi-seitig) |
| `pv-logger/backup.sh` | Daily pg_dump (runs on Pi via cron) |
| `pv-logger/update.sh` | Docker-Images aktualisieren (lokal auf Pi) |
| `docs/ENTWICKLER.md` | Full developer docs (SQL, JS, architecture) |
| `docs/ANWENDER.md` | User-facing Telegram command reference |
| `pv-logger/docs/java_script_functions.js` | All Code-node JS readable (not executed here) |

## Database Schema (key tables)

**`production_data`** — `date_of_production` (UNIQUE), `produced`, `consumed`, `injected` (all Wh), `unit`

**`electricity_prices`** — `price_per_kwh` (Cent/kWh), `vat_rate` (%), `valid_from`, `valid_to` (NULL = currently valid), `note`
- Constraint: only one open entry (`valid_to IS NULL`) allowed
- Constraint: no overlapping date ranges (btree_gist exclusion)

## Deployment

### Laufenden Pi aktualisieren (Normalfall, vom Mac)

```bash
# Dateien synchronisieren + ausstehende Migrationen einspielen
./deploy.sh

# Zusätzlich Docker-Images aktualisieren + Stack neustarten
./deploy.sh --full

# Nur Migrationen einspielen (ohne rsync)
./deploy.sh --migrate-only
```

> Achtung: Workflow-Änderungen (*.json) greifen erst nach manuellem Re-Import in n8n:
> http://100.80.63.62:5678 → Workflows → Import from File

### Erstinstallation (auf dem Pi)

```bash
# 1. Auf dem Pi: Verzeichnis anlegen und .env befüllen
mkdir -p /mnt/ssd/docker/pv-logger
# .env manuell anlegen (Vorlage: pv-logger/.env im Repo)

# 2. Vom Mac: Dateien deployen
./deploy.sh

# 3. Auf dem Pi: Stack starten
cd /mnt/ssd/docker/pv-logger
docker compose up -d

# 4. Datenbankschema einspielen
docker exec -i housecontrol-db psql -U housecontrol_user housecontrol-db < dump.sql

# 5. Migrationen anwenden
bash run_migrations.sh

# 6. n8n aufrufen und Workflows importieren
#    http://<IP>:5678 → Workflows → Import
#    → Dayly_Collector.json
#    → HouseControl.json
#    Anschliessend Credentials (Postgres, Telegram) in n8n einrichten.

# 7. Backup-Cron einrichten
chmod +x backup.sh
(crontab -l; echo "0 2 * * * /mnt/ssd/docker/pv-logger/backup.sh >> /mnt/ssd/docker/pv-logger/backups/backup.log 2>&1") | crontab -
```

### Migrations-Tracking

Angewendete Migrationen werden in der Tabelle `applied_migrations` der Datenbank protokolliert.
`run_migrations.sh` legt die Tabelle automatisch an und überspringt bereits angewendete Migrationen.

```sql
SELECT * FROM applied_migrations ORDER BY applied_at;
```

### Neue Migration hinzufügen

1. Datei `pv-logger/migrations/NNN_beschreibung.sql` anlegen
2. `./deploy.sh` ausführen – die Migration wird automatisch erkannt und angewendet

## Workflow Development

Edit workflows in n8n UI at http://localhost:5678 (or Pi IP). To persist changes:
1. Export workflow as JSON from n8n UI
2. Replace the corresponding `.json` file in `pv-logger/`
3. Keep `pv-logger/docs/java_script_functions.js` in sync with Code nodes

## Raspberry Pi Access

```bash
ssh -i ~/.ssh/pv_logger pi@100.80.63.62   # key-based, no password needed
./pull-backups.sh                          # sync backups to Mac
```

Pi path: `/mnt/ssd/docker/pv-logger/`

## Inverter Connectivity

The inverter is accessed by hostname `INV009199540008` — must resolve on the local network where Docker runs. If the HTTP Request node fails, check network connectivity to the inverter first.

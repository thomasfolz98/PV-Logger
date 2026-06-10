# PV-Logger – Entwicklerdokumentation

## Systemübersicht

PV-Logger ist ein containerisiertes Monitoring-System für einen Photovoltaik-Wechselrichter im Privathaus. Es liest täglich Produktionsdaten aus, speichert sie in PostgreSQL und erlaubt über Telegram die Verwaltung von Strompreisen sowie die Abfrage von Auswertungen (inkl. USt-Berechnung für die Steuererklärung).

```
Wechselrichter (LAN)
  └─ HTTP GET /yields.json
        │
        ▼
  n8n: Dayly_Collector     ──►  PostgreSQL
       (täglich 10:00)              │
                                    │ production_data
                                    │ electricity_prices
  Telegram-Bot                      │
  └─ Webhook via Ngrok              │
        │                           │
        ▼                           ▼
  n8n: HouseControl    ────────────►

  pgAdmin  ──►  PostgreSQL (Administrationszugriff)
```

---

## Docker Stack

Definiert in `pv-logger/docker-compose.yml`. Alle Container laufen auf dem Raspberry Pi unter `/mnt/ssd/docker/pv-logger/`.

| Container | Image | Ports | Funktion |
|-----------|-------|-------|---------|
| `housecontrol-db` | `postgres:17-bullseye` | 9980:5432 | Primäre Datenbank |
| `pgadminconsole` | `elestio/pgadmin:latest` | 9081:8080 | DB-Administrations-UI |
| `n8n` | `docker.n8n.io/n8nio/n8n:latest` | 5678:5678 | Workflow-Engine |
| `ngrok` | `ngrok/ngrok:latest` | 4040:4040 | Öffentlicher Webhook-Tunnel |

**Persistente Volumes:**
- `./postgres_data` → PostgreSQL-Daten
- `./n8n_data` → n8n-Workflows, Credentials, Logs
- `./pgadmin_data` → pgAdmin-Einstellungen

**Konfiguration:** `pv-logger/.env` enthält alle Credentials (DB-Passwort, ngrok-Token, Admin-E-Mail).

---

## Datenbank-Schema

### Tabelle `production_data`

Täglich befüllte Produktionsdaten des Wechselrichters.

| Spalte | Typ | Beschreibung |
|--------|-----|-------------|
| `id` | bigserial | Primärschlüssel |
| `date_of_production` | date UNIQUE | Datum des Eintrags |
| `produced` | bigint | Erzeugte Energie in Wh |
| `consumed` | bigint | Eigenverbrauch in Wh |
| `injected` | bigint | Netzeinspeisung in Wh |
| `unit` | varchar | Einheit (immer `"Wh"`) |

**Constraint:** `UNIQUE (date_of_production)` verhindert Duplikate beim Upsert.

### Tabelle `electricity_prices`

Strompreise mit Gültigkeitszeiträumen.

| Spalte | Typ | Beschreibung |
|--------|-----|-------------|
| `id` | bigserial | Primärschlüssel |
| `price_per_kwh` | numeric(8,4) | Preis in **Cent/kWh** |
| `vat_rate` | numeric(5,2) | MwSt-Satz in % (default 19) |
| `valid_from` | date NOT NULL | Gültig ab (inklusiv) |
| `valid_to` | date | Gültig bis (inklusiv), NULL = aktuell gültig |
| `note` | text | Optionaler Kommentar |
| `created_at` | timestamp | Anlagedatum |
| `updated_at` | timestamp | Änderungsdatum |

**Constraints (seit Migration 001):**
- `one_open_price` – Unique Index: nur ein Eintrag darf `valid_to IS NULL` haben
- `no_overlapping_prices` – Exclusion Constraint via `btree_gist`: keine überlappenden Zeiträume
- `valid_range_check` – CHECK: `valid_to IS NULL OR valid_to > valid_from`

**Strompreis-Workflow (Korrektur/Nachführung):**
```sql
-- Schritt 1: Aktuellen Eintrag abschließen
UPDATE electricity_prices SET valid_to = '2026-05-31' WHERE valid_to IS NULL;

-- Schritt 2: Neuen Eintrag anlegen
INSERT INTO electricity_prices (price_per_kwh, vat_rate, valid_from, note)
VALUES (32.50, 19.00, '2026-06-01', 'Tarifwechsel');
```

---

## n8n Workflows

### Workflow 1: `Dayly_Collector.json`

**Zweck:** Täglich die Produktionsdaten des Vortages aus dem Wechselrichter holen und in die DB schreiben.

**Ablauf:**
```
Schedule Trigger (10:00 Uhr)
  ▼
Postgres: SELECT MAX(date_of_production) AS last_date FROM production_data
  ▼
HTTP Request: GET http://INV009199540008/yields.json
  ▼
Code (JavaScript): Fehlende Tage extrahieren
  ▼
Postgres: INSERT ... ON CONFLICT DO NOTHING (Upsert)
```

**JavaScript-Logik (Code-Node):**
- Liest `lastDate` aus Postgres und `apiData` vom HTTP Request
- Iteriert von `lastDate + 1` bis gestern
- Extrahiert Produced/Consumed/Injected aus `apiData.MonthCurves.Datasets`
- Die API liefert Monatsdaten; der Index `[day-1]` im Data-Array entspricht dem Tag des Monats
- Gibt Array von Tages-Objekten zurück → n8n führt den Upsert-Node für jeden Eintrag aus
- Sicherheits-Limit: max. 365 Einträge pro Lauf

**Wechselrichter-API (`/yields.json`):**
```
MonthCurves.Datasets[].Type   →  "Produced" | "Consumed" | "Injected"
MonthCurves.Datasets[].Data[].Timestamp  →  "YYYY-MM"
MonthCurves.Datasets[].Data[].Data[]     →  Werte in Wh (Index = Tag - 1)
MonthCurves.Unit              →  "Wh"
```
Beispielstruktur: `pv-logger/docs/pv_output_example.json`

---

### Workflow 2: `HouseControl.json`

**Zweck:** Telegram-Bot für Strompreispflege und Auswertungen.

**Ablauf:**
```
Telegram Trigger (Webhook)
  ▼
Parse Command (Code)    ←── validiert und routet alle Befehle
  ▼
Command Router (Switch) ←── 5 Ausgänge
  ├─[error]──────► Send Error (Telegram)
  ├─[preis]──────► Close Previous Price (Postgres UPDATE)
  │                  ▼
  │               Insert New Price (Postgres INSERT)
  │                  ▼
  │               Format Price Confirmation (Code)
  │                  ▼
  │               Send Price Confirmation (Telegram)
  ├─[ust]────────► Calculate USt (Postgres SELECT)
  │                  ▼
  │               Format USt Result (Code)
  │                  ▼
  │               Send USt Result (Telegram)
  ├─[auswertung]─► Get Statistics (Postgres SELECT)
  │                  ▼
  │               Format Statistics (Code)
  │                  ▼
  │               Send Statistics (Telegram)
  └─[hilfe]──────► Format Help (Code)
                     ▼
                   Send Help (Telegram)
```

**Parse Command – unterstützte Befehle:**
| Befehl | Ausgabe-`command` |
|--------|------------------|
| `/preis` | `"preis"` |
| `/ust` | `"ust"` |
| `/auswertung` | `"auswertung"` |
| `/hilfe`, `/start`, `/help` | `"hilfe"` |
| Unbekannt / falsche Parameter | `"error"` |

**SQL – Close Previous Price:**
```sql
UPDATE electricity_prices
SET valid_to = $1::date - INTERVAL '1 day'
WHERE valid_to IS NULL AND valid_from < $1::date
```
Parameter: `[validFrom]`

**SQL – Insert New Price:**
```sql
INSERT INTO electricity_prices (price_per_kwh, vat_rate, valid_from, valid_to, note)
VALUES ($1, $2, $3::date, $4::date, 'Via Telegram')
RETURNING id, price_per_kwh, vat_rate, valid_from::text, valid_to::text
```
Parameter: `[price, vat, validFrom, validTo]`

**SQL – Calculate USt:**
```sql
SELECT
  ROUND(SUM(pd.consumed::numeric / 1000.0
    * COALESCE(ep.price_per_kwh, 0) / 100.0
    * COALESCE(ep.vat_rate, 0) / 100.0), 2)  AS ust_betrag_euro,
  SUM(pd.consumed)                            AS eigenverbrauch_wh,
  COUNT(pd.id)                                AS tage,
  COUNT(ep.id)                                AS tage_mit_preis
FROM production_data pd
LEFT JOIN electricity_prices ep
  ON pd.date_of_production >= ep.valid_from
 AND pd.date_of_production <= COALESCE(ep.valid_to, 'infinity'::date)
WHERE EXTRACT(YEAR FROM pd.date_of_production) = $1
```
Parameter: `[year]`

> **Formel:** `Wh / 1000 → kWh`, `Cent / 100 → €/kWh`, `% / 100 → Faktor`
> USt = Eigenverbrauch_kWh × Preis_€/kWh × MwSt-Faktor

**SQL – Get Statistics:**
```sql
SELECT
  SUM(produced)  AS erzeugt_wh,
  SUM(consumed)  AS eigenverbrauch_wh,
  SUM(injected)  AS eingespeist_wh,
  COUNT(*)       AS tage,
  MIN(date_of_production)::text AS von,
  MAX(date_of_production)::text AS bis
FROM production_data
WHERE date_of_production BETWEEN $1::date AND $2::date
```
Parameter: `[start, end]`

Vollständiger JavaScript-Quellcode aller Code-Nodes: `pv-logger/docs/java_script_functions.js`

---

## Backup-Strategie

**Täglich automatisch (Pi, Cron 02:00 Uhr):**
```
/mnt/ssd/docker/pv-logger/backups/pv-logger_YYYYMMDD_HHMM.sql.gz
```
- Skript: `pv-logger/backup.sh`
- Cron: `0 2 * * * /mnt/ssd/docker/pv-logger/backup.sh >> .../backup.log 2>&1`
- Retention: 7 Versionen

**Manuell auf Mac synchronisieren:**
```bash
./pull-backups.sh
# → speichert unter ./backups/
```

**Wiederherstellung:**
```bash
gunzip -c backups/pv-logger_DATUM.sql.gz | \
  docker exec -i housecontrol-db psql -U housecontrol_user housecontrol-db
```

---

## Deployment (Erstinstallation)

```bash
# 1. Repo auf den Pi klonen / kopieren
# 2. .env anpassen
cd /mnt/ssd/docker/pv-logger

# 3. Container starten
docker compose up -d

# 4. Datenbankschema einspielen
docker exec -i housecontrol-db psql -U housecontrol_user housecontrol-db < dump.sql

# 5. Migration anwenden
docker exec -i housecontrol-db psql -U housecontrol_user housecontrol-db < migrations/001_electricity_prices_v2.sql

# 6. n8n aufrufen und Workflows importieren
#    http://<IP>:5678 → Workflows → Import
#    → Dayly_Collector.json
#    → HouseControl.json
#    Anschliessend Credentials (Postgres, Telegram) in n8n einrichten.

# 7. Backup-Cron einrichten
chmod +x backup.sh
(crontab -l; echo "0 2 * * * /mnt/ssd/docker/pv-logger/backup.sh >> /mnt/ssd/docker/pv-logger/backups/backup.log 2>&1") | crontab -
```

---

## Migrations-Historie

| Nr. | Datum | Datei | Inhalt |
|-----|-------|-------|--------|
| 001 | 2026-03-27 | `migrations/001_electricity_prices_v2.sql` | btree_gist Extension, `note`-Spalte, Überlappungs-Constraint, Datenfehler korrigiert |

---

## SSH-Zugang (Mac → Pi)

```bash
# Schlüsselbasierter Zugriff (kein Passwort nötig)
ssh -i ~/.ssh/pv_logger pi@100.80.63.62

# Backups synchronisieren
./pull-backups.sh
```

Der SSH-Key `~/.ssh/pv_logger` wurde am 2026-03-27 eingerichtet.

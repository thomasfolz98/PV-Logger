# Worklog – PV-Logger / Demo-Projekt

## 2026-05-29 — Demo lokal getestet

### Was gemacht wurde
- Beide n8n-Workflows aus `n8n-workflows/` importiert und als **zwei separate Workflows** in n8n angelegt
- Fehler behoben: `N8N_BLOCK_ENV_ACCESS_IN_NODE=false` in `docker-compose.yml` ergänzt — war nötig, damit Workflows auf `$env.VARIABLEN` (Telegram, Anthropic) zugreifen können
- Beide Workflows auf "Published" gestellt und manuell getestet

### Ergebnis
- **PV Monitor – Basis Workflow**: läuft, schreibt alle 5 Minuten Messwerte vom Mock-Wechselrichter in `pv_readings` (PostgreSQL)
- **PV Monitor – KI Tagesauswertung**: läuft, liest Tageswerte aus DB, erstellt Analyse mit Claude API, sendet per Telegram — erfolgreich durchgelaufen
- Stack startet nach Reboot automatisch (Docker systemd-enabled, alle Container `restart: unless-stopped`)

### Offene Punkte
1. Demo-Repo als eigenständiges GitHub-Repo veröffentlichen
2. Video-Skript ausformulieren (`n8nPVMonitoring/konzept.md` hat die Struktur)
3. Video aufnehmen (Screencast + Kamera-Intro)
4. Angebot definieren (was wird konkret verkauft/angeboten?)

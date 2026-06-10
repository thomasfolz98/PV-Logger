# Prompt: Mock-Inverter-API bauen

## Wie ausführen

1. Separates Projektverzeichnis anlegen, z.B. `~/Projekte/n8n-pv-monitor-demo`
2. Dort Claude Code starten (eigener Kontext, unabhängig vom Nebentätigkeits-Projekt)
3. Den Prompt unten direkt in Claude Code eingeben
4. Ergebnis (`mock-inverter/`-Ordner mit Dockerfile, main.py, requirements.txt) in das
   GitHub-Demo-Repo übernehmen

Die Ergebnisse werden danach hier im Nebentätigkeits-Kontext nur für den
YouTube-Video-Inhalt und die Upload-Materialien verwendet — nicht weiterentwickelt.

---

## Prompt (direkt verwendbar)

Baue eine Mock-Wechselrichter-API mit FastAPI. Die API simuliert einen realen
Photovoltaik-Wechselrichter für Demonstrationszwecke — kein echter Wechselrichter
wird benötigt.

### Anforderungen

**Endpoint:** `GET /api/realtime`

**Response-Schema (JSON):**
```json
{
  "timestamp": "2026-05-07T11:32:00",
  "power_w": 1842,
  "energy_today_wh": 3240,
  "temperature_c": 38.5,
  "status": "producing"
}
```

**Simulationslogik:**
- Leistungskurve (power_w) folgt einer Gaußkurve mit Peak um 12:00 Uhr Ortszeit
- Tagesmaximum: zufällig zwischen 2500–4200 W (simuliert unterschiedliche Wetterbedingungen)
- Zufälliges Rauschen: ±10–15% auf den Momentanwert
- Bewölkungs-Einbrüche: ca. 2–3 mal pro Tag, Leistung fällt für 15–45 Min. auf 20–50%
- Vor Sonnenaufgang (vor 06:00) und nach Sonnenuntergang (nach 21:00): power_w = 0
- energy_today_wh: kumulierte Tagesenergie (Integral der Leistungskurve seit 00:00)
- temperature_c: Modultemperatur, korreliert mit power_w (höhere Leistung = höhere Temp, 25–65 °C)
- status: "producing" wenn power_w > 0, sonst "standby"

**Zweiter Endpoint:** `GET /api/history?hours=24`
- Gibt stündliche Aggregationen der letzten N Stunden zurück
- Nützlich für die KI-Auswertung (Tagesverlauf auf einen Blick)

**Response-Schema history:**
```json
[
  {"hour": "2026-05-07T10:00:00", "avg_power_w": 1650, "energy_wh": 1650},
  {"hour": "2026-05-07T11:00:00", "avg_power_w": 2100, "energy_wh": 2100}
]
```

**Technischer Stack:**
- Python 3.11+
- FastAPI
- Kein Datenbankzugriff — alle Werte werden zur Laufzeit berechnet
- Dockerfile (python:3.11-slim, Port 8000)
- requirements.txt

**Lieferobjekte:**
- `main.py` — FastAPI-App
- `requirements.txt`
- `Dockerfile`
- Kurze Dokumentation der Simulationslogik in der README (wie realistisch ist sie?)

**Nicht benötigt:**
- Authentifizierung
- HTTPS
- Persistenz / Datenbank
- Tests (nice to have, aber nicht Pflicht für Demo-Zwecke)

---

## Verwendungskontext (für den Auftraggeber)

Die fertige API wird in ein Docker-Compose-Setup eingebettet:
- Dienst-Name im Compose-Netz: `mock-inverter`
- n8n ruft intern `http://mock-inverter:8000/api/realtime` auf
- Kein direkter Zugriff von außen nötig (kein Port-Mapping zwingend erforderlich,
  aber für Debugging hilfreich: Port 8000 nach außen mappen)

Das Ergebnis landet im GitHub-Repo `n8n-pv-monitor-demo` unter `mock-inverter/`.

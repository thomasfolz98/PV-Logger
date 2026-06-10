# Briefing: LinkedIn-Beitrag

## Worum geht es

Ich habe ein vollständiges PV-Monitoring-System auf einem Raspberry Pi selbst gebaut —
seit ca. 2 Jahren produktiv im Betrieb. Als nächsten Schritt möchte ich daraus
Content machen (YouTube) und n8n-Automatisierungsprojekte als Nebentätigkeit anbieten.

Der LinkedIn-Beitrag soll ein erster Aufschlag sein: Sichtbarkeit in der Entwickler-Community,
ohne direkt zu verkaufen.

---

## Das Projekt in Kürze

**Stack:** n8n, PostgreSQL, Docker, Raspberry Pi, Telegram Bot, ngrok, Claude API (Anthropic)

**Was es macht:**
- Erfasst alle 5 Minuten die aktuelle Solarleistung vom Wechselrichter (HTTP GET)
- Schreibt die Daten in PostgreSQL
- Schickt Telegram-Alerts bei Leistungseinbrüchen (Schwellenwert-Trigger)
- Erstellt täglich eine KI-generierte Auswertung via Claude API → Telegram

**Kein Cloud-Abo, kein Hersteller-Lock-in — läuft selbst gehostet.**

---

## Demo-Repo (fertig, noch nicht veröffentlicht)

Pfad lokal: `n8nPVMonitoring/n8n-pv-monitor-demo/`

Enthält:
- Mock-Wechselrichter (FastAPI, deterministisch, Gaußkurve mit Bewölkungs-Einbrüchen)
- Basis-Workflow: Schedule → HTTP → Code (JS) → PostgreSQL → IF → Telegram
- KI-Workflow: Schedule → PostgreSQL → Code (Prompt) → Claude API → Telegram
- Vollständig containerisiert (Docker Compose), Clone & Run in < 5 Minuten

**GitHub-Repo ist noch nicht angelegt** — der Beitrag kann das ankündigen oder auf das
Konzept-Video verweisen.

---

## Zielgruppe für den LinkedIn-Beitrag

- Entwickler mit eigener PV-Anlage
- Entwickler, die n8n kennen, aber nur für CRM/E-Mail nutzen
- Leute, die KI mit echtem Mehrwert in eigene Systeme einbauen wollen

---

## Kernbotschaft / Positionierung

> „n8n ist keine Marketing-Automation. Es ist eine ernsthafte Integrationsplattform —
> auch für IoT und Hardware."

Differenzierung:
- IoT + n8n ist auf YouTube/LinkedIn wenig besetzt
- Reales Produktivsystem (nicht konstruierte Demo)
- KI als nützliches Werkzeug, nicht als Gimmick
- Self-hosted auf Raspberry Pi — trifft Entwickler-Nerv

---

## Ton / Stil-Wunsch

- Kein Hype, kein Verkaufsdruck
- Technisch glaubwürdig, aber zugänglich
- Persönlich ("ich habe gebaut...") statt Unternehmens-Marketing
- LinkedIn-typisch: Hook in der ersten Zeile, dann Story, am Ende Call to Action

---

## Mögliche Aufhänger für den Beitrag

1. **Zahlen:** „2 Jahre, 0 Cloud-Abos, 0 Ausfälle — so läuft mein PV-Monitoring."
2. **Provokation:** „Die App des Wechselrichter-Herstellers hat mir nicht gereicht."
3. **Show don't tell:** Screenshot / GIF vom Telegram-Bot mit KI-Auswertung
4. **Nerd-Hook:** „Mein Raspberry Pi schickt mir seit 2 Jahren jeden Abend eine KI-Zusammenfassung der Sonnenstunden."

---

## Was der Beitrag auslösen soll

- Kommentare / Saves von Entwicklern mit PV-Anlage
- Interesse an einem YouTube-Video (Ankündigung möglich)
- Erste Signale: Wer hätte Interesse an sowas für den eigenen Use Case?

**Kein direkter CTA auf Dienstleistung** — noch zu früh, kein Angebot steht fest.

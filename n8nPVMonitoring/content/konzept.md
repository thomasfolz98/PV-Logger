# Video-Konzept: n8n + PV-Monitoring + KI

Stand: 2026-05-07

---

## Arbeitstitel

**„n8n als IoT-Datenlogger: PV-Monitoring mit HTTP, PostgreSQL, Telegram — und KI-Analyse"**

---

## Zielgruppe

- Entwickler mit PV-Anlage, die mehr wollen als eine Hersteller-App
- Entwickler die n8n kennen, aber nur für CRM/E-Mail nutzen
- Alle, die KI sinnvoll (nicht dekorativ) in eigene Systeme einbauen wollen

---

## Hook / Einstieg (Kamera, ~60 Sek.)

> „Meine PV-Anlage läuft seit zwei Jahren autonom auf einem Raspberry Pi.
> Kein Cloud-Abo, keine proprietäre App — nur n8n, PostgreSQL und ein Telegram-Bot.
> Heute zeige ich dir, wie das funktioniert. Und am Ende schickt mir die Anlage
> selbst eine KI-generierte Auswertung."

---

## Kapitelstruktur (geschätzt ~17 Min.)

| Zeit  | Kapitel |
|-------|---------|
| 00:00 | Hook — Was ist das Ziel, was läuft da wirklich |
| 01:00 | n8n kurz vorgestellt — was ist es, warum für Entwickler interessant |
| 02:30 | Systemüberblick: Raspberry Pi, n8n, PostgreSQL, Wechselrichter-API |
| 04:00 | Demo Teil 1: Basis-Workflow — Zeittrigger → HTTP-Request → JavaScript → PostgreSQL |
| 09:00 | Telegram-Anbindung — Benachrichtigung bei Schwellenwert |
| 11:30 | Demo Teil 2: KI-Erweiterung — n8n AI-Node / Claude API → Tagesauswertung → Telegram |
| 15:30 | Was das zeigt: n8n als ernsthafte Integrationsplattform |
| 16:30 | Zusammenfassung & nächste Schritte |

---

## Technischer Stack (Demo)

```
Raspberry Pi (selbst gehostet, produktiv)
    └── n8n
         ├── Schedule Trigger (alle 5 Min.)
         ├── HTTP Request → Wechselrichter (Demo: Mock-API)
         ├── Function Node (JavaScript) — Daten normalisieren
         ├── PostgreSQL Node — INSERT
         ├── IF Node — Schwellenwert-Check
         ├── Telegram Node — Benachrichtigung
         └── [KI-Erweiterung, abendlicher Trigger 21:00]
              ├── PostgreSQL Node — Tageswerte aggregiert lesen
              ├── HTTP Request → Claude API
              └── Telegram Node — natürlichsprachliche Auswertung
```

---

## KI-Erweiterung konkret

Abendlicher Trigger liest Tageswerte aus PostgreSQL, schickt an Claude API:

**Prompt:**
> „Analysiere diese PV-Ertragsdaten für heute und schreibe eine kurze deutsche
> Zusammenfassung für den Anlagenbesitzer: [Daten].
> Vergleiche mit dem Monatsdurchschnitt und nenne auffällige Stunden."

**Beispiel-Output per Telegram:**
> „Heute 4,2 kWh — 18% unter dem Mai-Durchschnitt. Stärkster Einbruch 13–15 Uhr
> (vermutlich Bewölkung). Beste Stunde: 11 Uhr mit 0,8 kWh."

---

## Differenzierung

- Kein CRM, kein E-Mail-Workflow — IoT/Hardware + n8n ist auf YouTube unbesetzt
- Reales Produktivsystem, läuft seit 2 Jahren — keine konstruierte Demo
- KI mit echtem Mehrwert, nicht als Gimmick
- Self-hosted auf Raspberry Pi — trifft Entwickler-Community (kein Cloud-Lock-in)

---

## Demo-Repo (GitHub)

Siehe `github_demo_plan.md` — vollständig containerisiert, Clone & Run ohne echten Wechselrichter.

---

## Voraussetzungen (Vorbereitung)

- [ ] Mock-Inverter-API (FastAPI) für Demo bauen
- [ ] n8n-Workflow exportieren (JSON)
- [ ] Docker Compose: n8n + PostgreSQL + Mock-API
- [ ] Claude API Key einrichten (falls noch nicht vorhanden)
- [ ] n8n AI-Node vs. direkter HTTP-Request evaluieren
- [ ] Skript schreiben
- [ ] Kamera-Intro aufnehmen + Screencast

---

## Kapitelmarken (Entwurf)

```
00:00 Hook — Was hier läuft
01:00 n8n für Entwickler
02:30 Systemüberblick
04:00 Demo: Basis-Workflow live
09:00 Telegram-Anbindung
11:30 Demo: KI-Erweiterung
15:30 Fazit: n8n als ernsthafte Plattform
16:30 Zusammenfassung
```

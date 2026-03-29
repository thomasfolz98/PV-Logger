# PV-Logger – Anwenderdokumentation

## Was macht PV-Logger?

PV-Logger erfasst täglich die Daten deiner Solaranlage und stellt sie über einen Telegram-Bot zur Verfügung. Du kannst:

- **Strompreise** pflegen (mit Gültigkeitszeitraum)
- Die **Mehrwertsteuer auf Eigenverbrauch** für die Steuererklärung berechnen lassen
- **Auswertungen** über Erzeugung und Verbrauch abfragen

---

## Telegram-Befehle im Überblick

| Befehl | Funktion |
|--------|---------|
| `/preis` | Neuen Strompreis eintragen |
| `/ust` | MwSt-Betrag für Elster berechnen |
| `/auswertung` | Erzeugung und Verbrauch auswerten |
| `/hilfe` | Alle Befehle anzeigen |

---

## Befehle im Detail

### `/preis` – Strompreis eintragen

```
/preis [Cent/kWh] [MwSt%] [Gültig-ab] [Gültig-bis]
```

- **Cent/kWh** – Bruttopreis in Cent, z.B. `34.30`
- **MwSt%** – Mehrwertsteuersatz in Prozent, z.B. `19`
- **Gültig-ab** – Datum im Format `JJJJ-MM-TT`
- **Gültig-bis** – optional; weglassen wenn der Preis aktuell gültig ist

**Beispiele:**

```
/preis 34.30 19 2025-04-02
```
Trägt einen neuen Preis ab 02.04.2025 ein (kein Enddatum → aktuell gültig).

```
/preis 35.51 19 2025-01-01 2025-04-01
```
Trägt einen Preis für einen abgeschlossenen Zeitraum ein.

> **Hinweis:** Wenn es bereits einen offenen Preis (ohne Enddatum) gibt, wird dieser
> automatisch am Tag vor dem neuen Gültig-ab-Datum abgeschlossen. Du musst das
> nicht manuell tun.

---

### `/ust` – MwSt auf Eigenverbrauch berechnen

```
/ust [Jahr]
```

Berechnet die abzuführende Umsatzsteuer auf den Eigenverbrauch der Solaranlage
für das angegebene Steuerjahr. Den angezeigten Betrag trägst du in deine
Umsatzsteuererklärung (Elster-Formular) ein.

**Beispiele:**

```
/ust 2025
```

**Ausgabe (Beispiel):**
```
📊 Umsatzsteuer 2025

Eigenverbrauch: 1.842,3 kWh
Erfasste Tage: 365

💶 USt-Betrag: 119,53 €

👉 Diesen Betrag in das Elster-Formular eintragen.
```

> **Hinweis:** Falls eine Warnung erscheint, dass Tage ohne hinterlegten Strompreis
> vorhanden sind, sind für diesen Zeitraum noch keine Preisdaten eingetragen. Der
> angezeigte Betrag wäre dann zu niedrig – bitte zuerst die fehlenden Preise mit
> `/preis` nachtragen.

---

### `/auswertung` – Erzeugung und Verbrauch auswerten

```
/auswertung [Start] [Ende]
```

- **Start** – Startdatum im Format `JJJJ-MM-TT`
- **Ende** – optional; wird weggelassen, gilt das heutige Datum

**Beispiele:**

```
/auswertung 2025-01-01 2025-12-31
```
Auswertung für das gesamte Jahr 2025.

```
/auswertung 2026-01-01
```
Auswertung vom 01.01.2026 bis heute.

**Ausgabe (Beispiel):**
```
⚡ Auswertung 2025-01-01 bis 2025-12-31 (365 Tage)

Erzeugt:          4.821,0 kWh
Eigenverbrauch:   1.842,3 kWh (38%)
Eingespeist:      2.978,7 kWh
```

---

### `/hilfe` – Hilfe anzeigen

```
/hilfe
```

Zeigt alle verfügbaren Befehle mit Beispielen direkt im Telegram-Chat an.

---

## Häufige Fehlermeldungen

| Meldung | Ursache | Lösung |
|---------|---------|--------|
| `⚠️ Format falsch!` | Befehl unvollständig | Auf die angezeigte Beispiel-Syntax achten |
| `⚠️ Datum muss im Format JJJJ-MM-TT sein` | Falsches Datumsformat | Datum als `2025-04-02` schreiben (mit Bindestrichen) |
| `⚠️ Preis und MwSt müssen Zahlen sein` | Buchstaben im Preisfeld | Nur Zahlen verwenden, Komma als Dezimaltrennzeichen erlaubt |
| `⚠️ X Tage ohne Strompreis!` | Lücke in Strompreistabelle | Fehlende Preise mit `/preis` nachtragen |
| `⚠️ Keine Daten gefunden` | Kein Eintrag im Zeitraum | Anderen Zeitraum wählen oder prüfen ob der Collector läuft |
| `❓ Unbekannter Befehl` | Tippfehler | `/hilfe` für Übersicht aufrufen |

---

## Daten automatisch erfassen

Die tägliche Datenerfassung vom Wechselrichter läuft **automatisch jeden Morgen um 10:00 Uhr**. Es ist kein manuelles Eingreifen erforderlich. Falls an einem Tag keine Daten ankommen (z.B. Wechselrichter offline), werden die fehlenden Tage beim nächsten Lauf automatisch nachgeholt.

---

## Backup

Die Datenbank wird **täglich um 02:00 Uhr** automatisch gesichert (letzte 7 Tage auf dem Raspberry Pi). Um eine lokale Kopie auf dem Mac zu erstellen:

```bash
./pull-backups.sh
```

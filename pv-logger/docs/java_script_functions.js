/**
 * PV-Logger – JavaScript-Referenz
 * ================================
 * Dieses File enthält den Quellcode aller Code-Nodes aus den n8n-Workflows.
 * Es dient als Referenz und Versionierungsgrundlage; die ausführbaren Versionen
 * sind direkt in den Workflow-JSONs eingebettet.
 *
 * Inhalt:
 *   1. Dayly_Collector – Datenextraktion aus Wechselrichter-API
 *   2. HouseControl – Parse Command (Router)
 *   3. HouseControl – Format Price Confirmation
 *   4. HouseControl – Format USt Result
 *   5. HouseControl – Format Statistics
 *   6. HouseControl – Format Help
 */


// ============================================================
// 1. DAYLY_COLLECTOR – Code Node: Datenextraktion
// ============================================================
// Eingabe: Ergebnis des Postgres-Nodes ($('Postgres').first().json.last_date)
//          + HTTP-Response der Wechselrichter-API ($input.first().json)
// Ausgabe: Array von Tages-Einträgen für den Postgres-Upsert

const lastDateStr = $('Postgres').first().json.last_date;
const apiData = $input.first().json;

function addDays(dateStr, days) {
  const date = new Date(dateStr);
  date.setDate(date.getDate() + days);
  return date.toISOString().split('T')[0];
}

function getYesterday() {
  const date = new Date();
  date.setDate(date.getDate() - 1);
  return date.toISOString().split('T')[0];
}

let nextDateToFetch;
if (!lastDateStr) {
  nextDateToFetch = getYesterday();
} else {
  nextDateToFetch = addDays(lastDateStr, 1);
}

const yesterday = getYesterday();
const results = [];

const datasets = apiData.MonthCurves.Datasets;
const unit = apiData.MonthCurves.Unit;

function getVal(type, dateStr) {
  const dataset = datasets.find(d => d.Type === type);
  if (!dataset) return null;

  const monthStr = dateStr.substring(0, 7);
  const day = parseInt(dateStr.substring(8, 10), 10);

  const monthData = dataset.Data.find(d => d.Timestamp === monthStr);
  if (monthData && monthData.Data && monthData.Data[day - 1] !== undefined) {
    return monthData.Data[day - 1];
  }
  return null;
}

while (nextDateToFetch <= yesterday) {
  const prod = getVal("Produced", nextDateToFetch);
  const cons = getVal("Consumed", nextDateToFetch);
  const inj  = getVal("Injected", nextDateToFetch);

  if (prod !== null && cons !== null && inj !== null) {
    results.push({
      json: {
        date_of_production: nextDateToFetch,
        produced: prod,
        consumed: cons,
        injected: inj,
        unit: unit
      }
    });
  }

  nextDateToFetch = addDays(nextDateToFetch, 1);
  if (results.length > 365) break;
}

return results;


// ============================================================
// 2. HOUSECONTROL – Code Node: Parse Command (Router)
// ============================================================
// Eingabe:  Telegram-Nachricht ($input.first().json.message)
// Ausgabe:  { command, chatId, ...parameter } — wird an Command Router (Switch) weitergegeben

const msg = $input.first().json.message;
const text = msg?.text || '';
const chatId = msg?.chat?.id;
const parts = text.trim().split(/\s+/);
const cmd = parts[0]?.toLowerCase() || '';

if (cmd === '/preis') {
  if (parts.length < 4) {
    return [{ json: { command: 'error', chatId,
      message: '⚠️ Format falsch!\n\n/preis [Cent/kWh] [MwSt%] [JJJJ-MM-TT] [JJJJ-MM-TT]\nEnde-Datum ist optional.\n\nBeispiel:\n/preis 34.30 19 2025-04-02' } }];
  }
  const price = parseFloat(parts[1].replace(',', '.'));
  const vat   = parseFloat(parts[2].replace(',', '.'));
  const validFrom = parts[3];
  const validTo   = parts[4] || null;
  if (isNaN(price) || isNaN(vat)) {
    return [{ json: { command: 'error', chatId, message: '⚠️ Preis und MwSt müssen Zahlen sein.' } }];
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(validFrom)) {
    return [{ json: { command: 'error', chatId, message: '⚠️ Datum muss im Format JJJJ-MM-TT sein.\nBeispiel: 2025-04-02' } }];
  }
  if (validTo && !/^\d{4}-\d{2}-\d{2}$/.test(validTo)) {
    return [{ json: { command: 'error', chatId, message: '⚠️ Enddatum muss im Format JJJJ-MM-TT sein.' } }];
  }
  return [{ json: { command: 'preis', chatId, price, vat, validFrom, validTo } }];
}

if (cmd === '/ust') {
  const year = parts[1] || String(new Date().getFullYear());
  if (!/^\d{4}$/.test(year)) {
    return [{ json: { command: 'error', chatId, message: '⚠️ Format falsch!\n\n/ust [Jahr]\n\nBeispiel: /ust 2025' } }];
  }
  return [{ json: { command: 'ust', chatId, year: parseInt(year) } }];
}

if (cmd === '/auswertung') {
  if (parts.length < 2) {
    return [{ json: { command: 'error', chatId,
      message: '⚠️ Format falsch!\n\n/auswertung [Start] [Ende]\nEnde-Datum ist optional (= heute).\n\nBeispiel: /auswertung 2025-01-01 2025-12-31' } }];
  }
  const start = parts[1];
  const end   = parts[2] || new Date().toISOString().split('T')[0];
  if (!/^\d{4}-\d{2}-\d{2}$/.test(start)) {
    return [{ json: { command: 'error', chatId, message: '⚠️ Datum muss im Format JJJJ-MM-TT sein.' } }];
  }
  return [{ json: { command: 'auswertung', chatId, start, end } }];
}

if (['/hilfe', '/start', '/help'].includes(cmd)) {
  return [{ json: { command: 'hilfe', chatId } }];
}

return [{ json: { command: 'error', chatId,
  message: `❓ Unbekannter Befehl: ${cmd}\n\nTippe /hilfe für alle Befehle.` } }];


// ============================================================
// 3. HOUSECONTROL – Code Node: Format Price Confirmation
// ============================================================
// Eingabe:  Ergebnis des INSERT (nach "Insert New Price")
// Ausgabe:  { chatId, text } für den Telegram-Send-Node

const p = $('Parse Command').first().json;
const text2 = `✅ Strompreis gespeichert!\n\nPreis: ${p.price} Cent/kWh\nMwSt: ${p.vat}%\nGültig ab: ${p.validFrom}${p.validTo ? '\nBis: ' + p.validTo : '\n(kein Enddatum – aktuell gültig)'}`;
return [{ json: { chatId: p.chatId, text: text2 } }];


// ============================================================
// 4. HOUSECONTROL – Code Node: Format USt Result
// ============================================================
// Eingabe:  Ergebnis der SQL-Abfrage (nach "Calculate USt")
// Ausgabe:  { chatId, text } für den Telegram-Send-Node

const row = $input.first().json;
const p2 = $('Parse Command').first().json;
const ust = parseFloat(row.ust_betrag_euro || 0);
const kwh = (parseInt(row.eigenverbrauch_wh || 0) / 1000).toFixed(1);
const tage = parseInt(row.tage || 0);
const tageMitPreis = parseInt(row.tage_mit_preis || 0);
const tageOhnePreis = tage - tageMitPreis;

let text3 = `📊 Umsatzsteuer ${p2.year}\n\n`;
text3 += `Eigenverbrauch: ${kwh.replace('.', ',')} kWh\n`;
text3 += `Erfasste Tage: ${tage}`;
if (tageOhnePreis > 0) {
  text3 += ` (⚠️ ${tageOhnePreis} Tage ohne Strompreis!)`;
}
text3 += `\n\n💶 USt-Betrag: ${ust.toFixed(2).replace('.', ',')} €\n\n👉 Diesen Betrag in das Elster-Formular eintragen.`;

return [{ json: { chatId: p2.chatId, text: text3 } }];


// ============================================================
// 5. HOUSECONTROL – Code Node: Format Statistics
// ============================================================
// Eingabe:  Ergebnis der SQL-Abfrage (nach "Get Statistics")
// Ausgabe:  { chatId, text } für den Telegram-Send-Node

const row2 = $input.first().json;
const p3 = $('Parse Command').first().json;

if (!row2.tage || parseInt(row2.tage) === 0) {
  return [{ json: { chatId: p3.chatId,
    text: `⚠️ Keine Daten für den Zeitraum ${p3.start} bis ${p3.end} gefunden.` } }];
}

const erzeugt     = parseInt(row2.erzeugt_wh || 0);
const eigen       = parseInt(row2.eigenverbrauch_wh || 0);
const eingespeist = parseInt(row2.eingespeist_wh || 0);
const tage2       = parseInt(row2.tage);
const quote       = erzeugt > 0 ? Math.round(eigen / erzeugt * 100) : 0;
const fmt         = (wh) => (wh / 1000).toFixed(1).replace('.', ',') + ' kWh';

const text4 = `⚡ Auswertung ${row2.von} bis ${row2.bis} (${tage2} Tage)\n\nErzeugt:          ${fmt(erzeugt)}\nEigenverbrauch:   ${fmt(eigen)} (${quote}%)\nEingespeist:      ${fmt(eingespeist)}`;
return [{ json: { chatId: p3.chatId, text: text4 } }];


// ============================================================
// 6. HOUSECONTROL – Code Node: Format Help
// ============================================================
// Eingabe:  { chatId } vom Command Router
// Ausgabe:  { chatId, text } für den Telegram-Send-Node

const chatId2 = $input.first().json.chatId;
const helpText = `📋 Verfügbare Befehle:

/preis [Cent/kWh] [MwSt%] [Start] [Ende]
Neuen Strompreis eintragen
Beispiel: /preis 34.30 19 2025-04-02

/ust [Jahr]
MwSt auf Eigenverbrauch für Steuererklärung
Beispiel: /ust 2025

/auswertung [Start] [Ende]
Erzeugung und Verbrauch auswerten
Beispiel: /auswertung 2025-01-01 2025-12-31

/hilfe
Diese Hilfe anzeigen`;
return [{ json: { chatId: chatId2, text: helpText } }];

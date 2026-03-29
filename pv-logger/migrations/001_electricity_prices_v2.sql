-- Migration 001: electricity_prices Tabellenstruktur verbessern
-- Angewendet: 2026-03-27
-- Zweck: Überlappende Zeiträume und mehrfach offene Einträge verhindern,
--        Kommentarfeld hinzufügen, bestehende Datenfehler korrigieren.

BEGIN;

-- Voraussetzung: btree_gist Extension für Exclusion Constraint
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 1. Kommentarfeld (z.B. "Korrektur", "Via Telegram", "Tarifwechsel")
ALTER TABLE electricity_prices ADD COLUMN IF NOT EXISTS note text;

-- 2. Bestehende Datenfehler korrigieren:
--    Beide Einträge hatten valid_to = NULL. Den älteren Eintrag korrekt abschließen.
UPDATE electricity_prices
SET valid_to = '2025-04-01'
WHERE id = 4 AND valid_to IS NULL;

-- 3. Nur ein "offener" Eintrag (valid_to IS NULL) gleichzeitig erlaubt
CREATE UNIQUE INDEX IF NOT EXISTS one_open_price
    ON electricity_prices (valid_to)
    WHERE valid_to IS NULL;

-- 4. Keine überlappenden Zeiträume
--    Verwendet daterange mit inklusiven Grenzen ([])
ALTER TABLE electricity_prices
    ADD CONSTRAINT no_overlapping_prices
    EXCLUDE USING gist (
        daterange(valid_from, COALESCE(valid_to, 'infinity'::date), '[]') WITH &&
    );

-- 5. Plausibilitätsprüfung: valid_to muss nach valid_from liegen
ALTER TABLE electricity_prices
    ADD CONSTRAINT valid_range_check
    CHECK (valid_to IS NULL OR valid_to > valid_from);

COMMIT;

-- Ergebnis prüfen:
-- SELECT * FROM electricity_prices ORDER BY valid_from;
-- \d electricity_prices

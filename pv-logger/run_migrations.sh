#!/bin/bash
# run_migrations.sh – Datenbankmigrationen idempotent anwenden.
# Wird von deploy.sh (Mac-seitig) via SSH auf dem Pi aufgerufen.
# Protokolliert bereits angewendete Migrationen in der Tabelle applied_migrations.

set -e

MIGRATIONS_DIR="/mnt/ssd/docker/pv-logger/migrations"
DB_CONTAINER="housecontrol-db"
DB_USER="housecontrol_user"
DB_NAME="housecontrol-db"

# Keine Migrationsdateien vorhanden?
if [ ! -d "$MIGRATIONS_DIR" ] || [ -z "$(ls -A "$MIGRATIONS_DIR"/*.sql 2>/dev/null)" ]; then
  echo "Keine Migrationsdateien gefunden – übersprungen."
  exit 0
fi

# Tracking-Tabelle anlegen (idempotent)
docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c \
  "CREATE TABLE IF NOT EXISTS applied_migrations (
     name       text PRIMARY KEY,
     applied_at timestamptz DEFAULT now()
   )" > /dev/null

# Alle .sql-Dateien in alphabetischer Reihenfolge prüfen und anwenden
for sql_file in $(ls "$MIGRATIONS_DIR"/*.sql | sort); do
  migration=$(basename "$sql_file")

  already=$(docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -tAc \
    "SELECT 1 FROM applied_migrations WHERE name='$migration'" 2>/dev/null || true)

  if [ -n "$already" ]; then
    echo "  ✓ $migration – bereits angewendet"
  else
    echo "  → Wende an: $migration ..."
    docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" < "$sql_file"
    docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c \
      "INSERT INTO applied_migrations (name) VALUES ('$migration')" > /dev/null
    echo "  ✓ $migration – erfolgreich angewendet"
  fi
done

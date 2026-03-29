#!/bin/bash
# PV-Logger Stack aktualisieren
# Zieht die neuesten Docker-Images und startet alle Container neu.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "[$(date)] Aktualisierung gestartet..."

docker compose pull
docker compose down
docker compose up -d

echo "[$(date)] Alle Container laufen:"
docker compose ps

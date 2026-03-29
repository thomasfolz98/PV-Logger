#!/bin/bash
# Holt die aktuellen Backups vom Raspberry Pi auf den Mac.
# Ausführen: ./pull-backups.sh

REMOTE="pi@100.80.63.62:/mnt/ssd/docker/pv-logger/backups/"
LOCAL_DIR="$(dirname "$0")/backups"
SSH_KEY="$HOME/.ssh/pv_logger"

mkdir -p "$LOCAL_DIR"

echo "[$(date)] Synchronisiere Backups vom Pi..."
rsync -avz --progress -e "ssh -i ${SSH_KEY}" "$REMOTE" "$LOCAL_DIR/"

if [ $? -eq 0 ]; then
    COUNT=$(ls "$LOCAL_DIR"/*.sql.gz 2>/dev/null | wc -l | tr -d ' ')
    echo "[$(date)] Fertig. ${COUNT} Backup(s) lokal vorhanden:"
    ls -lh "$LOCAL_DIR"/*.sql.gz 2>/dev/null
else
    echo "[$(date)] FEHLER: Synchronisierung fehlgeschlagen!" >&2
    exit 1
fi

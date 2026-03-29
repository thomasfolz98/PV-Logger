#!/bin/bash
# deploy.sh – PV-Logger vom Mac auf den Raspberry Pi deployen
#
# Verwendung:
#   ./deploy.sh                 rsync + Migrationen einspielen
#   ./deploy.sh --full          rsync + Migrationen + Docker-Images aktualisieren + Stack neustarten
#   ./deploy.sh --migrate-only  nur Migrationen einspielen, kein rsync

set -e

REMOTE_HOST="pi@100.80.63.62"
REMOTE_DIR="/mnt/ssd/docker/pv-logger"
SSH_KEY="$HOME/.ssh/pv_logger"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/pv-logger"
SSH_CMD="ssh -i $SSH_KEY"

FULL=false
MIGRATE_ONLY=false
for arg in "$@"; do
  case $arg in
    --full) FULL=true ;;
    --migrate-only) MIGRATE_ONLY=true ;;
  esac
done

echo "[$(date)] === PV-Logger Deploy gestartet ==="

# 1. Dateien synchronisieren
if [ "$MIGRATE_ONLY" = false ]; then
  echo ""
  echo "[$(date)] Synchronisiere Dateien nach $REMOTE_HOST:$REMOTE_DIR ..."
  rsync -avz --progress \
    -e "ssh -i $SSH_KEY" \
    --exclude='.env' \
    --exclude='postgres_data/' \
    --exclude='n8n_data/' \
    --exclude='pgadmin_data/' \
    --exclude='backups/' \
    --exclude='Testdaten/' \
    "$SOURCE_DIR/" \
    "$REMOTE_HOST:$REMOTE_DIR/"
  echo "[$(date)] Synchronisierung abgeschlossen."
fi

# 2. Migrationen einspielen
echo ""
echo "[$(date)] Prüfe und spiele Migrationen ein..."
$SSH_CMD "$REMOTE_HOST" "chmod +x $REMOTE_DIR/run_migrations.sh && bash $REMOTE_DIR/run_migrations.sh"

# 3. Optional: Docker-Images aktualisieren + Stack neustarten
if [ "$FULL" = true ]; then
  echo ""
  echo "[$(date)] Aktualisiere Docker-Images und starte Stack neu..."
  $SSH_CMD "$REMOTE_HOST" "cd $REMOTE_DIR && docker compose pull && docker compose down && docker compose up -d"
  echo ""
  echo "[$(date)] Stack-Status:"
  $SSH_CMD "$REMOTE_HOST" "cd $REMOTE_DIR && docker compose ps"
fi

echo ""
echo "[$(date)] === Deploy abgeschlossen ==="
echo ""
echo "Hinweis: Änderungen an Workflows (*.json) müssen in n8n manuell"
echo "         re-importiert werden: http://100.80.63.62:5678"

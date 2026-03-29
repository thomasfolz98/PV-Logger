#!/bin/bash
set -o pipefail

# PV-Logger Datenbank-Backup
# Legt täglich ein komprimiertes Backup an und hält die letzten 7 Versionen.
# Cron-Eintrag auf dem Pi: 0 2 * * * /mnt/ssd/docker/pv-logger/backup.sh >> /mnt/ssd/docker/pv-logger/backups/backup.log 2>&1

BACKUP_DIR="/mnt/ssd/docker/pv-logger/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M)
FILENAME="pv-logger_${TIMESTAMP}.sql.gz"
CONTAINER="housecontrol-db"
DB_USER="housecontrol_user"
DB_NAME="housecontrol-db"

echo "[$(date)] Starte Backup: ${FILENAME}"

docker exec "${CONTAINER}" pg_dump -U "${DB_USER}" "${DB_NAME}" | gzip > "${BACKUP_DIR}/${FILENAME}"

if [ $? -eq 0 ]; then
    SIZE=$(du -sh "${BACKUP_DIR}/${FILENAME}" | cut -f1)
    echo "[$(date)] Backup erfolgreich: ${FILENAME} (${SIZE})"
else
    echo "[$(date)] FEHLER: Backup fehlgeschlagen!" >&2
    rm -f "${BACKUP_DIR}/${FILENAME}"
    exit 1
fi

# Nur die letzten 7 Backups behalten
KEPT=$(ls -t "${BACKUP_DIR}"/*.sql.gz 2>/dev/null | tail -n +8)
if [ -n "${KEPT}" ]; then
    echo "${KEPT}" | xargs rm
    echo "[$(date)] Alte Backups gelöscht"
fi

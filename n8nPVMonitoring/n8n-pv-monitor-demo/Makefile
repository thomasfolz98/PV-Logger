.PHONY: setup start stop restart logs status clean

# Verzeichnisse für persistente Daten anlegen (einmalig)
setup:
	mkdir -p /mnt/data/docker/pv-monitor-demo/postgres
	mkdir -p /mnt/data/docker/pv-monitor-demo/n8n
	@if [ ! -f .env ]; then cp .env.example .env && echo "✓ .env angelegt — bitte Tokens eintragen"; fi

# Stack starten
start:
	docker compose up -d
	@echo ""
	@echo "Stack läuft. Zugänge:"
	@echo "  n8n             → http://localhost:5678"
	@echo "  Mock-Wechselrichter → http://localhost:8000/api/realtime"

# Stack stoppen (Daten bleiben erhalten)
stop:
	docker compose down

# Stack neu starten
restart:
	docker compose down && docker compose up -d

# Live-Logs aller Container
logs:
	docker compose logs -f

# Logs eines einzelnen Containers: make logs-n8n / logs-postgres / logs-mock
logs-%:
	docker compose logs -f $*

# Status aller Container
status:
	docker compose ps

# Alles löschen inkl. Daten auf /mnt/data (Achtung: unwiderruflich!)
clean:
	docker compose down
	rm -rf /mnt/data/docker/pv-monitor-demo
	@echo "Alle Daten gelöscht."

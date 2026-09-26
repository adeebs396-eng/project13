#!/bin/bash
# Show recent logs from the Project 13 stack. Owned by Rana.
#
#   bash scripts/check-logs.sh                  last 100 lines, every service
#   bash scripts/check-logs.sh grafana          one service only
#   bash scripts/check-logs.sh grafana 500      one service, more lines
#   bash scripts/check-logs.sh --errors         only warnings and errors
#
set -uo pipefail

cd "$(dirname "$0")/../stack"

LOG_FILE="$HOME/project13-logs/check-logs.log"
mkdir -p "$(dirname "$LOG_FILE")"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

if ! docker compose version >/dev/null 2>&1; then
    log "[ERROR] Docker Compose plugin not found. This script only runs on the VM, not in Cloud Shell."
    exit 1
fi

if [ "${1:-}" = "--errors" ]; then
    log "[INFO] Warnings and errors from the last 500 lines of every service"
    docker compose logs --tail=500 --no-color 2>&1 \
        | grep -iE "level=(error|warn)|\berror\b|fatal|panic" \
        | grep -viE "grafana\.com|x509|angular|update.checker|plugin\.backgroundinstaller" \
        | tail -60 | tee -a "$LOG_FILE"
    log "[INFO] Nothing above this line means no errors worth reading."
    exit 0
fi

SERVICE="${1:-}"
LINES="${2:-100}"

if [ -n "$SERVICE" ]; then
    log "[INFO] Last $LINES lines from $SERVICE"
    docker compose logs --tail="$LINES" --no-color "$SERVICE" 2>&1 | tee -a "$LOG_FILE"
else
    log "[INFO] Last $LINES lines from every service"
    docker compose logs --tail="$LINES" --no-color 2>&1 | tee -a "$LOG_FILE"
fi

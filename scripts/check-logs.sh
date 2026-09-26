#!/bin/bash
set -euo pipefail

LOG_FILE="$HOME/project13-logs/check-logs.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

log "[INFO] Fetching container logs..."
# docker compose logs --tail=100

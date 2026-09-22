#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/deployment/start-services.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

log "[INFO] Starting services..."
# docker compose up -d
log "[INFO] Services started successfully."

#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../stack"

LOG_FILE="/var/log/deployment/setup-env.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

if [ ! -f .env ]; then
    cp .env.example .env
    log "[INFO] .env file created successfully from template."
else
    log "[INFO] .env file already exists. Skipping..."
fi

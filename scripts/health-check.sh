#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/deployment/health-check.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

check_endpoint() {
    local url=$1
    local expected_status=$2
    log "[INFO] Checking endpoint: $url"
    # curl -s -o /dev/null -w "%{http_code}" "$url"
}

log "[INFO] Running health checks..."

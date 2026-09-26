#!/bin/bash
set -euo pipefail

LOG_DIR="$HOME/project13-logs"
LOG_FILE="${LOG_DIR}/install-packages.log"

log() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Root privileges required." >&2
        exit 1
    fi
}

init_logging() {
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR"
    fi
}

update_system() {
    log "[INFO] Updating package lists..."
    apt-get update -y
    log "[INFO] Package lists updated successfully."
}

install_base_packages() {
    local packages=("curl" "wget" "git" "ca-certificates" "gnupg" "lsb-release" "unzip" "jq")
    log "[INFO] Required packages: ${packages[*]}"

    for pkg in "${packages[@]}"; do
        if dpkg -l | grep -qw "$pkg"; then
            log "[INFO] Package '$pkg' is already installed. Skipping..."
        else
            log "[INFO] Installing package: $pkg..."
            apt-get install -y "$pkg"
            log "[INFO] Package '$pkg' installed successfully."
        fi
    done
}

main() {
    check_root
    init_logging
    
    log "=================================================="
    log "Starting package installation script"
    log "=================================================="

    update_system
    install_base_packages

    log "=================================================="
    log "All base packages installed successfully!"
    log "=================================================="
}

main "$@"

#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log/deployment"
LOG_FILE="${LOG_DIR}/install-docker.log"

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

install_docker_prerequisites() {
    log "[INFO] Installing Docker prerequisites..."
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    log "[INFO] Prerequisites installed successfully."
}

add_docker_repository() {
    log "[INFO] Adding Docker official GPG key and repository..."
    
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
      
    apt-get update -y
    log "[INFO] Docker repository added successfully."
}

install_docker_engine() {
    if command -v docker &> /dev/null; then
        log "[INFO] Docker is already installed. Skipping engine installation..."
    else
        log "[INFO] Installing Docker Engine and Docker Compose plugin..."
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        log "[INFO] Docker Engine installed successfully."
    fi
}

configure_docker_service() {
    log "[INFO] Enabling and starting Docker service..."
    systemctl enable --now docker
    
    # إضافة المستخدم الحالي لمجموعة docker لتجنب استخدام sudo مع أوامر docker
    local current_user="${SUDO_USER:-$USER}"
    if id "$current_user" &>/dev/null && groups "$current_user" | grep -qw "docker"; then
        log "[INFO] User '$current_user' is already in the docker group."
    else
        log "[INFO] Adding user '$current_user' to the docker group..."
        usermod -aG docker "$current_user"
    fi
}

verify_installation() {
    log "[INFO] Verifying Docker installation..."
    docker --version
    docker compose version
    log "[INFO] Docker verification completed successfully."
}

main() {
    check_root
    init_logging
    
    log "=================================================="
    log "Starting Docker installation script"
    log "=================================================="

    install_docker_prerequisites
    add_docker_repository
    install_docker_engine
    configure_docker_service
    verify_installation

    log "=================================================="
    log "Docker and Docker Compose installed successfully! 🚀"
    log "=================================================="
}

main "$@"

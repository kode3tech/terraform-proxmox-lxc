#!/bin/bash
# =============================================================================
# LXC CONTAINER INITIALIZATION SCRIPT
# =============================================================================
# This script is executed inside the container after initialization via SSH
#
# Purpose: Complete Docker installation and system configuration
# Author: Terraform Provisioner
# Date: $(date)
# =============================================================================
# NOTE: Do not use 'set -o pipefail' - not supported by /bin/sh (dash)
# Terraform remote-exec uses /bin/sh by default, not bash
# =============================================================================

set -e  # Exit on first error
set -u  # Exit on undefined variable

# =============================================================================
# CONFIGURATION
# =============================================================================
TIMEZONE="America/Sao_Paulo"
APP_USER="appuser"
LOG_FILE="/var/log/container-init.log"

# =============================================================================
# FUNCTIONS
# =============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $*"
    exit 1
}

section() {
    log ""
    log "========================================="
    log "$*"
    log "========================================="
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

section "Container Initialization Started"
log "Hostname: $(hostname)"
log "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
log "Kernel: $(uname -r)"

# Wait for system to be fully ready
section "Waiting for system to be ready"
until systemctl is-system-running --wait 2>/dev/null; do
    log "System not ready, waiting..."
    sleep 2
done
log "System is ready"

# Update package lists
section "Updating package lists"
apt-get update || error "Failed to update package lists"
log "Package lists updated successfully"

# Install essential packages
section "Installing essential packages"
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    || error "Failed to install essential packages"
log "Essential packages installed successfully"

# Install Docker
section "Installing Docker"
log "Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    || error "Failed to add Docker GPG key"

log "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    || error "Failed to add Docker repository"

log "Updating package lists with Docker repository..."
apt-get update || error "Failed to update package lists after adding Docker repo"

log "Installing Docker packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    || error "Failed to install Docker packages"

log "Docker installed successfully"
docker --version | tee -a "$LOG_FILE"

# Configure Docker
section "Configuring Docker"
systemctl enable docker || error "Failed to enable Docker service"
systemctl start docker || error "Failed to start Docker service"

# Wait for Docker to be ready
sleep 5
docker info > /dev/null || error "Docker is not running properly"
log "Docker is running and healthy"

# Set timezone
section "Configuring timezone"
timedatectl set-timezone "$TIMEZONE" || log "Warning: Failed to set timezone"
log "Timezone: $(timedatectl | grep 'Time zone' || echo 'Unknown')"

# Create application user
section "Creating application user"
if ! id "$APP_USER" &>/dev/null; then
    useradd -m -s /bin/bash -G docker "$APP_USER" || error "Failed to create user $APP_USER"
    log "User $APP_USER created successfully"
else
    log "User $APP_USER already exists, adding to docker group..."
    usermod -aG docker "$APP_USER" || log "Warning: Failed to add user to docker group"
fi

# Configure Docker daemon (optional optimizations)
section "Configuring Docker daemon"
cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl restart docker || log "Warning: Failed to restart Docker after configuration"
log "Docker daemon configured"

# Network verification
section "Network verification"
log "Network interfaces:"
ip addr show | tee -a "$LOG_FILE"

log "Routing table:"
ip route show | tee -a "$LOG_FILE"

log "Testing connectivity to 8.8.8.8..."
if ping -c 3 8.8.8.8 &>/dev/null; then
    log "Internet connectivity: OK"
else
    log "Warning: No internet connectivity"
fi

log "Testing connectivity to docker.com..."
if ping -c 3 docker.com &>/dev/null; then
    log "Docker.com connectivity: OK"
else
    log "Warning: Cannot reach docker.com"
fi

# Test Docker
section "Testing Docker installation"
log "Running Docker hello-world test..."
if docker run --rm hello-world &>/dev/null; then
    log "Docker test: SUCCESS"
else
    log "Warning: Docker test failed"
fi

# System information
section "Final system status"
log "Docker version: $(docker --version)"
log "Docker Compose version: $(docker compose version)"
log "System uptime: $(uptime)"
log "Memory usage:"
free -h | tee -a "$LOG_FILE"
log "Disk usage:"
df -h | tee -a "$LOG_FILE"

section "Container Initialization Completed Successfully"
log "Log file saved to: $LOG_FILE"

exit 0

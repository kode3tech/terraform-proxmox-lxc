#!/bin/sh
# =============================================================================
# 04-install-docker.sh
# Installs Docker CE and configures it for the application user
# =============================================================================

set -e
set -u

echo "======================================"
echo "04: Installing Docker"
echo "======================================"

# Check if Docker is already installed
if command -v docker > /dev/null 2>&1; then
  echo "→ Docker already installed: $(docker --version)"
  exit 0
fi

# Install prerequisites
apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Add Docker's official GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Add appuser to docker group
if id "appuser" > /dev/null 2>&1; then
  usermod -aG docker appuser
  echo "✓ User 'appuser' added to docker group"
fi

# Verify installation
docker --version

echo "✓ Docker installation completed"

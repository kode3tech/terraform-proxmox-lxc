#!/bin/sh
# =============================================================================
# 01-system-update.sh
# Updates system packages and installs basic utilities
# =============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

echo "======================================"
echo "01: Updating system packages"
echo "======================================"

# Update package lists
apt-get update

# Upgrade existing packages (non-interactive)
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install basic utilities
apt-get install -y \
  curl \
  wget \
  vim \
  git \
  htop \
  net-tools \
  ca-certificates

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✓ System update completed"

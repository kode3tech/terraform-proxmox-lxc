#!/bin/bash
# =============================================================================
# BASIC SYSTEM CONFIGURATION
# =============================================================================
# Minimal container setup for testing provisioner functionality
# =============================================================================

set -e

echo "========================================="
echo "Basic System Configuration"
echo "========================================="

# System information
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"

# Update packages
echo "Updating package lists..."
apt-get update

# Install minimal tools
echo "Installing basic tools..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    vim \
    htop

# Configure timezone
echo "Setting timezone..."
timedatectl set-timezone America/Sao_Paulo

# Show final status
echo "========================================="
echo "Configuration completed"
echo "Current time: $(date)"
echo "========================================="

exit 0

#!/bin/sh
# =============================================================================
# 02-configure-timezone.sh
# Configures timezone and NTP
# =============================================================================

set -e
set -u

echo "======================================"
echo "02: Configuring timezone"
echo "======================================"

# Set timezone to America/Sao_Paulo
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Configure timezone in debconf
echo "tzdata tzdata/Areas select America" | debconf-set-selections
echo "tzdata tzdata/Zones/America select Sao_Paulo" | debconf-set-selections

# Reconfigure tzdata (non-interactive)
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive tzdata

# Install and configure NTP
apt-get update
apt-get install -y systemd-timesyncd

# Enable time synchronization
timedatectl set-ntp true

echo "✓ Timezone configured: $(date)"

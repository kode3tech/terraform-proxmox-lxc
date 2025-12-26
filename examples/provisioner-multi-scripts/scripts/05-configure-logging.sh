#!/bin/sh
# =============================================================================
# 05-configure-logging.sh
# Configures system logging and log rotation
# =============================================================================

set -e
set -u

echo "======================================"
echo "05: Configuring logging"
echo "======================================"

# Create application log directory
APP_LOG_DIR="/var/log/app"
mkdir -p "$APP_LOG_DIR"
chmod 755 "$APP_LOG_DIR"

# Create logrotate configuration for application logs
cat > /etc/logrotate.d/app <<'EOF'
/var/log/app/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 appuser appgroup
}
EOF

# Configure rsyslog for application logging
cat > /etc/rsyslog.d/50-app.conf <<'EOF'
# Application logging configuration
:programname, isequal, "app" /var/log/app/app.log
& stop
EOF

# Restart rsyslog to apply changes
systemctl restart rsyslog

echo "✓ Logging configuration completed"
echo "  - Application logs: $APP_LOG_DIR"
echo "  - Rotation: daily, keep 7 days"

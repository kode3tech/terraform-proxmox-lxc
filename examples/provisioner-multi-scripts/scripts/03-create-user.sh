#!/bin/sh
# =============================================================================
# 03-create-user.sh
# Creates application user and configures SSH access
# =============================================================================

set -e
set -u

echo "======================================"
echo "03: Creating application user"
echo "======================================"

USERNAME="appuser"
GROUPNAME="appgroup"

# Check if group already exists
if ! getent group "$GROUPNAME" > /dev/null 2>&1; then
  groupadd "$GROUPNAME"
  echo "✓ Group '$GROUPNAME' created"
else
  echo "→ Group '$GROUPNAME' already exists"
fi

# Check if user already exists
if ! id "$USERNAME" > /dev/null 2>&1; then
  useradd -m -s /bin/bash -g "$GROUPNAME" "$USERNAME"
  echo "✓ User '$USERNAME' created"
else
  echo "→ User '$USERNAME' already exists"
fi

# Create necessary directories
mkdir -p /home/"$USERNAME"/.ssh
chmod 700 /home/"$USERNAME"/.ssh

# Set ownership
chown -R "$USERNAME":"$GROUPNAME" /home/"$USERNAME"

echo "✓ User configuration completed"

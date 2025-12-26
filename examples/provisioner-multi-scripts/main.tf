# =============================================================================
# PROVISIONER EXAMPLE - MULTIPLE SCRIPTS
# =============================================================================
# This example demonstrates how to use provisioner_scripts_dir to execute
# multiple shell scripts in a controlled order.
#
# FEATURES DEMONSTRATED:
# - Multiple modular scripts execution
# - Controlled execution order using numeric prefixes
# - System updates and package installation
# - Timezone and NTP configuration
# - User and group management
# - Docker installation and configuration
# - Logging setup with log rotation
#
# PREREQUISITES:
# 1. SSH key pair generated:
#    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
#
# 2. Environment variables set:
#    export PM_API_URL="https://proxmox.example.com:8006/api2/json"
#    export PM_API_TOKEN_ID="terraform@pam!mytoken"
#    export PM_API_TOKEN_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#    export PM_TLS_INSECURE="true"
#
# 3. Container must have static IP (not DHCP) for SSH connection
#
# SCRIPT EXECUTION ORDER:
# Scripts are executed in lexicographic order:
#   01-system-update.sh      -> Updates packages and installs utilities
#   02-configure-timezone.sh -> Sets timezone and NTP
#   03-create-user.sh        -> Creates appuser and appgroup
#   04-install-docker.sh     -> Installs Docker CE
#   05-configure-logging.sh  -> Configures application logging
# =============================================================================

module "lxc_with_multi_scripts" {
  source = "../.."

  # Required parameters
  hostname    = "lxc-multi-scripts-demo"
  target_node = "pve01"
  ostemplate  = "nas:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

  # Basic configuration
  vmid         = 401
  cores        = 2
  memory       = 2048
  swap         = 512
  unprivileged = true
  onboot       = true
  start        = true

  # Root filesystem
  rootfs_storage = "nas"
  rootfs_size    = "20G"

  # Network configuration (MUST be static IP for provisioner)
  network_bridge  = "vmbr0"
  network_ip      = "192.168.1.221/24"
  network_gateway = "192.168.1.1"

  # SSH public key (REQUIRED for SSH key authentication)
  ssh_public_keys = file("~/.ssh/id_rsa.pub")

  # Features
  features = {
    nesting = true # Required for Docker
  }

  # =============================================================================
  # PROVISIONER CONFIGURATION - MULTIPLE SCRIPTS
  # =============================================================================
  provisioner_enabled = true

  # SSH connection configuration
  provisioner_ssh_user        = "root"
  provisioner_ssh_private_key = "~/.ssh/id_rsa" # File path (recommended)

  # Execute all *.sh scripts from directory (in lexicographic order)
  provisioner_scripts_dir = "${path.module}/scripts"

  # Connection timeout (increased for multiple scripts)
  provisioner_timeout = "10m"

  # Description
  description = "LXC container with multi-script provisioning (Docker + logging)"

  # Tags
  tags = {
    environment = "demo"
    purpose     = "provisioner-multi-scripts"
    stack       = "docker"
  }
}

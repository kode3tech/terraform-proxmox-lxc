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
  hostname    = var.hostname
  target_node = var.target_node
  ostemplate  = var.ostemplate

  # Basic configuration
  vmid         = var.vmid
  cores        = 2
  memory       = 2048
  swap         = 512
  unprivileged = true
  onboot       = true
  start        = true

  # Root filesystem
  rootfs_storage = var.rootfs_storage
  rootfs_size    = "20G"

  # Network configuration (MUST be static IP for provisioner)
  network_bridge  = var.network_bridge
  network_ip      = var.network_ip
  network_gateway = var.network_gateway

  # SSH public key (REQUIRED for SSH key authentication)
  # COMMENTED: Uncomment and provide your real SSH public key for testing
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")

  # For testing without SSH keys, use password instead:
  password = "YourSecurePassword123!"

  # Features
  features = {
    nesting = true # Required for Docker
  }

  # =============================================================================
  # PROVISIONER CONFIGURATION - MULTIPLE SCRIPTS
  # =============================================================================
  # NOTE: Provisioner is DISABLED by default for security and CI validation.
  # To enable provisioning:
  # 1. Set provisioner_enabled = true
  # 2. Provide your SSH private key using file() function:
  #    provisioner_ssh_private_key = file("~/.ssh/id_rsa")
  # 3. Ensure the container has your public key configured via ssh_public_keys
  # =============================================================================
  provisioner_enabled = false
  # Uncomment and configure when ready to use provisioner:
  # provisioner_ssh_user        = "root"
  # provisioner_ssh_private_key = file("~/.ssh/id_rsa")  # YOUR private key
  # provisioner_scripts_dir     = "${path.module}/scripts"

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

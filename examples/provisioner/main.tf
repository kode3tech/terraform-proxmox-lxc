# =============================================================================
# PROVISIONER EXAMPLE
# =============================================================================
# This example demonstrates how to use remote-exec provisioner to automatically
# configure the container after initialization via SSH.
#
# FEATURES DEMONSTRATED:
# - Automatic package installation (Docker, utilities)
# - System configuration (timezone, locale)
# - Service management (enable/start Docker)
# - User creation and SSH key injection
# - Network configuration verification
# - Script-based provisioning (external file)
#
# PREREQUISITES:
# 1. SSH key pair generated:
#    ssh-keygen -t rsa -b 4096 -f ~/.ssh/proxmox_lxc -N ""
#
# 2. Environment variables set:
#    export PM_API_URL="https://proxmox.example.com:8006/api2/json"
#    export PM_API_TOKEN_ID="terraform@pam!mytoken"
#    export PM_API_TOKEN_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#    export PM_TLS_INSECURE="true"
#
# 3. Container must have static IP (not DHCP) for SSH connection
# =============================================================================

# =============================================================================
# EXAMPLE 1: Using SSH Key Authentication + External Script
# =============================================================================
module "lxc_with_script" {
  source = "../.."

  # Required parameters
  hostname    = var.hostname
  target_node = var.target_node
  ostemplate  = var.ostemplate

  # Basic configuration
  vmid         = var.vmid
  cores        = var.cores
  memory       = var.memory
  swap         = var.swap
  unprivileged = var.unprivileged
  onboot       = var.onboot
  start        = var.start

  # Root filesystem
  rootfs_storage = var.rootfs_storage
  rootfs_size    = var.rootfs_size

  # Network configuration (MUST be static IP for provisioner)
  network_bridge  = var.network_bridge
  network_ip      = var.network_ip
  network_gateway = var.network_gateway

  # SSH public key (REQUIRED for SSH key authentication)
  # COMMENTED: Uncomment and provide your real SSH public key for testing
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")

  # For testing without SSH keys, use password instead:
  password = var.password

  # Features
  features = {
    nesting = var.features_nesting # Required for Docker
  }

  # =============================================================================
  # PROVISIONER CONFIGURATION - SSH KEY + SCRIPT FILE
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
  # provisioner_script_path     = "${path.module}/scripts/install-docker.sh"

  # Description
  description = var.description

  # Tags
  tags = var.tags
}

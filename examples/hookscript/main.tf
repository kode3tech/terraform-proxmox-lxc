# =============================================================================
# HOOKSCRIPT EXAMPLE
# =============================================================================
# This example demonstrates how to use hookscripts with LXC containers.
# Hookscripts are executed during container lifecycle events.
#
# PREREQUISITES:
# 1. Upload hookscript.sh to Proxmox:
#    scp hookscript.sh root@<proxmox-host>:/var/lib/vz/snippets/
#
# 2. Make it executable:
#    ssh root@<proxmox-host> "chmod +x /var/lib/vz/snippets/hookscript.sh"
#
# 3. Ensure storage 'local' has 'snippets' content type enabled:
#    pvesm set local --content vztmpl,iso,snippets
#
# =============================================================================

module "lxc_with_hookscript" {
  source = "../.."

  # Required parameters
  hostname    = var.hostname
  target_node = var.target_node
  ostemplate  = var.ostemplate

  # Basic configuration
  vmid         = var.vmid
  cores        = 2
  memory       = 2048
  swap         = 1024
  unprivileged = true
  onboot       = false
  start        = true

  # Root filesystem
  rootfs_storage = var.rootfs_storage
  rootfs_size    = "8G"

  # Network configuration
  network_bridge  = var.network_bridge
  network_ip      = var.network_ip
  network_gateway = var.network_gateway

  # =============================================================================
  # HOOKSCRIPT CONFIGURATION
  # =============================================================================
  # The hookscript must be stored in a Proxmox storage with 'snippets' content
  # Format: "storage:snippets/script-name.sh"
  #
  # The script will be executed during these phases:
  # - pre-start:  Before container starts
  # - post-start: After container starts
  # - pre-stop:   Before container stops
  # - post-stop:  After container stops
  # =============================================================================
  hookscript = var.hookscript

  # SSH access (recommended for post-start configuration)
  # COMMENTED: Uncomment and provide your real SSH public key for testing
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")

  # Root Password (NOT RECOMMENDED - use only for testing)
  # Set root password for console/SSH access
  password = var.root_password

  # Features
  features = {
    nesting = true # Required for Docker/containers
  }

  # Description
  description = "LXC container with hookscript demonstration"

  # Tags
  tags = {
    environment = "demo"
    purpose     = "hookscript-testing"
  }
}

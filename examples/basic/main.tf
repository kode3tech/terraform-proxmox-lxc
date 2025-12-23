module "lxc_container" {
  source = "../.."

  # Naming convention
  prefix   = "app"
  env      = "dev"
  workload = "web"
  index    = "01"

  # Proxmox configuration
  target_node = "pve-node01" # Change to your Proxmox node name
  vmid        = null         # Auto-assign VM ID

  # Container image
  ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

  # Resources
  cores  = 2
  memory = 2048
  swap   = 1024

  # Storage
  rootfs_storage = "local-lvm"
  rootfs_size    = "10G"

  # Network
  network_bridge  = "vmbr0"
  network_ip      = "192.168.1.100/24"
  network_gateway = "192.168.1.1"
  # network_vlan    = 10 # Optional VLAN tag

  # Container settings
  unprivileged = true
  onboot       = false
  start        = true

  # SSH access (replace with your public key)
  ssh_public_keys = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... user@hostname
  EOT

  # Optional password (not recommended for production)
  # password = "change-me"

  # Additional tags
  tags = {
    project = "example"
    owner   = "infrastructure-team"
  }

  # Description
  description = "Example web application container"
}

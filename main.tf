locals {
  # Generate standardized hostname following naming convention
  hostname = "${var.prefix}-${var.env}-${var.workload}-${var.index}"

  # Merge mandatory tags with user-provided tags
  merged_tags = merge(
    {
      "managed-by" = "terraform"
      "module"     = "lxc"
      "env"        = var.env
      "workload"   = var.workload
    },
    var.tags
  )

  # Convert tags map to description format (some Proxmox versions use description for metadata)
  tags_description = join(", ", [for k, v in local.merged_tags : "${k}=${v}"])

  # Final description combining user description and tags
  final_description = var.description != "" ? "${var.description} | ${local.tags_description}" : local.tags_description
}

resource "proxmox_lxc" "this" {
  target_node  = var.target_node
  vmid         = var.vmid
  hostname     = local.hostname
  ostemplate   = var.ostemplate
  arch         = var.arch
  unprivileged = var.unprivileged
  onboot       = var.onboot
  start        = var.start
  description  = local.final_description

  # Resource allocation
  cores  = var.cores
  memory = var.memory
  swap   = var.swap

  # Root filesystem configuration
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  # Network configuration
  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = var.network_ip
    gw     = var.network_gateway
    tag    = var.network_vlan
  }

  # SSH public keys injection
  ssh_public_keys = var.ssh_public_keys

  # Root password (if provided)
  password = var.password

  # Lifecycle configuration
  lifecycle {
    create_before_destroy = false

    # Prevent accidental destruction
    precondition {
      condition     = length(local.hostname) <= 64
      error_message = "Generated hostname '${local.hostname}' exceeds 64 characters"
    }

    precondition {
      condition     = can(regex("^[a-z0-9-]+$", local.hostname))
      error_message = "Generated hostname '${local.hostname}' contains invalid characters (only lowercase letters, numbers, and hyphens allowed)"
    }
  }
}

locals {
  # Merge mandatory tags with user-provided tags
  merged_tags = merge(
    {
      "managed-by" = "terraform"
      "module"     = "lxc"
    },
    var.tags
  )

  # Convert tags map to Proxmox tags format (semicolon-delimited values only)
  # Proxmox tags can only contain: a-zA-Z0-9-._
  # Sort values to ensure consistent ordering and prevent drift
  # Example: "terraform;production;web-server;devops"
  tags_string = join(";", sort(values(local.merged_tags)))

  # Keep full tags in description for complete visibility
  # Sort keys to ensure consistent ordering and prevent drift
  tags_description = join(", ", [for k in sort(keys(local.merged_tags)) : "${k}=${local.merged_tags[k]}"])

  # Final description combining user description and tags
  final_description = var.description != "" ? "${var.description} | ${local.tags_description}" : local.tags_description
}

resource "proxmox_lxc" "this" {
  target_node  = var.target_node
  vmid         = var.vmid
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  arch         = var.arch
  unprivileged = var.unprivileged
  onboot       = var.onboot
  start        = var.start
  description  = local.final_description
  tags         = local.tags_string

  # Resource allocation
  cores    = var.cores
  memory   = var.memory
  swap     = var.swap
  cpulimit = var.cpulimit
  cpuunits = var.cpuunits

  # Storage
  bwlimit = var.bwlimit

  # Console configuration
  cmode   = var.cmode
  console = var.console
  tty     = var.tty

  # Template and protection
  template   = var.template
  protection = var.protection
  force      = var.force
  unique     = var.unique
  restore    = var.restore

  # DNS configuration
  nameserver   = var.nameserver
  searchdomain = var.searchdomain

  # Advanced options
  ostype     = var.ostype
  pool       = var.pool
  startup    = var.startup
  hookscript = var.hookscript

  # High Availability
  hastate = var.hastate
  hagroup = var.hagroup

  # Root filesystem configuration
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  # Network configuration
  network {
    name     = "eth0"
    bridge   = var.network_bridge
    ip       = var.network_ip
    gw       = var.network_gateway
    ip6      = var.network_ip6
    gw6      = var.network_gw6
    hwaddr   = var.network_hwaddr
    mtu      = var.network_mtu
    rate     = var.network_rate
    tag      = var.network_vlan
    firewall = var.network_firewall
  }

  # Additional network interfaces (eth1, eth2, etc.)
  dynamic "network" {
    for_each = var.additional_networks
    content {
      name     = network.value.name
      bridge   = network.value.bridge
      ip       = network.value.ip
      gw       = network.value.gw
      ip6      = network.value.ip6
      gw6      = network.value.gw6
      hwaddr   = network.value.hwaddr
      mtu      = network.value.mtu
      rate     = network.value.rate
      tag      = network.value.tag
      firewall = network.value.firewall
    }
  }

  # Additional storage mountpoints
  dynamic "mountpoint" {
    for_each = var.mountpoints
    content {
      key       = mountpoint.value.slot
      slot      = mountpoint.value.slot
      storage   = mountpoint.value.storage
      mp        = mountpoint.value.mp
      size      = mountpoint.value.size
      acl       = mountpoint.value.acl
      backup    = mountpoint.value.backup
      quota     = mountpoint.value.quota
      replicate = mountpoint.value.replicate
      shared    = mountpoint.value.shared
    }
  }

  # Advanced features
  dynamic "features" {
    for_each = var.features != null ? [var.features] : []
    content {
      fuse    = features.value.fuse
      keyctl  = features.value.keyctl
      mount   = features.value.mount
      nesting = features.value.nesting
    }
  }

  # SSH public keys injection
  ssh_public_keys = var.ssh_public_keys

  # Root password (if provided)
  password = var.password

  # Lifecycle configuration
  lifecycle {
    create_before_destroy = false

    # Ignore changes to parameters that cannot be reliably modified or cause drift
    # bwlimit: Only applies during creation/migration, not runtime modification
    # description: Proxmox may modify formatting (whitespace, newlines) causing drift
    # mountpoint: Proxmox may change backup attribute based on storage configuration
    ignore_changes = [
      bwlimit,
      description,
      mountpoint
    ]

    # Validate quota compatibility with unprivileged containers
    precondition {
      condition = !var.unprivileged || alltrue([
        for mp in var.mountpoints : mp.quota == null || mp.quota == false
      ])
      error_message = <<-EOT
        Quotas are not supported by unprivileged containers.

        Solutions:
          1. Remove quota = true from all mountpoints (recommended)
          2. Set unprivileged = false (NOT RECOMMENDED - security risk)

        Unprivileged containers use UID/GID mapping which conflicts with quota functionality.
        For security reasons, use unprivileged containers without quotas.
      EOT
    }

    # Prevent accidental destruction
    precondition {
      condition     = length(var.hostname) <= 64
      error_message = "Hostname '${var.hostname}' exceeds 64 characters"
    }

    precondition {
      condition     = can(regex("^[a-z0-9-]+$", var.hostname))
      error_message = "Hostname '${var.hostname}' contains invalid characters (only lowercase letters, numbers, and hyphens allowed)"
    }

    precondition {
      condition     = var.hagroup == null || var.hastate != null
      error_message = "hastate must be set when hagroup is defined"
    }
  }
}

# =============================================================================
# =============================================================================
# REMOTE-EXEC PROVISIONER
# =============================================================================
# Execute commands inside the container after initialization via SSH
# Supports SSH key authentication only (password auth removed due to security concerns)
# Supports inline commands OR external script file
# =============================================================================
locals {
  # Extract IP address from network_ip (remove CIDR notation)
  # Examples: "192.168.1.100/24" -> "192.168.1.100", "dhcp" -> null
  extracted_ip = var.network_ip != "dhcp" && var.network_ip != "" ? split("/", var.network_ip)[0] : null

  # Determine SSH host (explicit value takes precedence)
  ssh_host = var.provisioner_ssh_host != null ? var.provisioner_ssh_host : local.extracted_ip

  # Process SSH private key (file path or content)
  # If it starts with "-----BEGIN", it's key content; otherwise treat as file path
  # Use nonsensitive() to unmark the value for string operations, then mark it back as sensitive
  ssh_private_key = var.provisioner_ssh_private_key != null && !can(regex("^-----BEGIN", nonsensitive(var.provisioner_ssh_private_key))) ? sensitive(file(nonsensitive(var.provisioner_ssh_private_key))) : var.provisioner_ssh_private_key

  # Determine execution mode: scripts_dir > script_path > commands
  use_scripts_dir = var.provisioner_scripts_dir != null
  use_script_file = !local.use_scripts_dir && var.provisioner_script_path != null

  # Process scripts directory: list all *.sh files and sort them
  # Sorting ensures predictable execution order (use 01-, 02- prefixes for control)
  script_files = local.use_scripts_dir ? sort(fileset(var.provisioner_scripts_dir, "*.sh")) : []

  # Concatenate all scripts from directory into a single script
  # Each script is separated by a header comment for debugging
  scripts_content = local.use_scripts_dir ? join("\n\n", [
    for script_file in local.script_files :
    "# ============================================================================\n# Executing: ${script_file}\n# ============================================================================\n${file("${var.provisioner_scripts_dir}/${script_file}")}"
  ]) : ""

  # Single script file content
  script_content = local.use_script_file ? file(var.provisioner_script_path) : ""

  # Final commands list based on mode
  provisioner_commands = local.use_scripts_dir ? [local.scripts_content] : (local.use_script_file ? [local.script_content] : var.provisioner_commands)
}

resource "null_resource" "provisioner" {
  count = var.provisioner_enabled ? 1 : 0

  # Re-run provisioner when container is recreated or commands/script(s) change
  triggers = {
    container_id = proxmox_lxc.this.id
    # Hash changes when any script file or inline commands change
    commands = local.use_scripts_dir ? md5(local.scripts_content) : (local.use_script_file ? md5(local.script_content) : join(",", var.provisioner_commands))
  }

  connection {
    type        = "ssh"
    user        = var.provisioner_ssh_user
    host        = local.ssh_host
    private_key = local.ssh_private_key
    timeout     = var.provisioner_timeout
  }

  # Wait for SSH to be available and execute commands
  provisioner "remote-exec" {
    inline = concat(
      [
        "# Wait for system to be ready",
        "until systemctl is-system-running --wait 2>/dev/null; do sleep 2; done",
        "echo 'Container is ready for provisioning'"
      ],
      local.provisioner_commands
    )
  }

  depends_on = [proxmox_lxc.this]

  lifecycle {
    # Validate SSH private key is provided
    precondition {
      condition     = !var.provisioner_enabled || var.provisioner_ssh_private_key != null
      error_message = <<-EOT
        SSH private key required when provisioner_enabled = true.

        Set provisioner_ssh_private_key to:
          - File path: "~/.ssh/id_rsa"
          - Key content: file("~/.ssh/id_rsa")

        Also ensure ssh_public_keys is configured in the container.
      EOT
    }

    # Validate DHCP incompatibility with provisioner
    precondition {
      condition     = !var.provisioner_enabled || var.network_ip != "dhcp" || var.provisioner_ssh_host != null
      error_message = <<-EOT
        ╔═══════════════════════════════════════════════════════════════════════╗
        ║  DHCP is not compatible with automatic provisioner execution         ║
        ╚═══════════════════════════════════════════════════════════════════════╝

        WHY THIS LIMITATION EXISTS:

        The Telmate/proxmox provider does not expose the DHCP-assigned IP address
        as an output. Terraform needs to know the SSH connection target during the
        PLAN phase, but DHCP IPs are only assigned during container startup.

        This is a fundamental limitation of the provider, not the module.

        SOLUTIONS (choose one):

        1. ✅ Use static IP (RECOMMENDED):
           network_ip = "192.168.1.100/24"
           provisioner_enabled = true

        2. ✅ Provide IP manually after container starts:
           network_ip = "dhcp"
           provisioner_ssh_host = "192.168.1.100"  # Set after checking container IP
           provisioner_enabled = true

        3. ✅ Disable provisioner and use external tools:
           network_ip = "dhcp"
           provisioner_enabled = false
           # Then use Ansible, SSH scripts, or manual configuration

        CHECKING DHCP IP:
        After container creation, you can find the IP with:
          ssh root@proxmox-host "pct exec <vmid> -- hostname -I"

        For automatic configuration with DHCP, consider using:
          - Ansible playbooks (run after terraform apply)
          - Cloud-init (for VMs, not LXC)
          - Manual SSH after discovering the IP
      EOT
    }

    # Validate SSH host can be determined
    precondition {
      condition     = !var.provisioner_enabled || local.ssh_host != null
      error_message = <<-EOT
        Cannot determine SSH connection target.

        The provisioner needs to know where to connect. Provide ONE of:

        1. Static IP in network_ip:
           network_ip = "192.168.1.100/24"

        2. Explicit SSH host:
           provisioner_ssh_host = "192.168.1.100"

        Current configuration:
          - network_ip: ${var.network_ip}
          - provisioner_ssh_host: ${var.provisioner_ssh_host == null ? "not set" : var.provisioner_ssh_host}
      EOT
    }

    # Validate commands, script, or scripts directory is provided
    precondition {
      condition     = !var.provisioner_enabled || (length(var.provisioner_commands) > 0 || var.provisioner_script_path != null || var.provisioner_scripts_dir != null)
      error_message = <<-EOT
        Commands, script, or scripts directory required when provisioner_enabled = true.

        Provide ONE of:
          - provisioner_commands = ["cmd1", "cmd2", ...]
          - provisioner_script_path = "path/to/script.sh"
          - provisioner_scripts_dir = "path/to/scripts/" (executes all *.sh files in order)
      EOT
    }

    # Validate only one execution method is used
    precondition {
      condition = !var.provisioner_enabled || (
        (length(var.provisioner_commands) > 0 ? 1 : 0) +
        (var.provisioner_script_path != null ? 1 : 0) +
        (var.provisioner_scripts_dir != null ? 1 : 0)
      ) == 1
      error_message = <<-EOT
        Only ONE provisioner method can be used at a time.

        Choose ONE of:
          - provisioner_commands (inline commands)
          - provisioner_script_path (single script file)
          - provisioner_scripts_dir (directory with multiple *.sh scripts)

        Current configuration:
          - provisioner_commands: ${length(var.provisioner_commands) > 0 ? "SET" : "not set"}
          - provisioner_script_path: ${var.provisioner_script_path != null ? "SET" : "not set"}
          - provisioner_scripts_dir: ${var.provisioner_scripts_dir != null ? "SET" : "not set"}
      EOT
    }

    # Validate SSH public keys are configured
    precondition {
      condition     = !var.provisioner_enabled || var.ssh_public_keys != null
      error_message = <<-EOT
        SSH public keys must be configured when provisioner_enabled = true.

        The provisioner requires SSH access to the container. Set:
          ssh_public_keys = file("~/.ssh/id_rsa.pub")

        This injects your public key into the container's authorized_keys,
        allowing the provisioner to connect using your private key.
      EOT
    }
  }
}

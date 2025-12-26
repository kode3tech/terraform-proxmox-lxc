# =============================================================================
# BASIC LXC CONTAINER EXAMPLE
# =============================================================================
# This example demonstrates the minimum required configuration to create an
# LXC container using this module, based on the official Telmate/proxmox
# provider documentation.
#
# Reference: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc
# =============================================================================

module "lxc_container" {
  source = "../.."

  # ---------------------------------------------------------------------------
  # REQUIRED ARGUMENTS
  # ---------------------------------------------------------------------------
  hostname    = var.hostname    # Container hostname
  target_node = var.target_node # Proxmox cluster node name
  ostemplate  = var.ostemplate  # Volume identifier pointing to OS template or backup file

  # ---------------------------------------------------------------------------
  # STORAGE CONFIGURATION
  # ---------------------------------------------------------------------------
  rootfs_storage = var.rootfs_storage # Storage pool for root filesystem
  rootfs_size    = var.rootfs_size    # Root filesystem size

  # ---------------------------------------------------------------------------
  # NETWORK CONFIGURATION
  # ---------------------------------------------------------------------------
  network_bridge = var.network_bridge # Bridge to attach
  network_ip     = var.network_ip     # Use DHCP for automatic IP assignment

  # ---------------------------------------------------------------------------
  # AUTHENTICATION & ACCESS
  # ---------------------------------------------------------------------------
  # IMPORTANT: Without authentication, you can only access via Proxmox console!
  # This example uses password authentication for simplicity.
  # For production, use ssh_public_keys instead:
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")
  # ---------------------------------------------------------------------------
  password = var.root_password

  # Note: With DHCP, you'll need to check the IP after creation:
  # - Via Proxmox UI: Container > Summary > IP Address
  # - Via CLI: ssh root@proxmox-host "pct exec <vmid> -- hostname -I"
  # Then SSH: ssh root@<container-ip>

  # ---------------------------------------------------------------------------
  # OPTIONAL ARGUMENTS (Provider Optional)
  # ---------------------------------------------------------------------------
  # The following arguments are optional. Uncomment and modify as needed.
  # Provider documentation: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc
  # ---------------------------------------------------------------------------
  # Container Identification
  # vmid = null # VMID for the container (0 = auto-assign next available)

  # Architecture & OS
  # arch   = "amd64" # Container architecture: amd64, arm64, armhf, i386
  # ostype = null    # OS type for LXC setup (alpine, archlinux, centos, debian, ubuntu, unmanaged)

  # Resource Allocation (CPU & Memory)
  # cores    = null # Number of CPU cores (null = use all available)
  # cpulimit = 0    # CPU usage limit (0 = unlimited)
  # cpuunits = 1024 # CPU weight for scheduling
  # memory   = 512  # RAM in MB
  # swap     = 512  # Swap memory in MB

  # Storage Configuration (rootfs is required by provider, automatically configured by module)
  # rootfs_storage = "local-lvm" # Storage pool for root filesystem
  # rootfs_size    = "8G"        # Root filesystem size (format: <number>T|G|M|K)
  # bwlimit        = null        # I/O bandwidth limit in KiB/s

  # Network Configuration
  # network_bridge   = "vmbr0" # Bridge to attach (e.g., "vmbr0")
  # network_ip       = "dhcp"  # IPv4: static CIDR, "dhcp", or "manual"
  # network_gateway  = null    # IPv4 gateway address
  # network_ip6      = null    # IPv6: static CIDR, "auto", "dhcp", or "manual"
  # network_gw6      = null    # IPv6 gateway address
  # network_hwaddr   = null    # MAC address (I/G bit not set)
  # network_mtu      = null    # MTU size
  # network_rate     = null    # Rate limit in Mbps
  # network_vlan     = null    # VLAN tag
  # network_firewall = false   # Enable Proxmox firewall on interface

  # DNS Configuration
  # nameserver   = null # DNS server IP (defaults to Proxmox host if not set)
  # searchdomain = null # DNS search domain (defaults to Proxmox host if not set)

  # Container Behavior
  # unprivileged = true  # Run as unprivileged user (recommended for security)
  # onboot       = false # Start on boot
  # start        = true  # Start after creation
  # template     = false # Mark as template for cloning
  # unique       = false # Assign unique random MAC address

  # Console Configuration
  # cmode   = "tty" # Console mode: "tty", "console", or "shell"
  # console = true  # Attach console device
  # tty     = 2     # Number of TTYs (0-6)

  # Startup & Shutdown Behavior
  # startup = null # Format: "order=<number>,up=<seconds>,down=<seconds>"

  # Advanced Features (for Docker, nested virtualization, etc.)
  # features = {
  #   nesting = false # Enable nested virtualization
  #   fuse    = false # Enable FUSE mounts
  #   keyctl  = false # Enable keyctl() system call
  #   mount   = null  # Allowed filesystem types separated by semicolons (e.g., "nfs;cifs")
  # }

  # Authentication & Access
  # ssh_public_keys = null # Multi-line string of SSH public keys (use heredoc syntax)
  # Example:
  # ssh_public_keys = <<-EOT
  #   ssh-rsa AAAAB3NzaC1yc2E... user@example.com
  #   ssh-ed25519 AAAAC3NzaC1lZDI1... user@example.com
  # EOT

  # password = null # Root password (use SSH keys for production)

  # Proxmox Resource Management
  # pool       = null  # Resource pool name
  # protection = false # Prevent removal/update
  # force      = false # Allow overwriting pre-existing containers
  # restore    = false # Mark as restore task
  # hookscript = null  # Volume identifier to executable script (e.g., "local:snippets/hook.sh")

  # High Availability (requires Proxmox HA setup)
  # hastate = null # HA state: "started", "stopped", "enabled", "disabled", or "ignored"
  # hagroup = null # HA group identifier (requires hastate to be set)

  # Metadata & Tags
  # description = "" # Container description in Proxmox UI
  # tags        = {} # Additional tags (merged with mandatory module tags: managed-by, module)
}

# =============================================================================
# REQUIRED ARGUMENTS
# =============================================================================
variable "hostname" {
  description = "Hostname for the LXC container"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.hostname))
    error_message = "Hostname must be 1-63 characters, start and end with alphanumeric, contain only lowercase letters, numbers, and hyphens"
  }
}

variable "target_node" {
  description = "Name of the Proxmox cluster node where the LXC container will be created"
  type        = string

  validation {
    condition     = length(var.target_node) > 0
    error_message = "Target node name cannot be empty"
  }
}

variable "ostemplate" {
  description = "Volume identifier that points to the OS template or backup file (e.g., 'local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst')"
  type        = string

  validation {
    condition     = can(regex("^[^:]+:vztmpl/.+\\.(tar\\.(gz|xz|zst)|tar)$", var.ostemplate))
    error_message = "OS template must be in format 'storage:vztmpl/filename.tar.{gz|xz|zst}'"
  }
}

# =============================================================================
# RESOURCE ALLOCATION
# =============================================================================
variable "vmid" {
  description = "VMID for the LXC container. If set to 0 or null, the next available VMID is used"
  type        = number
  default     = null

  validation {
    condition     = var.vmid == null || try(var.vmid >= 100 && var.vmid <= 999999999, false)
    error_message = "VMID must be between 100 and 999999999, or null for auto-assignment"
  }
}

variable "arch" {
  description = "Container OS architecture type"
  type        = string
  default     = "amd64"

  validation {
    condition     = contains(["amd64", "arm64", "armhf", "i386"], var.arch)
    error_message = "Architecture must be one of: amd64, arm64, armhf, i386"
  }
}

variable "cores" {
  description = "Number of CPU cores assigned to the container. Container can use all available cores by default"
  type        = number
  default     = null

  validation {
    condition     = var.cores == null || try(var.cores >= 1 && var.cores <= 8192, false)
    error_message = "Cores must be between 1 and 8192, or null to allow all cores"
  }
}

variable "cpulimit" {
  description = "Limit CPU usage by this number. Default 0 means no limit. Set to 2 to limit container to 2 cores worth of CPU time"
  type        = number
  default     = 0

  validation {
    condition     = var.cpulimit >= 0 && var.cpulimit <= 8192
    error_message = "CPU limit must be between 0 (unlimited) and 8192"
  }
}

variable "cpuunits" {
  description = "CPU weight that the container possesses. Used by kernel scheduler to distribute CPU time. Default is 1024"
  type        = number
  default     = 1024

  validation {
    condition     = var.cpuunits >= 0 && var.cpuunits <= 500000
    error_message = "CPU units must be between 0 and 500000"
  }
}

variable "memory" {
  description = "Amount of RAM to assign to the container in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.memory >= 16 && var.memory <= 268435456
    error_message = "Memory must be between 16MB and 256TB"
  }
}

variable "swap" {
  description = "Amount of swap memory available to the container in MB. Default is 512"
  type        = number
  default     = 512

  validation {
    condition     = var.swap >= 0 && var.swap <= 268435456
    error_message = "Swap must be between 0MB and 256TB"
  }
}

# =============================================================================
# STORAGE CONFIGURATION
# =============================================================================
variable "rootfs_storage" {
  description = "Storage identifier for the root filesystem (e.g., 'local-lvm', 'local-zfs')"
  type        = string
  default     = "local-lvm"

  validation {
    condition     = length(var.rootfs_storage) > 0
    error_message = "Root filesystem storage cannot be empty"
  }
}

variable "rootfs_size" {
  description = "Size of the root filesystem. Must end in T, G, M, or K (e.g., '8G', '1024M')"
  type        = string
  default     = "8G"

  validation {
    condition     = can(regex("^[1-9][0-9]*[TGMK]$", var.rootfs_size))
    error_message = "Rootfs size must be a positive number ending with T, G, M, or K (e.g., '8G', '1024M')"
  }
}

variable "bwlimit" {
  description = "Override I/O bandwidth limit in KiB/s for disk operations"
  type        = number
  default     = null

  validation {
    condition     = var.bwlimit == null || try(var.bwlimit >= 0, false)
    error_message = "Bandwidth limit must be 0 or greater KiB/s"
  }
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================
variable "network_bridge" {
  description = "Bridge to attach the network interface to (e.g., 'vmbr0')"
  type        = string
  default     = "vmbr0"

  validation {
    condition     = can(regex("^vmbr[0-9]+$", var.network_bridge))
    error_message = "Network bridge must be in format 'vmbr<number>' (e.g., 'vmbr0')"
  }
}

variable "network_ip" {
  description = "IPv4 address of the network interface. Can be static IPv4 (CIDR notation), 'dhcp', or 'manual'"
  type        = string
  default     = "dhcp"

  validation {
    condition = (
      var.network_ip == "dhcp" ||
      var.network_ip == "manual" ||
      can(cidrhost(var.network_ip, 0))
    )
    error_message = "Network IP must be valid CIDR notation (e.g., '192.168.1.100/24'), 'dhcp', or 'manual'"
  }
}

variable "network_gateway" {
  description = "IPv4 address belonging to the network interface's default gateway"
  type        = string
  default     = null

  validation {
    condition     = var.network_gateway == null || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.network_gateway))
    error_message = "Network gateway must be a valid IPv4 address"
  }
}

variable "network_ip6" {
  description = "IPv6 address of the network interface. Can be static IPv6 (CIDR notation), 'auto', 'dhcp', or 'manual'"
  type        = string
  default     = null

  validation {
    condition = (
      var.network_ip6 == null ||
      var.network_ip6 == "auto" ||
      var.network_ip6 == "dhcp" ||
      var.network_ip6 == "manual" ||
      can(regex("^([0-9a-fA-F:]+)/[0-9]+$", var.network_ip6))
    )
    error_message = "Network IPv6 must be valid CIDR notation, 'auto', 'dhcp', or 'manual'"
  }
}

variable "network_gw6" {
  description = "IPv6 address of the network interface's default gateway"
  type        = string
  default     = null

  validation {
    condition     = var.network_gw6 == null || can(regex("^[0-9a-fA-F:]+$", var.network_gw6))
    error_message = "Network IPv6 gateway must be a valid IPv6 address"
  }
}

variable "network_hwaddr" {
  description = "Common MAC address with the I/G (Individual/Group) bit not set. Automatically determined if not set"
  type        = string
  default     = null

  validation {
    condition     = var.network_hwaddr == null || can(regex("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$", var.network_hwaddr))
    error_message = "MAC address must be in format XX:XX:XX:XX:XX:XX or XX-XX-XX-XX-XX-XX"
  }
}

variable "network_mtu" {
  description = "MTU (Maximum Transmission Unit) for the network interface"
  type        = number
  default     = null

  validation {
    condition     = var.network_mtu == null || try(var.network_mtu >= 576 && var.network_mtu <= 65536, false)
    error_message = "MTU must be between 576 and 65536 bytes"
  }
}

variable "network_rate" {
  description = "Rate limiting on the network interface in Mbps (Megabits per second)"
  type        = number
  default     = null

  validation {
    condition     = var.network_rate == null || try(var.network_rate > 0 && var.network_rate <= 10000000, false)
    error_message = "Network rate must be between 0 and 10000000 Mbps"
  }
}

variable "network_vlan" {
  description = "VLAN tag of the network interface. Automatically determined if not set"
  type        = number
  default     = null

  validation {
    condition     = var.network_vlan == null || try(var.network_vlan >= 1 && var.network_vlan <= 4094, false)
    error_message = "VLAN tag must be between 1 and 4094"
  }
}

variable "network_firewall" {
  description = "Enable the Proxmox firewall on the network interface"
  type        = bool
  default     = false
}

# =============================================================================
# DNS CONFIGURATION
# =============================================================================
variable "nameserver" {
  description = "DNS server IP address used by the container. Uses Proxmox host values if not specified"
  type        = string
  default     = null

  validation {
    condition     = var.nameserver == null || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.nameserver))
    error_message = "Nameserver must be a valid IPv4 address"
  }
}

variable "searchdomain" {
  description = "DNS search domain for the container. Uses Proxmox host values if not specified"
  type        = string
  default     = null

  validation {
    condition     = var.searchdomain == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-\\.]*[a-zA-Z0-9]$", var.searchdomain))
    error_message = "Search domain must be a valid DNS domain name"
  }
}

# =============================================================================
# CONTAINER BEHAVIOR
# =============================================================================
variable "unprivileged" {
  description = "Makes the container run as an unprivileged user. Recommended for security. Default is false"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Specifies whether the container will start on boot. Default is false"
  type        = bool
  default     = false
}

variable "start" {
  description = "Specifies whether the container is started after creation. Default is false"
  type        = bool
  default     = true
}

variable "cmode" {
  description = "Console mode. 'tty' tries to open tty devices, 'console' attaches to /dev/console, 'shell' invokes a shell. Default is 'tty'"
  type        = string
  default     = "tty"

  validation {
    condition     = contains(["tty", "console", "shell"], var.cmode)
    error_message = "Console mode must be one of: tty, console, shell"
  }
}

variable "console" {
  description = "Attach a console device to the container. Default is true"
  type        = bool
  default     = true
}

variable "tty" {
  description = "Number of TTY (teletypewriter) devices available to the container. Default is 2"
  type        = number
  default     = 2

  validation {
    condition     = var.tty >= 0 && var.tty <= 6
    error_message = "TTY count must be between 0 and 6"
  }
}

variable "template" {
  description = "Enable to mark this container as a template for cloning. Default is false"
  type        = bool
  default     = false
}

variable "unique" {
  description = "Assign a unique random ethernet address to the container. Default is false"
  type        = bool
  default     = false
}

variable "startup" {
  description = "Startup and shutdown behavior (e.g., 'order=1,up=30,down=60'). Defines startup order and delays"
  type        = string
  default     = null

  validation {
    condition = (
      var.startup == null ||
      can(regex("^(order=[0-9]+)?(,up=[0-9]+)?(,down=[0-9]+)?$", var.startup))
    )
    error_message = "Startup must be in format 'order=N,up=N,down=N' where N is a number"
  }
}

# =============================================================================
# ADVANCED FEATURES
# =============================================================================
variable "features" {
  description = "Object for allowing the container to access advanced features (FUSE mounts, nesting, keyctl, allowed mount types)"
  type = object({
    fuse    = optional(bool, false)
    keyctl  = optional(bool, false)
    mount   = optional(string, null)
    nesting = optional(bool, false)
  })
  default = null

  validation {
    condition = (
      var.features == null ||
      try(var.features.mount == null, true) ||
      can(regex("^[a-z0-9]+(;[a-z0-9]+)*$", try(var.features.mount, "")))
    )
    error_message = "Features mount must be filesystem types separated by semicolons (e.g., 'nfs;cifs;ext4')"
  }
}

# =============================================================================
# AUTHENTICATION & ACCESS
# =============================================================================
variable "ssh_public_keys" {
  description = "Multi-line string of SSH public keys that will be added to the container's authorized_keys"
  type        = string
  default     = null

  validation {
    condition = (
      var.ssh_public_keys == null ||
      can(regex("ssh-(rsa|dss|ed25519|ecdsa)", var.ssh_public_keys))
    )
    error_message = "SSH public keys must contain valid SSH key format (ssh-rsa, ssh-dss, ssh-ed25519, or ssh-ecdsa)"
  }
}

variable "password" {
  description = "Root password inside the container. Use SSH keys instead for better security"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.password == null || try(length(var.password) >= 5, false)
    error_message = "Password must be at least 5 characters long"
  }
}

# =============================================================================
# OPERATING SYSTEM
# =============================================================================
variable "ostype" {
  description = "OS type used by LXC to set up and configure the container. Automatically determined if not set"
  type        = string
  default     = null

  validation {
    condition = (
      var.ostype == null ||
      try(contains([
        "alpine", "archlinux", "centos", "debian", "devuan", "fedora",
        "gentoo", "opensuse", "ubuntu", "unmanaged"
      ], var.ostype), false)
    )
    error_message = "OS type must be one of: alpine, archlinux, centos, debian, devuan, fedora, gentoo, opensuse, ubuntu, unmanaged"
  }
}

# =============================================================================
# PROXMOX MANAGEMENT
# =============================================================================
variable "pool" {
  description = "Name of the Proxmox resource pool to add this container to"
  type        = string
  default     = null

  validation {
    condition     = var.pool == null || can(regex("^[a-zA-Z0-9_-]+$", var.pool))
    error_message = "Pool name must contain only alphanumeric characters, underscores, and hyphens"
  }
}

variable "protection" {
  description = "Enable protection flag to prevent the container and its disk from being removed/updated. Default is false"
  type        = bool
  default     = false
}

variable "force" {
  description = "Allow overwriting of pre-existing containers. Default is false"
  type        = bool
  default     = false
}

variable "restore" {
  description = "Mark the container creation/update as a restore task. Default is false"
  type        = bool
  default     = false
}

variable "hookscript" {
  description = "Volume identifier to a script that will be executed during various steps in the container's lifetime"
  type        = string
  default     = null

  validation {
    condition     = var.hookscript == null || can(regex("^[^:]+:.+$", var.hookscript))
    error_message = "Hookscript must be a volume identifier in format 'storage:path/to/script'"
  }
}

# =============================================================================
# HIGH AVAILABILITY
# =============================================================================
variable "hastate" {
  description = "Requested HA state for the resource: started, stopped, enabled, disabled, or ignored"
  type        = string
  default     = null

  validation {
    condition = (
      var.hastate == null ||
      try(contains(["started", "stopped", "enabled", "disabled", "ignored"], var.hastate), false)
    )
    error_message = "HA state must be one of: started, stopped, enabled, disabled, ignored"
  }
}

variable "hagroup" {
  description = "HA group identifier the resource belongs to. Requires hastate to be set"
  type        = string
  default     = null

  validation {
    condition     = var.hagroup == null || can(regex("^[a-zA-Z0-9_-]+$", var.hagroup))
    error_message = "HA group must contain only alphanumeric characters, underscores, and hyphens"
  }
}

# =============================================================================
# METADATA & TAGGING
# =============================================================================
variable "description" {
  description = "Container description seen in the Proxmox web interface"
  type        = string
  default     = ""

  validation {
    condition     = length(var.description) <= 8192
    error_message = "Description must not exceed 8192 characters"
  }
}

variable "tags" {
  description = "Additional tags to merge with mandatory module tags (managed-by, module). Tag values will appear in Proxmox UI as tags and full key=value pairs in description."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.tags : can(regex("^[a-zA-Z0-9._-]+$", v))
    ])
    error_message = <<-EOT
      Tag values must contain only characters allowed by Proxmox: a-z, A-Z, 0-9, hyphen (-), period (.), and underscore (_).
      Invalid characters include: spaces, equals (=), special symbols, etc.

      Examples of valid tag values:
        - "production" ✓
        - "web-server" ✓
        - "app_v1.0" ✓

      Examples of invalid tag values:
        - "web server" ✗ (contains space)
        - "app=web" ✗ (contains equals sign)
        - "prod/web" ✗ (contains slash)
    EOT
  }
}

# =============================================================================
# ADDITIONAL NETWORKS
# =============================================================================
variable "additional_networks" {
  description = "Additional network interfaces beyond eth0. Each network must have a unique name (eth1, eth2, etc.)"
  type = list(object({
    name     = string           # Interface name (e.g., "eth1", "eth2")
    bridge   = string           # Bridge to attach to (e.g., "vmbr1")
    ip       = optional(string) # IPv4 address in CIDR or "dhcp" or "manual"
    gw       = optional(string) # IPv4 gateway
    ip6      = optional(string) # IPv6 address in CIDR or "auto", "dhcp", "manual"
    gw6      = optional(string) # IPv6 gateway
    hwaddr   = optional(string) # MAC address
    mtu      = optional(number) # MTU (576-65536)
    rate     = optional(number) # Rate limit in Mbps
    tag      = optional(number) # VLAN tag
    firewall = optional(bool)   # Enable firewall
  }))
  default = []

  validation {
    condition = alltrue([
      for net in var.additional_networks : can(regex("^eth[1-9][0-9]*$", net.name))
    ])
    error_message = "Additional network names must be eth1, eth2, eth3, etc. (eth0 is the primary network)"
  }

  validation {
    condition     = length(var.additional_networks) == length(distinct([for net in var.additional_networks : net.name]))
    error_message = "Each additional network must have a unique name"
  }

  validation {
    condition = alltrue([
      for net in var.additional_networks :
      net.ip == null || net.ip == "dhcp" || net.ip == "manual" || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", net.ip))
    ])
    error_message = "Additional network IP must be valid CIDR notation, 'dhcp', 'manual', or null"
  }

  validation {
    condition = alltrue([
      for net in var.additional_networks :
      net.mtu == null || try(net.mtu >= 576 && net.mtu <= 65536, false)
    ])
    error_message = "Additional network MTU must be between 576 and 65536 bytes"
  }
}

# =============================================================================
# ADDITIONAL STORAGE (MOUNTPOINTS)
# =============================================================================
variable "mountpoints" {
  description = "Additional storage volumes to mount in the container. Supports storage-backed, bind mounts, and device mounts"
  type = list(object({
    slot      = string         # Mount point identifier (e.g., "0", "1", "2")
    storage   = string         # Storage name, directory path, or device path
    mp        = string         # Mount point path inside container (e.g., "/mnt/data")
    size      = string         # Size with unit (e.g., "10G", "500M", "1T")
    acl       = optional(bool) # Enable ACL support (default: false)
    backup    = optional(bool) # Include in backups (default: false)
    quota     = optional(bool) # Enable user quotas (default: false)
    replicate = optional(bool) # Include in storage replica job (default: false)
    shared    = optional(bool) # Mark as available on all nodes (default: false)
  }))
  default = []

  validation {
    condition = alltrue([
      for mp in var.mountpoints : can(regex("^[0-9]+$", mp.slot))
    ])
    error_message = "Mountpoint slot must be a numeric string (e.g., '0', '1', '2')"
  }

  validation {
    condition     = length(var.mountpoints) == length(distinct([for mp in var.mountpoints : mp.slot]))
    error_message = "Each mountpoint must have a unique slot number"
  }

  validation {
    condition = alltrue([
      for mp in var.mountpoints : can(regex("^/[a-zA-Z0-9/_-]+$", mp.mp))
    ])
    error_message = "Mountpoint path must be an absolute path starting with / and contain only alphanumeric characters, /, _, and -"
  }

  validation {
    condition = alltrue([
      for mp in var.mountpoints : can(regex("^[0-9]+(\\.[0-9]+)?[TGMK]$", mp.size))
    ])
    error_message = "Mountpoint size must end in T, G, M, or K (e.g., '10G', '500M', '1.5T')"
  }

  validation {
    condition = alltrue([
      for mp in var.mountpoints : mp.mp != "/"
    ])
    error_message = "Mountpoint path cannot be root (/). Use rootfs configuration instead"
  }
}

# =============================================================================
# PROVISIONER CONFIGURATION
# =============================================================================
variable "provisioner_enabled" {
  description = "Enable remote-exec provisioner to run commands after container initialization"
  type        = bool
  default     = false
}

variable "provisioner_commands" {
  description = "List of commands to execute inside the container after initialization. Requires provisioner_enabled = true. Mutually exclusive with provisioner_script_path"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.provisioner_commands) == 0 || alltrue([for cmd in var.provisioner_commands : length(cmd) > 0])
    error_message = "All commands must be non-empty strings"
  }
}

variable "provisioner_script_path" {
  description = "Path to shell script file to execute inside the container after initialization. Mutually exclusive with provisioner_commands. Script will be read and executed inline"
  type        = string
  default     = null
}

variable "provisioner_ssh_user" {
  description = "SSH user for remote-exec provisioner. Defaults to 'root' for LXC containers"
  type        = string
  default     = "root"

  validation {
    condition     = length(var.provisioner_ssh_user) > 0
    error_message = "SSH user cannot be empty"
  }
}

variable "provisioner_ssh_host" {
  description = "SSH host/IP for remote-exec provisioner. If not provided, will attempt to extract from network_ip"
  type        = string
  default     = null
}

variable "provisioner_ssh_private_key" {
  description = "SSH private key for remote-exec provisioner. Can be file path or key content. Required when provisioner_enabled = true"
  type        = string
  default     = null
  sensitive   = true
}

variable "provisioner_timeout" {
  description = "Timeout for SSH connection in the provisioner (e.g., '5m', '30s')"
  type        = string
  default     = "5m"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.provisioner_timeout))
    error_message = "Timeout must be in format '30s', '5m', or '1h'"
  }
}

variable "provisioner_scripts_dir" {
  description = <<-EOT
    Directory containing shell scripts (*.sh) to execute sequentially.
    Scripts are executed in lexicographic order (use numeric prefixes like 01-, 02- to control order).
    Mutually exclusive with provisioner_commands and provisioner_script_path.

    Example structure:
      scripts/
        01-update-system.sh
        02-install-docker.sh
        03-configure-app.sh
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.provisioner_scripts_dir == null || can(regex("^[^\\s]+$", var.provisioner_scripts_dir))
    error_message = "Scripts directory path cannot contain whitespace"
  }
}

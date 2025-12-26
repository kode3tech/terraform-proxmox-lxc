# =============================================================================
# ADVANCED LXC CONTAINER EXAMPLE
# =============================================================================
# This example demonstrates a comprehensive configuration using most available
# features of the module. It serves as a reference for advanced use cases and
# validation of all module capabilities.
#
# Reference: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc
# =============================================================================

module "lxc_advanced" {
  source = "../.."

  # ---------------------------------------------------------------------------
  # REQUIRED ARGUMENTS
  # ---------------------------------------------------------------------------

  # hostname: Container hostname (FQDN or simple hostname)
  # - Must be 1-63 characters long
  # - Only lowercase letters, numbers, and hyphens allowed
  # - Must start and end with alphanumeric character
  # - This will be the hostname inside the container
  hostname = var.hostname

  # target_node: Proxmox cluster node name where container will be created
  # - Must match exactly the node name in Proxmox
  # - Required even in single-node environments
  # - Example: "pve", "pve01", "proxmox-node-1"
  # ⚠️  IMMUTABLE: Cannot be changed after creation (requires destroy/recreate)
  target_node = var.target_node

  # ostemplate: Full path to the operating system template
  # - Format: "storage:vztmpl/template-name.tar.{gz|xz|zst}"
  # - Storage must have the template available
  # - Common templates: ubuntu, debian, alpine, centos, rocky
  # - Check available templates: pveam available
  # ⚠️  IMMUTABLE: Cannot be changed after creation (requires destroy/recreate)
  ostemplate = var.ostemplate

  # ---------------------------------------------------------------------------
  # RESOURCE ALLOCATION
  # ---------------------------------------------------------------------------

  # vmid: Unique container ID in Proxmox (100-999999999)
  # - If null or omitted, Proxmox auto-assigns next available ID
  # - Useful for maintaining consistent IDs across environments
  # - Avoid IDs below 100 (reserved for system VMs)
  vmid = var.vmid

  # arch: Container CPU architecture
  # - Options: "amd64" (default), "arm64", "armhf", "i386"
  # - Must match the architecture of the template used
  # - amd64: Intel/AMD 64-bit (most common)
  # ⚠️  IMMUTABLE: Cannot be changed after creation (requires destroy/recreate)
  arch = "amd64"

  # cores: Number of CPU cores allocated to container
  # - Null or omitted = container can use all available cores
  # - Value 1-8192 limits how many cores container can use
  # - Does not guarantee dedicated cores, only limits maximum
  cores = 8

  # cpulimit: CPU usage limit in number of cores
  # - 0 = no limit (default)
  # - 1 = maximum of 1 core of CPU time
  # - 2 = maximum of 2 cores of CPU time
  # - Useful to prevent container from monopolizing all resources
  cpulimit = 4

  # cpuunits: CPU weight for kernel scheduler
  # - Default: 1024 (normal weight)
  # - Higher values = higher CPU priority
  # - Lower values = lower CPU priority
  # - Useful when multiple containers compete for CPU
  # - Example: critical container = 2048, backup container = 512
  cpuunits = 4096

  # memory: Amount of RAM allocated to container in MB
  # - Minimum: 16MB, Maximum: 268435456MB (256TB)
  # - Default: 512MB
  # - This is the main container RAM
  # - Adjust based on expected workload
  memory = 4096

  # swap: Amount of swap memory in MB
  # - Default: 512MB
  # - 0 = no swap (not recommended)
  # - Swap is used when RAM is full
  # - Generally configure as 50% of RAM or equal to RAM
  swap = 2048

  # ---------------------------------------------------------------------------
  # STORAGE CONFIGURATION
  # ---------------------------------------------------------------------------
  # rootfs_storage: Proxmox storage pool for root filesystem
  # - Must be a valid storage configured in Proxmox
  # - Examples: "local-lvm", "local-zfs", "nas", "ceph"
  # - Check available storages: pvesm status
  # - Avoid "local" (dir storage) for production, prefer LVM/ZFS
  # ⚠️  IMMUTABLE: Cannot be changed after creation (requires destroy/recreate)
  rootfs_storage = "nas"

  # rootfs_size: Root filesystem size
  # - Format: "<number>T|G|M|K"
  # - Examples: "8G", "500M", "1T", "10240K"
  # - Must have size indicator letter (T, G, M or K)
  # - Default: 8G
  # ⚠️  PARTIALLY IMMUTABLE: Can only be INCREASED, never reduced
  rootfs_size = "20G"

  # bwlimit: I/O bandwidth limit in KiB/s
  # - Null = no limit (default - RECOMMENDED)
  # - Useful to limit impact of I/O intensive containers
  # - Example: 10240 = 10 MB/s
  # - Applies only during migration and clone operations
  # ⚠️  CREATION-ONLY: Cannot be modified after container exists (ignored by lifecycle)
  # ⚠️  RECOMMENDATION: Leave as null unless you need migration bandwidth control
  bwlimit = null

  # ---------------------------------------------------------------------------
  # NETWORK CONFIGURATION
  # ---------------------------------------------------------------------------
  # network_bridge: Proxmox virtual network bridge
  # - Default: "vmbr0"
  # - Must exist on Proxmox host
  # - Check available bridges: ip link show
  # - Examples: "vmbr0" (default), "vmbr1" (isolated network)
  network_bridge = "vmbr0"

  # network_ip: IP address and network mask (CIDR)
  # - IPv4 format: "192.168.1.100/24"
  # - "dhcp" = obtain IP automatically via DHCP
  # - "manual" = no automatic IP configuration
  # - Null = dhcp
  # - Use static IP for servers and "dhcp" for development
  network_ip = "192.168.1.201/24"

  # network_gateway: IPv4 default gateway
  # - Router/gateway IP address
  # - Required when network_ip is static
  # - Null = no gateway configured
  # - Must be in same network as network_ip
  network_gateway = "192.168.1.1"

  # network_ip6: IPv6 address and mask (CIDR)
  # - Format: "2001:db8::1/64"
  # - "auto" = autoconfiguration via SLAAC
  # - "dhcp" = obtain via DHCPv6
  # - "manual" = no automatic configuration
  # - Null = no IPv6
  network_ip6 = "auto"

  # network_gw6: IPv6 default gateway
  # - IPv6 gateway address
  # - Null = no IPv6 gateway
  # - Only needed when using static IPv6
  network_gw6 = null

  # network_hwaddr: Custom MAC address
  # - Format: "XX:XX:XX:XX:XX:XX"
  # - Null = Proxmox auto-generates
  # - Useful to maintain consistent MAC or licensing requirements
  # - Must not have I/G (Individual/Group) bit set
  network_hwaddr = null

  # network_mtu: Maximum Transmission Unit (maximum packet size)
  # - Default: 1500 (standard Ethernet)
  # - Jumbo frames: 9000
  # - Null = use bridge MTU
  # - Adjust if your network supports jumbo frames
  network_mtu = 1500

  # network_rate: Network rate limit in Mbps
  # - Null = no limit (default)
  # - Useful to limit bandwidth of specific containers
  # - Example: 100 = 100 Mbps maximum
  # - Does not affect traffic between containers
  network_rate = 100

  # network_vlan: VLAN tag for network segmentation
  # - Null = no VLAN (default)
  # - Value: 1-4094
  # - Bridge must be configured for VLANs (VLAN aware)
  # - Useful for network isolation and segmentation
  network_vlan = null

  # network_firewall: Enable Proxmox firewall on interface
  # - true = enable firewall (rules defined in Proxmox)
  # - false = no firewall (default)
  # - Requires firewall rules configured in Proxmox
  # - Useful for additional security on shared networks
  network_firewall = false

  # ---------------------------------------------------------------------------
  # DNS CONFIGURATION
  # ---------------------------------------------------------------------------
  # nameserver: DNS server IP address
  # - Null = uses Proxmox host DNS (default)
  # - Can be multiple IPs separated by space
  # - Examples: "8.8.8.8", "1.1.1.1 8.8.8.8"
  # - Configured in /etc/resolv.conf inside container
  nameserver = "8.8.4.4"

  # searchdomain: DNS search domain
  # - Null = uses Proxmox host domain (default)
  # - Example: "example.com" allows resolving "host" as "host.example.com"
  # - Useful in corporate networks with internal domain
  # - Configured in /etc/resolv.conf inside container
  searchdomain = "kode3.intra"

  # ---------------------------------------------------------------------------
  # CONTAINER BEHAVIOR
  # ---------------------------------------------------------------------------
  # unprivileged: Run container as unprivileged user
  # - true = unprivileged container (RECOMMENDED - more secure)
  # - false = privileged container (root in container = root on host)
  # - Unprivileged containers have mapped UIDs (100000+)
  # - Use false only if absolutely necessary for compatibility
  # ⚠️  IMMUTABLE: Cannot be changed after creation (requires destroy/recreate)
  unprivileged = true

  # onboot: Start container automatically when host boots
  # - true = start on boot
  # - false = don't start automatically (default)
  # - Useful for services that must always be available
  # - Respects order defined in "startup"
  onboot = false

  # start: Start container immediately after creation
  # - true = starts after terraform apply
  # - false = create but don't start
  # - Useful when you want to provision but not run immediately
  start = true

  # template: Mark container as template
  # - true = container becomes template (read-only, used for cloning)
  # - false = normal container (default)
  # - Templates cannot be started
  # - Use to create "golden images" for cloning
  template = false

  # unique: Generate random unique MAC address
  # - true = generate new random MAC
  # - false = keep existing MAC or use default (default)
  # - Useful when cloning containers to avoid MAC conflicts
  unique = false

  # ---------------------------------------------------------------------------
  # CONSOLE CONFIGURATION
  # ---------------------------------------------------------------------------
  # cmode: Container console mode
  # - "tty" = console via terminal (default)
  # - "console" = console via /dev/console
  # - "shell" = direct interactive shell
  # - Affects how you connect to container console
  cmode = "console"

  # console: Enable console device
  # - true = console available (default)
  # - false = no console
  # - Required to access console via Proxmox UI
  console = true

  # tty: Number of TTY terminals available
  # - Default: 2
  # - Value: 0-6
  # - TTYs appear as /dev/tty1, /dev/tty2, etc.
  # - Useful if you need multiple simultaneous console sessions
  tty = 2

  # ---------------------------------------------------------------------------
  # STARTUP & SHUTDOWN
  # ---------------------------------------------------------------------------
  # startup: Boot order and timing configuration
  # - Format: "order=<number>,up=<seconds>,down=<seconds>"
  # - order: boot order (lower = starts first)
  # - up: wait in seconds after start before starting next
  # - down: wait in seconds after shutdown before shutting down next
  # - Null = no order control
  # - Example: "order=1,up=60" = starts first, waits 60s
  startup = "order=2,up=30,down=60"

  # ---------------------------------------------------------------------------
  # ADVANCED FEATURES (Docker/Nested Virtualization Support)
  # ---------------------------------------------------------------------------

  # NOTE: Only 'nesting' feature is enabled by default as other features
  # (fuse, keyctl, mount) require root@pam authentication in Proxmox.
  # If you need these features, ensure you're authenticated as root@pam.

  features = {
    # nesting: Enable nested virtualization
    # - true = allows running VMs/containers inside container
    # - false = no nesting (default)
    # - REQUIRED to run Docker/Podman/LXD inside container
    # - Slightly reduces security isolation
    nesting = true

    # fuse: Enable FUSE (Filesystem in Userspace) support
    # - true = allows mounting FUSE filesystems
    # - false = no FUSE (default)
    # - Required for some applications (sshfs, AppImage, etc.)
    # - Useful for development and modern tools
    # - REQUIRES: root@pam authentication
    # fuse = true

    # keyctl: Enable keyctl() syscall
    # - true = allows kernel keyring management
    # - false = no keyctl (default)
    # - Required for some applications (systemd, security features)
    # - Useful for containers with full systemd
    # - REQUIRES: root@pam authentication
    # keyctl = true

    # mount: Allowed filesystem types for mounting
    # - Null = default types only
    # - Semicolon-separated string: "nfs;cifs;ext4"
    # - Allows mounting additional filesystems inside container
    # - Useful for network shares (NFS/CIFS)
    # - Example: "nfs;cifs" for Windows/Linux shares
    # - REQUIRES: root@pam authentication
    # mount = "nfs;cifs;ext4"
  }

  # ---------------------------------------------------------------------------
  # AUTHENTICATION & ACCESS
  # ---------------------------------------------------------------------------
  # ssh_public_keys: SSH public keys for container access
  # - Format: multi-line string (heredoc)
  # - One key per line
  # - Installed for root user
  # - RECOMMENDED: always use SSH keys instead of password
  # - Supports RSA, Ed25519, ECDSA
  # COMMENTED: Uncomment and provide your real SSH public key
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")

  # password: Container root user password
  # - String with password in plain text
  # - NOT RECOMMENDED for production
  # - Use only for development/testing
  # - ALWAYS prefer ssh_public_keys for production
  # - Terraform stores in state file (security risk)
  password = "YourSecurePassword123!"

  # ---------------------------------------------------------------------------
  # OPERATING SYSTEM
  # ---------------------------------------------------------------------------
  # ostype: Container operating system type
  # - Null = automatic detection based on template
  # - Options: "alpine", "archlinux", "centos", "debian", "ubuntu", "unmanaged"
  # - Affects OS-specific configurations (init, network, etc.)
  # - Use "unmanaged" for unlisted or custom OSes
  ostype = null

  # ---------------------------------------------------------------------------
  # PROXMOX RESOURCE MANAGEMENT
  # ---------------------------------------------------------------------------
  # pool: Proxmox resource pool name
  # - Null = no pool (default)
  # - Pools group resources for management and permissions
  # - Pool must exist in Proxmox before use
  # - Useful for multi-tenant organization or by project
  # - Create pools in: Datacenter → Permissions → Pools
  pool = null

  # protection: Protection against accidental removal
  # - true = prevents destruction via UI/API
  # - false = no protection (default)
  # - You must disable protection before destroying
  # - RECOMMENDED for critical production containers
  protection = false

  # force: Force creation overwriting existing container
  # - true = overwrites if already exists
  # - false = fails if already exists (default - SAFE)
  # - CAUTION: may destroy existing data
  # - Use only in development/testing
  force = false

  # restore: Mark operation as backup restore
  # - true = restore operation
  # - false = normal creation (default)
  # - Use when restoring from backup
  # - Changes behavior of some validations
  # ⚠️  IMMUTABLE: Cannot be changed after creation (only set during creation)
  restore = false

  # hookscript: Script executed on lifecycle events
  # - Null = no hookscript (default)
  # - Format: "storage:snippets/script.sh"
  # - Script must be in snippets-type storage
  # - Executed on: pre-start, post-start, pre-stop, post-stop
  # - Useful for custom automation (backup, notifications, etc.)
  hookscript = null

  # ---------------------------------------------------------------------------
  # HIGH AVAILABILITY (requires Proxmox HA setup)
  # ---------------------------------------------------------------------------
  # hastate: Desired High Availability state
  # - Null = no HA (default)
  # - "started" = always started (automatic HA restart)
  # - "stopped" = always stopped
  # - "enabled" = managed by HA but can be stopped
  # - "disabled" = not managed by HA
  # - "ignored" = ignored by HA manager
  # - Requires Proxmox cluster with HA configured
  # hastate = "started"

  # hagroup: HA group for container
  # - Null = no HA group (default)
  # - Name of HA group configured in cluster
  # - Requires hastate to be configured
  # - Controls which nodes container can run on
  # - Configure HA groups in: Datacenter → HA → Groups
  # hagroup = "production-ha"

  # ---------------------------------------------------------------------------
  # METADATA & TAGS
  # ---------------------------------------------------------------------------
  # description: Container description
  # - Free text describing container purpose/function
  # - Appears in Proxmox UI
  # - Useful for documentation and quick identification
  # - Supports multiple lines
  # - Module automatically adds management tags
  description = "Production Docker container for web applications"

  # tags: Custom tags for organization
  # - Key-value map
  # - Merged with mandatory module tags (managed-by, module)
  # - Useful for filtering, searching, and organizing resources
  # - Tag values appear in Proxmox UI tags field
  # - Full key=value pairs appear in description for reference
  tags = {
    environment = "production" # Environment: dev, stg, prd
    application = "web-server" # Application or service
    team        = "devops"     # Responsible team
    backup      = "daily"      # Backup policy
    test        = "true"
  }

  # ---------------------------------------------------------------------------
  # ADDITIONAL NETWORKS (Multiple network interfaces)
  # ---------------------------------------------------------------------------
  # additional_networks: Additional network interfaces beyond eth0
  # - List of network configurations
  # - Each network must have unique name (eth1, eth2, etc.)
  # - Primary network (eth0) configured via network_* variables
  # - Useful for: network segregation, multiple VLANs, DMZ, etc.
  # - Can mix different IP configurations (DHCP, static, manual)
  # - Each network can be on different bridge/VLAN
  additional_networks = [
    {
      # First additional network (eth1) - VLAN CORP
      name     = "eth1"          # Interface name
      bridge   = "vmbr0"         # Same bridge as eth0
      ip       = "10.10.0.10/20" # Static IP in CORP network
      gw       = "10.10.0.1"     # CORP gateway
      tag      = 10              # VLAN tag for CORP
      firewall = false           # Enable firewall on this interface
    },
    {
      # Second additional network (eth2) - VLAN IOT
      name     = "eth2"          # Interface name
      bridge   = "vmbr0"         # Same bridge as eth0
      ip       = "10.60.0.10/23" # Static IP in IOT network
      gw       = "10.60.0.1"     # IOT gateway
      tag      = 60              # VLAN tag for IOT
      firewall = false           # Enable firewall on this interface
    }
  ]

  # ---------------------------------------------------------------------------
  # ADDITIONAL STORAGE (Mountpoints)
  # ---------------------------------------------------------------------------
  # mountpoints: Additional storage volumes beyond root filesystem
  # - List of mountpoint configurations
  # - Each mountpoint must have unique slot number
  # - Supports storage-backed, bind mounts, and device mounts
  # - Useful for: data volumes, shared storage, NFS/CIFS shares
  # - Can be backed up independently from root filesystem
  # - Size is read-only after creation (can only increase)
  mountpoints = [
    {
      # Storage-backed mountpoint (Proxmox storage volume)
      slot    = "0"         # Mountpoint identifier (mp0)
      storage = "nas"       # Proxmox storage name
      mp      = "/mnt/data" # Mount path inside container
      size    = "50G"       # Volume size (50GB)
      backup  = true        # Include in container backups
      # Optional: acl, quota, replicate, shared
    },
    {
      # Another storage-backed volume for application data
      slot      = "1"               # Mountpoint identifier (mp1)
      storage   = "nas"             # Same or different storage
      mp        = "/var/lib/docker" # Docker data directory
      size      = "100G"            # 100GB for container images/volumes
      backup    = true              # Don't backup (too large/dynamic)
      replicate = false             # Don't replicate in storage jobs
      # NOTE: quota not supported in unprivileged containers
    }
  ]
}

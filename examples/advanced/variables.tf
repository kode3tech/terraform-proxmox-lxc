# =============================================================================
# VARIABLES
# =============================================================================
variable "target_node" {
  description = "Proxmox node name where the LXC container will be created"
  type        = string
  default     = "pve01"
}

variable "hostname" {
  description = "Hostname for the LXC container"
  type        = string
  default     = "docker-prd-app-01"
}

variable "ostemplate" {
  description = "OS template to use for the container"
  type        = string
  default     = "nas:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
}

variable "vmid" {
  description = "Unique container ID in Proxmox"
  type        = number
  default     = 200
}

variable "arch" {
  description = "Container CPU architecture (amd64, arm64, armhf, i386)"
  type        = string
  default     = "amd64"
}

variable "cores" {
  description = "Number of CPU cores allocated to container"
  type        = number
  default     = 8
}

variable "cpulimit" {
  description = "CPU usage limit in number of cores (0 = no limit)"
  type        = number
  default     = 4
}

variable "cpuunits" {
  description = "CPU weight for kernel scheduler"
  type        = number
  default     = 4096
}

variable "memory" {
  description = "Amount of RAM allocated to container in MB"
  type        = number
  default     = 4096
}

variable "swap" {
  description = "Amount of swap memory in MB"
  type        = number
  default     = 2048
}

variable "rootfs_storage" {
  description = "Storage pool for the root filesystem"
  type        = string
  default     = "nas"
}

variable "rootfs_size" {
  description = "Root filesystem size"
  type        = string
  default     = "20G"
}

variable "bwlimit" {
  description = "I/O bandwidth limit in KiB/s (null = no limit)"
  type        = number
  default     = null
}

variable "network_bridge" {
  description = "Network bridge to attach the container to"
  type        = string
  default     = "vmbr0"
}

variable "network_ip" {
  description = "Static IP address with CIDR notation"
  type        = string
  default     = "192.168.1.201/24"
}

variable "network_gateway" {
  description = "Network gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

variable "network_ip6" {
  description = "IPv6 address configuration (auto, dhcp, manual, or CIDR)"
  type        = string
  default     = "auto"
}

variable "network_gw6" {
  description = "IPv6 gateway address"
  type        = string
  default     = null
}

variable "network_hwaddr" {
  description = "Custom MAC address"
  type        = string
  default     = null
}

variable "network_mtu" {
  description = "Maximum Transmission Unit (packet size)"
  type        = number
  default     = 1500
}

variable "network_rate" {
  description = "Network rate limit in Mbps"
  type        = number
  default     = 100
}

variable "network_vlan" {
  description = "VLAN tag for network segmentation"
  type        = number
  default     = null
}

variable "network_firewall" {
  description = "Enable Proxmox firewall on interface"
  type        = bool
  default     = false
}

variable "nameserver" {
  description = "DNS server IP address"
  type        = string
  default     = "8.8.4.4"
}

variable "searchdomain" {
  description = "DNS search domain"
  type        = string
  default     = "kode3.intra"
}

variable "unprivileged" {
  description = "Run container as unprivileged user"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Start container automatically when host boots"
  type        = bool
  default     = false
}

variable "start" {
  description = "Start container immediately after creation"
  type        = bool
  default     = true
}

variable "template" {
  description = "Mark container as template"
  type        = bool
  default     = false
}

variable "unique" {
  description = "Generate random unique MAC address"
  type        = bool
  default     = false
}

variable "cmode" {
  description = "Container console mode (tty, console, shell)"
  type        = string
  default     = "console"
}

variable "console" {
  description = "Enable console device"
  type        = bool
  default     = true
}

variable "tty" {
  description = "Number of TTY terminals available"
  type        = number
  default     = 2
}

variable "startup" {
  description = "Boot order and timing configuration (format: order=N,up=N,down=N)"
  type        = string
  default     = "order=2,up=30,down=60"
}

variable "features_nesting" {
  description = "Enable nested virtualization (required for Docker)"
  type        = bool
  default     = true
}

variable "password" {
  description = "Root password for the container"
  type        = string
  default     = "YourSecurePassword123!"
  sensitive   = true
}

variable "ostype" {
  description = "Container operating system type"
  type        = string
  default     = null
}

variable "pool" {
  description = "Proxmox resource pool name"
  type        = string
  default     = null
}

variable "protection" {
  description = "Protection against accidental removal"
  type        = bool
  default     = false
}

variable "force" {
  description = "Force creation overwriting existing container"
  type        = bool
  default     = false
}

variable "restore" {
  description = "Mark operation as backup restore"
  type        = bool
  default     = false
}

variable "hookscript" {
  description = "Script executed on lifecycle events"
  type        = string
  default     = null
}

variable "description" {
  description = "Container description"
  type        = string
  default     = "Production Docker container for web applications"
}

variable "tags" {
  description = "Custom tags for organization"
  type        = map(string)
  default = {
    environment = "production"
    application = "web-server"
    team        = "devops"
    backup      = "daily"
    test        = "true"
  }
}

variable "additional_networks" {
  description = "Additional network interfaces beyond eth0"
  type = list(object({
    name     = string
    bridge   = string
    ip       = string
    gw       = string
    tag      = number
    firewall = bool
  }))
  default = [
    {
      name     = "eth1"
      bridge   = "vmbr0"
      ip       = "10.10.0.10/20"
      gw       = "10.10.0.1"
      tag      = 10
      firewall = false
    },
    {
      name     = "eth2"
      bridge   = "vmbr0"
      ip       = "10.60.0.10/23"
      gw       = "10.60.0.1"
      tag      = 60
      firewall = false
    }
  ]
}

variable "mountpoints" {
  description = "Additional storage volumes beyond root filesystem"
  type = list(object({
    slot      = string
    storage   = string
    mp        = string
    size      = string
    backup    = bool
    replicate = optional(bool)
  }))
  default = [
    {
      slot    = "0"
      storage = "nas"
      mp      = "/mnt/data"
      size    = "50G"
      backup  = true
    },
    {
      slot      = "1"
      storage   = "nas"
      mp        = "/var/lib/docker"
      size      = "100G"
      backup    = true
      replicate = false
    }
  ]
}
# =============================================================================

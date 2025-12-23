# Naming inputs (mandatory)
variable "prefix" {
  description = "Prefix for resource naming"
  type        = string

  validation {
    condition     = length(var.prefix) > 0 && length(var.prefix) <= 10
    error_message = "Prefix must be between 1 and 10 characters"
  }
}

variable "env" {
  description = "Environment identifier (dev, stg, or prd)"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prd"], var.env)
    error_message = "Environment must be one of: dev, stg, prd"
  }
}

variable "workload" {
  description = "Workload identifier for the container"
  type        = string

  validation {
    condition     = length(var.workload) > 0 && length(var.workload) <= 20
    error_message = "Workload must be between 1 and 20 characters"
  }
}

variable "index" {
  description = "Numeric index for the container (01-99)"
  type        = string
  default     = "01"

  validation {
    condition     = can(regex("^(0[1-9]|[1-9][0-9])$", var.index))
    error_message = "Index must be between 01 and 99"
  }
}

# Proxmox configuration
variable "target_node" {
  description = "Name of the Proxmox node where the container will be created"
  type        = string
}

variable "vmid" {
  description = "VM ID for the LXC container. If not set, Proxmox will auto-assign"
  type        = number
  default     = null
}

# Container specifications
variable "ostemplate" {
  description = "OS template for the container (e.g., 'local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst')"
  type        = string
}

variable "arch" {
  description = "Container architecture"
  type        = string
  default     = "amd64"

  validation {
    condition     = contains(["amd64", "arm64", "armhf", "i386"], var.arch)
    error_message = "Architecture must be one of: amd64, arm64, armhf, i386"
  }
}

variable "cores" {
  description = "Number of CPU cores allocated to the container"
  type        = number
  default     = 1

  validation {
    condition     = var.cores >= 1 && var.cores <= 128
    error_message = "Cores must be between 1 and 128"
  }
}

variable "memory" {
  description = "Memory allocation in MB for the container"
  type        = number
  default     = 512

  validation {
    condition     = var.memory >= 128 && var.memory <= 524288
    error_message = "Memory must be between 128MB and 512GB"
  }
}

variable "swap" {
  description = "Swap allocation in MB for the container"
  type        = number
  default     = 512

  validation {
    condition     = var.swap >= 0 && var.swap <= 524288
    error_message = "Swap must be between 0MB and 512GB"
  }
}

# Storage configuration
variable "rootfs_storage" {
  description = "Storage pool for the root filesystem"
  type        = string
  default     = "local-lvm"
}

variable "rootfs_size" {
  description = "Size of the root filesystem (e.g., '8G', '20G')"
  type        = string
  default     = "8G"

  validation {
    condition     = can(regex("^[0-9]+[GM]$", var.rootfs_size))
    error_message = "Rootfs size must be in format like '8G' or '1024M'"
  }
}

# Network configuration
variable "network_bridge" {
  description = "Network bridge to attach the container to"
  type        = string
  default     = "vmbr0"
}

variable "network_ip" {
  description = "IP address configuration for the container (e.g., '192.168.1.100/24' or 'dhcp')"
  type        = string
  default     = "dhcp"
}

variable "network_gateway" {
  description = "Gateway IP address for the container network"
  type        = string
  default     = null
}

variable "network_vlan" {
  description = "VLAN tag for the network interface"
  type        = number
  default     = null

  validation {
    condition     = var.network_vlan == null || (var.network_vlan >= 1 && var.network_vlan <= 4094)
    error_message = "VLAN must be between 1 and 4094"
  }
}

# Container settings
variable "unprivileged" {
  description = "Create an unprivileged container (recommended for security)"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Start container on host boot"
  type        = bool
  default     = false
}

variable "start" {
  description = "Start the container after creation"
  type        = bool
  default     = true
}

variable "ssh_public_keys" {
  description = "SSH public keys to inject into the container"
  type        = string
  default     = null
}

variable "password" {
  description = "Root password for the container (use with caution)"
  type        = string
  default     = null
  sensitive   = true
}

# Tagging and metadata
variable "tags" {
  description = "Additional tags to apply to the container (will be merged with mandatory tags)"
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "Description of the container"
  type        = string
  default     = ""
}

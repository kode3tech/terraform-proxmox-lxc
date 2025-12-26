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
  default     = "lxc-hookscript-demo"
}

variable "ostemplate" {
  description = "OS template to use for the container"
  type        = string
  default     = "nas:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
}

variable "vmid" {
  description = "Unique container ID in Proxmox"
  type        = number
  default     = 300
}

variable "rootfs_storage" {
  description = "Storage pool for the root filesystem"
  type        = string
  default     = "nas"
}

variable "network_bridge" {
  description = "Network bridge to attach the container to"
  type        = string
  default     = "vmbr0"
}

variable "network_ip" {
  description = "Static IP address with CIDR notation"
  type        = string
  default     = "192.168.1.210/24"
}

variable "network_gateway" {
  description = "Network gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

variable "hookscript" {
  description = "Path to hookscript in Proxmox storage (format: storage:snippets/script.sh)"
  type        = string
  default     = "local:snippets/hookscript.sh"
}

variable "root_password" {
  description = "Root password for the container"
  type        = string
  default     = "YourSecurePassword123!"
  sensitive   = true
}

variable "cores" {
  description = "Number of CPU cores allocated to container"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of RAM allocated to container in MB"
  type        = number
  default     = 2048
}

variable "swap" {
  description = "Amount of swap memory in MB"
  type        = number
  default     = 1024
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

variable "rootfs_size" {
  description = "Size of the root filesystem"
  type        = string
  default     = "8G"
}

variable "features_nesting" {
  description = "Enable nested virtualization (required for Docker/containers)"
  type        = bool
  default     = true
}

variable "description" {
  description = "Container description"
  type        = string
  default     = "LXC container with hookscript demonstration"
}

variable "tags" {
  description = "Custom tags for organization"
  type        = map(string)
  default = {
    environment = "demo"
    purpose     = "hookscript-testing"
  }
}

# No input variables are required for this example.
# =============================================================================

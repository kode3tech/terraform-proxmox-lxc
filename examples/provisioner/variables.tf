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
  default     = "lxc-script-demo"
}

variable "ostemplate" {
  description = "OS template to use for the container"
  type        = string
  default     = "nas:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "vmid" {
  description = "Unique container ID in Proxmox"
  type        = number
  default     = 400
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
  description = "Static IP address with CIDR notation (required for provisioner)"
  type        = string
  default     = "192.168.1.220/24"
}

variable "network_gateway" {
  description = "Network gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

variable "cores" {
  description = "Number of CPU cores allocated to container"
  type        = number
  default     = 4
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

variable "unprivileged" {
  description = "Run container as unprivileged user"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Start container automatically when host boots"
  type        = bool
  default     = true
}

variable "start" {
  description = "Start container immediately after creation"
  type        = bool
  default     = true
}

variable "rootfs_size" {
  description = "Size of the root filesystem"
  type        = string
  default     = "16G"
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

variable "description" {
  description = "Container description"
  type        = string
  default     = "LXC container with Docker installed via external script"
}

variable "tags" {
  description = "Custom tags for organization"
  type        = map(string)
  default = {
    environment = "demo"
    purpose     = "provisioner-script"
    stack       = "docker"
  }
}

# No input variables are required for this example.
# =============================================================================

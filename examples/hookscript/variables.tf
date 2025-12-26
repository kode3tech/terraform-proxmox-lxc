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

# No input variables are required for this example.
# =============================================================================

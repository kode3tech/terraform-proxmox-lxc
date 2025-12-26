variable "target_node" {
  description = "Proxmox node name where the LXC container will be created"
  type        = string
  default     = "pve01"
}

variable "hostname" {
  description = "Hostname for the LXC container"
  type        = string
  default     = "app-dev-web-01"
}

variable "ostemplate" {
  description = "OS template to use for the container (storage:vztmpl/template-name.tar.gz)"
  type        = string
  default     = "nas:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
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

variable "rootfs_size" {
  description = "Size of the root filesystem"
  type        = string
  default     = "8G"
}

variable "network_ip" {
  description = "IP address configuration (dhcp, manual, or CIDR notation)"
  type        = string
  default     = "dhcp"
}

variable "root_password" {
  description = "Root password for the container (use ssh_public_keys in production instead)"
  type        = string
  default     = "YourSecurePassword123!"
  sensitive   = true
}

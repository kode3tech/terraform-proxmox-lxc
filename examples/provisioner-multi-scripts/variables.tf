
variable "target_node" {
  description = "Proxmox node name where the LXC container will be created"
  type        = string
  default     = "pve01"
}

variable "hostname" {
  description = "Hostname for the LXC container"
  type        = string
  default     = "lxc-multi-scripts-demo"
}

variable "ostemplate" {
  description = "OS template to use for the container"
  type        = string
  default     = "nas:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "vmid" {
  description = "Unique container ID in Proxmox"
  type        = number
  default     = 401
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
  default     = "192.168.1.221/24"
}

variable "network_gateway" {
  description = "Network gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

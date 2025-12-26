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

# No input variables are required for this example.
# =============================================================================

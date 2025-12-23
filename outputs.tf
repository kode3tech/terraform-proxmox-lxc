output "id" {
  description = "The ID of the LXC container resource"
  value       = proxmox_lxc.this.id
}

output "hostname" {
  description = "The hostname of the LXC container"
  value       = proxmox_lxc.this.hostname
}

output "vmid" {
  description = "The VM ID assigned to the LXC container"
  value       = proxmox_lxc.this.vmid
}

output "ipv4_address" {
  description = "The IPv4 address of the LXC container (if static IP is configured)"
  value       = var.network_ip != "dhcp" ? split("/", var.network_ip)[0] : null
}

output "network_config" {
  description = "Network configuration applied to the container"
  value = {
    bridge  = var.network_bridge
    ip      = var.network_ip
    gateway = var.network_gateway
    vlan    = var.network_vlan
  }
}

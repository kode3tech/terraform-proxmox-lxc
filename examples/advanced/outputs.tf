# =============================================================================
# OUTPUTS
# =============================================================================

output "container_id" {
  description = "The VMID of the created LXC container"
  value       = module.lxc_advanced.id
}

output "container_name" {
  description = "The hostname of the created LXC container"
  value       = module.lxc_advanced.hostname
}

output "container_vmid" {
  description = "The VMID of the created LXC container"
  value       = module.lxc_advanced.vmid
}

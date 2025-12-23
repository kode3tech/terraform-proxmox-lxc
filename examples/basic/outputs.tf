output "container_id" {
  description = "Container ID"
  value       = module.lxc_container.id
}

output "container_hostname" {
  description = "Container hostname"
  value       = module.lxc_container.hostname
}

output "container_vmid" {
  description = "Container VMID"
  value       = module.lxc_container.vmid
}

output "container_ip" {
  description = "Container IP address"
  value       = module.lxc_container.ipv4_address
}

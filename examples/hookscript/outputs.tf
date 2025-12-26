# =============================================================================
# OUTPUTS
# =============================================================================

output "container_id" {
  description = "Container VMID"
  value       = module.lxc_with_hookscript.vmid
}

output "container_hostname" {
  description = "Container hostname"
  value       = module.lxc_with_hookscript.hostname
}

output "hookscript_log" {
  description = "Path to hookscript log file on Proxmox host"
  value       = "/var/log/pve/hookscript-${module.lxc_with_hookscript.vmid}.log"
}

output "check_logs_command" {
  description = "Command to check hookscript logs"
  value       = "ssh root@pve01 'tail -f /var/log/pve/hookscript-${module.lxc_with_hookscript.vmid}.log'"
}

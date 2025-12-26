# =============================================================================
# OUTPUTS
# =============================================================================

output "container_id" {
  description = "Container VMID"
  value       = module.lxc_with_script.vmid
}

output "container_ip" {
  description = "Container IP address"
  value       = "192.168.1.220"
}

output "ssh_command" {
  description = "SSH command for container"
  value       = "ssh -i ~/.ssh/id_rsa root@192.168.1.220"
}

output "docker_test_command" {
  description = "Command to test Docker installation"
  value       = "ssh -i ~/.ssh/id_rsa root@192.168.1.220 'docker run hello-world'"
}

output "check_logs" {
  description = "Command to check initialization logs"
  value       = "ssh -i ~/.ssh/id_rsa root@192.168.1.220 'cat /var/log/container-init.log'"
}

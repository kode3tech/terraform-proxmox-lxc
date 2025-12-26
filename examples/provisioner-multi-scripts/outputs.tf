# =============================================================================
# OUTPUTS
# =============================================================================

output "container_id" {
  description = "Container VMID"
  value       = module.lxc_with_multi_scripts.vmid
}

output "container_ip" {
  description = "Container IP address"
  value       = "192.168.1.221"
}

output "ssh_command" {
  description = "SSH command for container"
  value       = "ssh -i ~/.ssh/id_rsa root@192.168.1.221"
}

output "docker_test_command" {
  description = "Command to test Docker installation"
  value       = "ssh -i ~/.ssh/id_rsa root@192.168.1.221 'docker run hello-world'"
}

output "scripts_executed" {
  description = "Scripts that were executed in order"
  value = [
    "01-system-update.sh",
    "02-configure-timezone.sh",
    "03-create-user.sh",
    "04-install-docker.sh",
    "05-configure-logging.sh"
  ]
}

output "check_logs" {
  description = "Command to check application logs configuration"
  value       = "ssh -i ~/.ssh/id_rsa root@192.168.1.221 'ls -la /var/log/app/ && cat /etc/logrotate.d/app'"
}

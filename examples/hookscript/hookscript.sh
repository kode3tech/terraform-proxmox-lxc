#!/usr/bin/perl
# =============================================================================
# LXC HOOKSCRIPT EXAMPLE
# =============================================================================
# This script is executed during various stages of the container's lifecycle.
# It demonstrates all available hook phases and common use cases.
#
# REQUIREMENTS:
# - Must be executable (chmod +x)
# - Must be stored in a Proxmox storage with 'snippets' content type
# - Must use Perl (Proxmox requirement)
#
# USAGE:
# 1. Upload this script to Proxmox:
#    scp hookscript.sh root@proxmox:/var/lib/vz/snippets/
# 2. Make it executable:
#    ssh root@proxmox "chmod +x /var/lib/vz/snippets/hookscript.sh"
# 3. Reference in Terraform:
#    hookscript = "local:snippets/hookscript.sh"
#
# AVAILABLE PHASES:
# - pre-start:  Before container starts
# - post-start: After container starts
# - pre-stop:   Before container stops
# - post-stop:  After container stops
#
# ENVIRONMENT VARIABLES PROVIDED BY PROXMOX:
# - $ENV{PHASE}:    Current hook phase (pre-start, post-start, etc.)
# - $ENV{VMID}:     Container VMID
# - $ENV{VMTYPE}:   Type of VM (lxc)
# =============================================================================

use strict;
use warnings;

# Get environment variables
my $phase = $ENV{PHASE} // 'unknown';
my $vmid  = $ENV{VMID}  // 'unknown';
my $vmtype = $ENV{VMTYPE} // 'unknown';

# Log file path (stored on Proxmox host)
my $logfile = "/var/log/pve/hookscript-${vmid}.log";

# Function to log messages
sub log_message {
    my ($message) = @_;
    my $timestamp = localtime();
    open(my $fh, '>>', $logfile) or die "Cannot open log file: $!";
    print $fh "[$timestamp] [VMID:$vmid] [$phase] $message\n";
    close($fh);
}

# Log the hook execution
log_message("Hookscript executed - Phase: $phase, Type: $vmtype");

# Execute phase-specific actions
if ($phase eq 'pre-start') {
    # -------------------------------------------------------------------------
    # PRE-START PHASE
    # -------------------------------------------------------------------------
    # Executed BEFORE the container starts
    # Use cases:
    # - Validate prerequisites
    # - Setup network resources
    # - Mount additional filesystems on host
    # - Check resource availability
    # - Backup configuration
    # -------------------------------------------------------------------------

    log_message("Container is about to start");

    # Example: Check if required mount point exists on host
    if (! -d "/mnt/shared-data") {
        log_message("WARNING: /mnt/shared-data does not exist on host");
        # Could create it or exit with error
        # exit 1;  # Uncomment to prevent container start
    }

    # Example: Ensure network bridge is available
    my $bridge_check = `ip link show vmbr0 2>/dev/null`;
    if ($? != 0) {
        log_message("ERROR: Bridge vmbr0 not found");
        exit 1;
    }

    log_message("Pre-start checks completed successfully");

} elsif ($phase eq 'post-start') {
    # -------------------------------------------------------------------------
    # POST-START PHASE
    # -------------------------------------------------------------------------
    # Executed AFTER the container has started
    # Use cases:
    # - Configure container via SSH/exec
    # - Update DNS records
    # - Register container in monitoring
    # - Send notifications
    # - Wait for services to be ready
    # -------------------------------------------------------------------------

    log_message("Container has started successfully");

    # Example: Wait for container to be fully ready
    sleep 5;

    # Example: Execute command inside the container
    my $container_cmd = "pct exec $vmid -- systemctl is-system-running --wait 2>/dev/null";
    my $result = `$container_cmd`;
    log_message("Container system status: " . ($result || "unknown"));

    # Example: Configure container networking (if needed)
    # system("pct exec $vmid -- ip route add default via 192.168.1.1");

    # Example: Update external DNS via API
    # my $hostname = `pct exec $vmid -- hostname -f`;
    # chomp($hostname);
    # log_message("Container hostname: $hostname");
    # Could call DNS API here to register hostname

    # Example: Send notification
    # system("echo 'Container $vmid started' | mail -s 'LXC Alert' admin\@example.com");

    log_message("Post-start configuration completed");

} elsif ($phase eq 'pre-stop') {
    # -------------------------------------------------------------------------
    # PRE-STOP PHASE
    # -------------------------------------------------------------------------
    # Executed BEFORE the container stops
    # Use cases:
    # - Gracefully shutdown services
    # - Backup critical data
    # - Flush logs/buffers
    # - Unregister from monitoring
    # - Update DNS records
    # -------------------------------------------------------------------------

    log_message("Container is about to stop");

    # Example: Backup critical data before stopping
    # my $backup_cmd = "pct exec $vmid -- tar czf /tmp/backup.tar.gz /etc";
    # system($backup_cmd);

    # Example: Gracefully stop services
    # system("pct exec $vmid -- systemctl stop docker");
    # sleep 10;  # Wait for graceful shutdown

    # Example: Flush logs
    # system("pct exec $vmid -- sync");

    log_message("Pre-stop preparation completed");

} elsif ($phase eq 'post-stop') {
    # -------------------------------------------------------------------------
    # POST-STOP PHASE
    # -------------------------------------------------------------------------
    # Executed AFTER the container has stopped
    # Use cases:
    # - Clean up resources
    # - Unmount filesystems on host
    # - Update monitoring status
    # - Send notifications
    # - Archive logs
    # -------------------------------------------------------------------------

    log_message("Container has stopped");

    # Example: Archive container logs
    my $log_archive = "/var/log/pve/archived-logs";
    if (! -d $log_archive) {
        mkdir($log_archive) or log_message("Cannot create archive directory");
    }

    # Example: Copy container logs to archive
    # system("cp /var/lib/lxc/${vmid}/console.log ${log_archive}/console-${vmid}-" . time() . ".log");

    # Example: Clean up temporary files on host
    # system("rm -f /tmp/container-${vmid}-*");

    # Example: Update external monitoring
    # system("curl -X POST https://monitoring.example.com/api/containers/$vmid/offline");

    log_message("Post-stop cleanup completed");

} else {
    log_message("Unknown phase: $phase");
}

# Exit successfully
exit 0;

# Hookscript Example - Lifecycle Management

This example demonstrates how to use **Proxmox hookscripts** for LXC container lifecycle management, executing custom logic on the **Proxmox host** during container events.

## OpenTofu Compatibility

✅ **This module is fully compatible with OpenTofu!**

All `terraform` commands in this guide can be replaced with `tofu`:

```bash
# Using Terraform
terraform init && terraform apply

# Using OpenTofu
tofu init && tofu apply
```

## What This Example Creates

- ✅ **LXC container** with static IP (192.168.1.210/24)
- ✅ **Hookscript** attached to container lifecycle
- ✅ **Custom logic** executed during start/stop events
- ✅ **Host-side execution** (runs on Proxmox, not in container)
- ✅ **Event logging** for debugging and auditing
- ✅ **SSH key authentication** configured

## What Are Hookscripts?

**Hookscripts** are Perl scripts that execute on the **Proxmox host** during LXC container lifecycle events.

### Key Characteristics

| Feature | Hookscript | Provisioner (remote-exec) |
|---------|------------|---------------------------|
| **Execution location** | Proxmox host | Inside container (via SSH) |
| **Language** | Perl only | Any (bash, python, etc.) |
| **When executes** | Every lifecycle event | Once after creation |
| **Manual upload required** | ✅ Yes (to Proxmox) | ❌ No (embedded in Terraform) |
| **Network required** | ❌ No | ✅ Yes (SSH) |
| **Access to container** | Via `pct exec` | Via SSH |
| **Access to host** | Direct (runs as root) | ❌ No |
| **Best for** | Lifecycle management | Initial configuration |

### Lifecycle Phases

Hookscripts can execute during **4 lifecycle phases**:

1. **pre-start** - Before container starts
   - Use case: Prepare host resources, mount storage, check prerequisites

2. **post-start** - After container starts
   - Use case: Configure container, register with monitoring, update DNS

3. **pre-stop** - Before container stops
   - Use case: Graceful shutdown, backup data, deregister services

4. **post-stop** - After container stops
   - Use case: Cleanup host resources, unmount storage, log events

---

## Hookscript vs Provisioner: When to Use Each

### Use Hookscripts When:

✅ Need to execute on **Proxmox host** (not inside container)
✅ Need to run on **every start/stop** (not just once)
✅ Need access to **host resources** (storage, networking, other containers)
✅ Managing **lifecycle events** (mounting, backups, DNS updates)
✅ Container **may not have network** during execution
✅ Need to execute **before container fully starts**

**Example use cases:**
- Mount NFS share on host before container starts
- Update external DNS when container starts
- Backup container data before stopping
- Register/deregister with monitoring system
- Cleanup host resources after stop

### Use Provisioners When:

✅ Need to execute **inside container** (not on host)
✅ Only need to run **once after creation**
✅ Installing **software inside container** (Docker, apps)
✅ Configuring **container OS** (users, timezone, packages)
✅ Container **has network access**

**Example use cases:**
- Install Docker inside container
- Configure application settings
- Create users and groups
- Deploy application code

### Can Use Both Together:

```hcl
module "lxc" {
  # Hookscript: Mount NFS on host when container starts
  hookscript = "local:snippets/mount-nfs.sh"

  # Provisioner: Install Docker inside container after creation
  provisioner_enabled = true
  provisioner_script_path = "${path.module}/scripts/install-docker.sh"
}
```

---

## Prerequisites

### 1. Proxmox Environment

- **Proxmox VE** 7.x or 8.x
- **Storage** named `nas` available
- **Network bridge** `vmbr0` configured
- **Static IP available**: `192.168.1.210/24`
- **LXC template**: Ubuntu 20.04
- **Snippets storage**: `local` with snippets content type enabled

### 2. Local Tools

- **Terraform** >= 1.6.0 **OR OpenTofu** >= 1.6.0
- **direnv** for environment variable loading
- **SSH client** with key pair
- **SCP** for uploading hookscript to Proxmox

### 3. Proxmox Storage Configuration

The hookscript must be stored in a Proxmox storage that supports **snippets** content type.

```bash
# Check current storage configuration
ssh root@proxmox-host "pvesm status"

# Check if 'local' supports snippets
ssh root@proxmox-host "pvesm status | grep local"
# Should show: local ... dir ... vztmpl,iso,snippets

# If snippets is missing, enable it:
ssh root@proxmox-host "pvesm set local --content vztmpl,iso,snippets"
```

---

## Quick Start

### Step 1: Setup Environment

```bash
# Navigate to example directory
cd examples/hookscript

# Copy environment configuration
cp .env.example .env

# Edit with your Proxmox credentials
nano .env  # or vim .env

# Allow direnv to load variables
direnv allow .
```

### Step 2: Review the Hookscript

This example includes a sample Perl hookscript:

```bash
# View the hookscript
cat hookscript.pl
```

**What the hookscript does:**
- Logs all lifecycle events to `/var/log/pve/hookscript.log`
- Executes different logic for each phase (pre-start, post-start, pre-stop, post-stop)
- Demonstrates accessing container ID and phase information
- Shows how to execute commands inside container (`pct exec`)

### Step 3: Upload Hookscript to Proxmox

⚠️ **CRITICAL STEP**: Hookscripts must be manually uploaded to Proxmox!

```bash
# Upload hookscript to Proxmox snippets directory
scp hookscript.pl root@proxmox-host:/var/lib/vz/snippets/

# Make it executable (REQUIRED)
ssh root@proxmox-host "chmod +x /var/lib/vz/snippets/hookscript.pl"

# Verify upload and permissions
ssh root@proxmox-host "ls -l /var/lib/vz/snippets/hookscript.pl"
# Should show: -rwxr-xr-x ... /var/lib/vz/snippets/hookscript.pl
```

**Alternative storage locations:**

If using different storage:
```bash
# For 'nas' storage (NFS/CIFS)
scp hookscript.pl root@proxmox-host:/mnt/pve/nas/snippets/

# Update main.tf:
hookscript = "nas:snippets/hookscript.pl"
```

### Step 4: Generate SSH Keys (if not exists)

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "proxmox-hookscript" -f ~/.ssh/id_rsa -N ""

# Verify keys
ls -la ~/.ssh/id_rsa*
```

### Step 5: Download LXC Template

```bash
# SSH into Proxmox host
ssh root@proxmox-host

# Update template list
pveam update

# Download Ubuntu 20.04 template
pveam download nas ubuntu-20.04-standard_20.04-1_amd64.tar.gz

# Verify
pveam list nas | grep ubuntu-20.04
```

### Step 6: Customize Configuration

Edit `main.tf` to match your environment:

```hcl
module "lxc_with_hookscript" {
  source = "../.."

  # Update these:
  hostname    = "your-container-name"
  target_node = "pve01"                      # Your node
  ostemplate  = "nas:vztmpl/ubuntu-20.04..." # Your template

  # Update network:
  network_ip      = "192.168.1.210/24"       # Available IP
  network_gateway = "192.168.1.1"            # Your gateway

  # Update hookscript path (storage:snippets/filename):
  hookscript = "local:snippets/hookscript.pl"

  # Update SSH key:
  ssh_public_keys = file("~/.ssh/id_rsa.pub")
}
```

### Step 7: Deploy

```bash
# Initialize
terraform init  # or: tofu init

# Review plan
terraform plan  # or: tofu plan

# Apply
terraform apply  # or: tofu apply
# Type 'yes' when prompted
```

**Expected Output:**

```
module.lxc_with_hookscript.proxmox_lxc.this: Creating...
module.lxc_with_hookscript.proxmox_lxc.this: Still creating... [10s elapsed]
module.lxc_with_hookscript.proxmox_lxc.this: Creation complete after 25s

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

container_hostname = "lxc-hookscript-demo"
container_id = "pve01/lxc/300"
container_ip = "192.168.1.210"
container_vmid = 300
```

### Step 8: Verify Hookscript Execution

```bash
# Check hookscript log on Proxmox host
ssh root@proxmox-host "tail -f /var/log/pve/hookscript.log"

# Should show entries like:
# [2024-01-15 14:30:00] pre-start: Container 300 starting...
# [2024-01-15 14:30:05] post-start: Container 300 started successfully!
```

---

## Testing Hookscript Phases

### Trigger post-start (Container Start)

```bash
# Start the container
terraform apply  # If container is stopped

# Or manually via Proxmox:
ssh root@proxmox-host "pct start 300"

# Check hookscript log
ssh root@proxmox-host "tail -20 /var/log/pve/hookscript.log"
# Should show:
# [timestamp] pre-start: Container 300 starting...
# [timestamp] post-start: Container 300 started!
```

### Trigger pre-stop and post-stop (Container Stop)

```bash
# Stop the container
ssh root@proxmox-host "pct stop 300"

# Check hookscript log
ssh root@proxmox-host "tail -20 /var/log/pve/hookscript.log"
# Should show:
# [timestamp] pre-stop: Container 300 stopping...
# [timestamp] post-stop: Container 300 stopped!
```

### Trigger on Reboot

```bash
# Reboot the container
ssh root@proxmox-host "pct reboot 300"

# Check hookscript log (should show all 4 phases)
ssh root@proxmox-host "tail -40 /var/log/pve/hookscript.log"
# Should show:
# pre-stop, post-stop (shutdown)
# pre-start, post-start (startup)
```

---

## Understanding the Hookscript

### Script Structure

The included `hookscript.pl` demonstrates all phases:

```perl
#!/usr/bin/perl

use strict;
use warnings;

# Get container ID and phase from arguments
my $vmid = shift;
my $phase = shift;

# Log file
my $logfile = "/var/log/pve/hookscript.log";

# Open log file for appending
open(my $fh, '>>', $logfile) or die "Cannot open $logfile: $!";

# Get timestamp
my $timestamp = localtime();

# Log the event
print $fh "[$timestamp] $phase: Container $vmid - Phase triggered\n";

# Phase-specific logic
if ($phase eq 'pre-start') {
    print $fh "[$timestamp] pre-start: Preparing container $vmid...\n";
    # Example: Mount NFS share
    # system("mount -t nfs server:/share /mnt/lxc-$vmid");

} elsif ($phase eq 'post-start') {
    print $fh "[$timestamp] post-start: Container $vmid started!\n";
    # Example: Update DNS
    # system("nsupdate -k /etc/bind/update.key update.txt");

} elsif ($phase eq 'pre-stop') {
    print $fh "[$timestamp] pre-stop: Preparing to stop container $vmid...\n";
    # Example: Backup data
    # system("pct exec $vmid -- tar czf /backup/data.tar.gz /data");

} elsif ($phase eq 'post-stop') {
    print $fh "[$timestamp] post-stop: Container $vmid stopped!\n";
    # Example: Unmount NFS
    # system("umount /mnt/lxc-$vmid");
}

close($fh);

exit(0);  # Success
```

### Available Variables

Hookscripts receive these arguments:

- `$vmid` (ARGV[0]) - Container VMID (e.g., 300)
- `$phase` (ARGV[1]) - Lifecycle phase (pre-start, post-start, pre-stop, post-stop)

### Common Perl Modules

```perl
use strict;           # Enforce strict variable declarations
use warnings;         # Enable warnings
use File::Path;       # Create/remove directories
use File::Copy;       # Copy files
use LWP::UserAgent;   # HTTP requests
use JSON;             # JSON parsing
```

---

## Real-World Use Cases

### 1. NFS Mount Management

Mount NFS share when container starts, unmount when stops:

```perl
#!/usr/bin/perl
use strict;
use warnings;

my $vmid = shift;
my $phase = shift;

my $nfs_server = "192.168.1.10";
my $nfs_share = "/data/containers";
my $mount_point = "/mnt/lxc-$vmid";

if ($phase eq 'pre-start') {
    # Create mount point
    system("mkdir -p $mount_point");

    # Mount NFS
    system("mount -t nfs $nfs_server:$nfs_share $mount_point");

    # Bind mount into container
    system("pct set $vmid -mp0 $mount_point,mp=/mnt/data");

} elsif ($phase eq 'post-stop') {
    # Unmount NFS
    system("umount $mount_point");

    # Remove mount point
    system("rmdir $mount_point");
}

exit(0);
```

### 2. Dynamic DNS Updates

Update DNS when container starts/stops:

```perl
#!/usr/bin/perl
use strict;
use warnings;

my $vmid = shift;
my $phase = shift;

# Get container IP
my $ip = `pct exec $vmid -- hostname -I | awk '{print \$1}'`;
chomp($ip);

# Get container hostname
my $hostname = `pct exec $vmid -- hostname`;
chomp($hostname);

if ($phase eq 'post-start') {
    # Add DNS record
    system("nsupdate -k /etc/bind/update.key <<EOF
server 192.168.1.1
zone example.com
update add $hostname.example.com 300 A $ip
send
EOF");

} elsif ($phase eq 'pre-stop') {
    # Remove DNS record
    system("nsupdate -k /etc/bind/update.key <<EOF
server 192.168.1.1
zone example.com
update delete $hostname.example.com A
send
EOF");
}

exit(0);
```

### 3. Backup Before Stop

Automatically backup container data before stopping:

```perl
#!/usr/bin/perl
use strict;
use warnings;

my $vmid = shift;
my $phase = shift;

if ($phase eq 'pre-stop') {
    my $timestamp = `date +%Y%m%d-%H%M%S`;
    chomp($timestamp);

    my $backup_dir = "/backup/lxc-$vmid";
    system("mkdir -p $backup_dir");

    # Backup container data
    system("pct exec $vmid -- tar czf - /data | cat > $backup_dir/data-$timestamp.tar.gz");

    # Keep only last 5 backups
    system("cd $backup_dir && ls -t | tail -n +6 | xargs rm -f");
}

exit(0);
```

### 4. Service Registration

Register container with monitoring/service discovery:

```perl
#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use JSON;

my $vmid = shift;
my $phase = shift;

my $consul_api = "http://consul.example.com:8500/v1";
my $ua = LWP::UserAgent->new;

if ($phase eq 'post-start') {
    # Get container info
    my $ip = `pct exec $vmid -- hostname -I | awk '{print \$1}'`;
    chomp($ip);
    my $hostname = `pct exec $vmid -- hostname`;
    chomp($hostname);

    # Register with Consul
    my $service = {
        ID => "lxc-$vmid",
        Name => $hostname,
        Address => $ip,
        Port => 80,
    };

    $ua->put("$consul_api/agent/service/register",
             Content => encode_json($service));

} elsif ($phase eq 'pre-stop') {
    # Deregister from Consul
    $ua->put("$consul_api/agent/service/deregister/lxc-$vmid");
}

exit(0);
```

### 5. Firewall Rule Management

Add/remove firewall rules dynamically:

```perl
#!/usr/bin/perl
use strict;
use warnings;

my $vmid = shift;
my $phase = shift;

if ($phase eq 'post-start') {
    # Get container IP
    my $ip = `pct exec $vmid -- hostname -I | awk '{print \$1}'`;
    chomp($ip);

    # Allow HTTP/HTTPS from container
    system("iptables -A FORWARD -s $ip -p tcp --dport 80 -j ACCEPT");
    system("iptables -A FORWARD -s $ip -p tcp --dport 443 -j ACCEPT");

} elsif ($phase eq 'post-stop') {
    # Get container IP (from config)
    my $config = `pct config $vmid`;
    my ($ip) = $config =~ /ip=(\d+\.\d+\.\d+\.\d+)/;

    # Remove firewall rules
    system("iptables -D FORWARD -s $ip -p tcp --dport 80 -j ACCEPT 2>/dev/null");
    system("iptables -D FORWARD -s $ip -p tcp --dport 443 -j ACCEPT 2>/dev/null");
}

exit(0);
```

---

## Troubleshooting

### 1. Hookscript Not Executing

**Symptoms:** No entries in log file after container start/stop

**Causes & Solutions:**

```bash
# Check if hookscript is configured
ssh root@proxmox-host "pct config 300 | grep hookscript"
# Should show: hookscript: local:snippets/hookscript.pl

# Check if hookscript file exists
ssh root@proxmox-host "ls -l /var/lib/vz/snippets/hookscript.pl"

# Check if hookscript is executable
ssh root@proxmox-host "ls -l /var/lib/vz/snippets/hookscript.pl"
# Should show: -rwxr-xr-x

# Make executable if not:
ssh root@proxmox-host "chmod +x /var/lib/vz/snippets/hookscript.pl"

# Check Proxmox task log
ssh root@proxmox-host "tail -f /var/log/pve/tasks/active"
```

### 2. Permission Denied Errors

**Error in Proxmox logs:**
```
hookscript: Permission denied
```

**Solutions:**

```bash
# Make hookscript executable
ssh root@proxmox-host "chmod +x /var/lib/vz/snippets/hookscript.pl"

# Check file ownership
ssh root@proxmox-host "ls -l /var/lib/vz/snippets/hookscript.pl"
# Should be owned by root

# Fix ownership if wrong
ssh root@proxmox-host "chown root:root /var/lib/vz/snippets/hookscript.pl"
```

### 3. Hookscript Syntax Errors

**Error:** Hookscript fails silently

**Debugging:**

```bash
# Test hookscript manually
ssh root@proxmox-host "perl -c /var/lib/vz/snippets/hookscript.pl"
# Should output: syntax OK

# Run manually with test arguments
ssh root@proxmox-host "perl /var/lib/vz/snippets/hookscript.pl 300 post-start"

# Check for runtime errors
ssh root@proxmox-host "perl -w /var/lib/vz/snippets/hookscript.pl 300 post-start"
```

### 4. Storage Does Not Support Snippets

**Error:**
```
storage 'local' does not support content type 'snippets'
```

**Solution:**

```bash
# Enable snippets content type
ssh root@proxmox-host "pvesm set local --content vztmpl,iso,snippets"

# Verify
ssh root@proxmox-host "pvesm status | grep local"
# Should show: local ... dir ... vztmpl,iso,snippets

# Alternative: Use different storage that supports snippets
# Edit main.tf:
hookscript = "nas:snippets/hookscript.pl"
# Upload hookscript to nas storage
```

### 5. Hookscript Path Wrong

**Error:**
```
hookscript: file does not exist
```

**Solutions:**

```bash
# Verify storage:snippets path format
# CORRECT: "local:snippets/hookscript.pl"
# WRONG: "local:/var/lib/vz/snippets/hookscript.pl"
# WRONG: "/var/lib/vz/snippets/hookscript.pl"

# List available hookscripts
ssh root@proxmox-host "pvesh get /nodes/pve01/storage/local/content --content snippets"

# Check main.tf configuration
hookscript = "local:snippets/hookscript.pl"  # Correct format
```

### 6. Container Won't Start After Adding Hookscript

**Error:** Container fails to start

**Debugging:**

```bash
# Check hookscript exit code
ssh root@proxmox-host "perl /var/lib/vz/snippets/hookscript.pl 300 pre-start; echo \$?"
# Should output: 0

# Non-zero exit code prevents container start!
# Fix hookscript to always exit(0)

# Temporarily disable hookscript
ssh root@proxmox-host "pct set 300 -delete hookscript"

# Start container
ssh root@proxmox-host "pct start 300"

# Fix hookscript, then re-enable
ssh root@proxmox-host "pct set 300 -hookscript local:snippets/hookscript.pl"
```

---

## Modifying the Hookscript

### Updating the Script

```bash
# Edit hookscript locally
nano hookscript.pl

# Upload new version
scp hookscript.pl root@proxmox-host:/var/lib/vz/snippets/

# Ensure executable
ssh root@proxmox-host "chmod +x /var/lib/vz/snippets/hookscript.pl"

# Test syntax
ssh root@proxmox-host "perl -c /var/lib/vz/snippets/hookscript.pl"

# Restart container to test
ssh root@proxmox-host "pct reboot 300"

# Check logs
ssh root@proxmox-host "tail -f /var/log/pve/hookscript.log"
```

**Note:** Terraform **does not** detect hookscript content changes. You must manually upload updates!

### Adding Debugging

```perl
#!/usr/bin/perl
use strict;
use warnings;

# Enable debugging
my $DEBUG = 1;

sub debug {
    return unless $DEBUG;
    my $msg = shift;
    my $logfile = "/var/log/pve/hookscript-debug.log";
    open(my $fh, '>>', $logfile);
    print $fh "[" . localtime() . "] DEBUG: $msg\n";
    close($fh);
}

my $vmid = shift;
my $phase = shift;

debug("VMID: $vmid, Phase: $phase");
debug("ENV: " . join(", ", map { "$_=$ENV{$_}" } keys %ENV));

# Rest of script...
```

---

## Cleanup

```bash
# Destroy container
terraform destroy  # or: tofu destroy

# Type 'yes' when prompted
```

**What gets deleted:**
- ✅ Container (VMID 300)
- ✅ Container disk

**What remains:**
- ❌ Hookscript on Proxmox (`/var/lib/vz/snippets/hookscript.pl`)
- ❌ Hookscript logs
- ❌ SSH keys
- ❌ LXC template

**Manual cleanup:**

```bash
# Remove hookscript from Proxmox
ssh root@proxmox-host "rm /var/lib/vz/snippets/hookscript.pl"

# Remove logs
ssh root@proxmox-host "rm /var/log/pve/hookscript.log"
```

---

## Next Steps

### Explore Other Examples

- **[Basic Example](../basic)** - Simple DHCP container
- **[Provisioner Example](../provisioner)** - Single external script
- **[Multi-Scripts Example](../provisioner-multi-scripts)** - Multiple ordered scripts
- **[Advanced Example](../advanced)** - All features, production-ready

### Combine with Provisioners

```hcl
module "lxc" {
  source = "../.."

  # Hookscript: Mount NFS when container starts
  hookscript = "local:snippets/mount-nfs.pl"

  # Provisioner: Install Docker after creation
  provisioner_enabled = true
  provisioner_script_path = "${path.module}/scripts/install-docker.sh"
  provisioner_ssh_private_key = "~/.ssh/id_rsa"
}
```

### Production Checklist

Before using in production:

- [ ] Test hookscript manually with all phases
- [ ] Verify hookscript exit codes (must be 0)
- [ ] Add comprehensive error handling
- [ ] Add logging for debugging
- [ ] Test container start/stop/reboot cycles
- [ ] Document hookscript purpose and behavior
- [ ] Version control hookscript
- [ ] Set up monitoring for hookscript failures
- [ ] Create deployment process for hookscript updates
- [ ] Consider idempotency (safe to run multiple times)
- [ ] Test failure scenarios (network down, NFS unavailable, etc.)
- [ ] Add timeout handling for long-running operations

---

## Additional Resources

### Documentation

- [Proxmox Hookscripts](https://pve.proxmox.com/wiki/Hookscript)
- [Proxmox Container Management](https://pve.proxmox.com/wiki/Linux_Container)
- [Perl Programming](https://perldoc.perl.org/)
- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc)

### Module Files

- [Module README](../../README.md)
- [Module Variables](../../variables.tf)
- [Module Outputs](../../outputs.tf)

### Perl Resources

- [Learn Perl](https://learn.perl.org/)
- [Perl Monks](https://www.perlmonks.org/)
- [CPAN Modules](https://metacpan.org/)

### Community

- [Proxmox Forum](https://forum.proxmox.com/)
- [Terraform Discussions](https://discuss.hashicorp.com/c/terraform-core)
- [OpenTofu Community](https://opentofu.org/community)

---

## Summary

This example demonstrates:

✅ **Hookscript integration** for lifecycle management
✅ **Host-side execution** on Proxmox server
✅ **All lifecycle phases** (pre/post start/stop)
✅ **Manual upload workflow** to Proxmox storage
✅ **Real-world use cases** (NFS, DNS, backups, monitoring)
✅ **Debugging techniques** for hookscript development
✅ **Complementary to provisioners** for complete automation

Use this as a template for your Proxmox LXC lifecycle management! 🚀
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.2-rc07 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lxc_with_hookscript"></a> [lxc\_with\_hookscript](#module\_lxc\_with\_hookscript) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_check_logs_command"></a> [check\_logs\_command](#output\_check\_logs\_command) | Command to check hookscript logs |
| <a name="output_container_hostname"></a> [container\_hostname](#output\_container\_hostname) | Container hostname |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Container VMID |
| <a name="output_hookscript_log"></a> [hookscript\_log](#output\_hookscript\_log) | Path to hookscript log file on Proxmox host |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

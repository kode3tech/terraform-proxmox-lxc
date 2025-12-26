# Provisioner Example - Multiple Ordered Scripts

This example demonstrates how to use **multiple modular scripts** with the `provisioner_scripts_dir` feature for organized, maintainable container provisioning.

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

- ✅ **LXC container** with static IP (192.168.1.221/24)
- ✅ **System updates** applied automatically
- ✅ **Timezone configured** (America/Sao_Paulo) with NTP
- ✅ **Application user** (`appuser`) and group created
- ✅ **Docker installed** via official repository
- ✅ **Logging configured** with rotation policies
- ✅ **Modular provisioning** - 5 ordered scripts
- ✅ **SSH key authentication** configured

## What is Scripts Directory Provisioning?

The `provisioner_scripts_dir` feature allows you to organize provisioning into **multiple, ordered shell scripts** instead of one monolithic script.

### Benefits of Multiple Scripts

✅ **Modularity** - Each script handles one logical concern
✅ **Reusability** - Copy individual scripts across projects
✅ **Maintainability** - Easier to update specific steps
✅ **Team collaboration** - Different team members own different scripts
✅ **Testing** - Test scripts independently
✅ **Clear ordering** - Numeric prefixes control execution sequence

### Execution Order

Scripts execute in **lexicographic (alphabetical) order**:

```
scripts/
├── 01-system-update.sh         # Runs first
├── 02-configure-timezone.sh    # Runs second
├── 03-create-user.sh           # Runs third
├── 04-install-docker.sh        # Runs fourth
└── 05-configure-logging.sh     # Runs last
```

**Naming convention:**
- Use numeric prefixes: `01-`, `02-`, `03-`
- Double digits for proper ordering (01 not 1)
- Descriptive names after prefix
- `.sh` extension required

---

## Scripts Overview

### 01-system-update.sh
**Purpose:** Update packages and install essential utilities

**What it does:**
- Updates package lists (`apt-get update`)
- Upgrades installed packages
- Installs: curl, wget, vim, git, htop, net-tools, dnsutils
- Cleans up package cache

**Why first?** Ensures all subsequent scripts have latest packages and utilities.

### 02-configure-timezone.sh
**Purpose:** Configure system timezone and time synchronization

**What it does:**
- Sets timezone to `America/Sao_Paulo`
- Installs NTP client (`systemd-timesyncd`)
- Enables and starts time sync service
- Verifies time configuration

**Why second?** Correct time is essential for logs, certificates, and scheduling.

### 03-create-user.sh
**Purpose:** Create application user and group

**What it does:**
- Creates `appgroup` system group
- Creates `appuser` system user
- Sets up home directory (`/opt/appuser`)
- Configures user for application workloads

**Why third?** User needed before installing applications that may require non-root execution.

### 04-install-docker.sh
**Purpose:** Install Docker Engine from official repository

**What it does:**
- Adds Docker's official GPG key
- Configures Docker APT repository
- Installs Docker CE, CLI, and containerd
- Enables and starts Docker service
- Verifies installation with hello-world

**Why fourth?** Applications (next steps) may need Docker.

### 05-configure-logging.sh
**Purpose:** Set up application logging with rotation

**What it does:**
- Creates log directory (`/var/log/myapp`)
- Sets permissions (appuser ownership)
- Configures logrotate for rotation policy
- Sets up daily rotation with 30-day retention

**Why last?** Final infrastructure piece before applications.

---

## Provisioner Methods Comparison

The module supports **three** provisioning approaches:

### 1. Multiple Scripts Directory (This Example)

```hcl
provisioner_scripts_dir = "${path.module}/scripts"
```

**✅ Best for:**
- Complex multi-phase provisioning
- Team collaboration (different scripts for different owners)
- Reusability (mix and match scripts across projects)
- Clear separation of concerns

**Example structure:**
```
scripts/
├── 01-base-system.sh      # By: DevOps team
├── 02-security.sh         # By: Security team
├── 03-monitoring.sh       # By: SRE team
├── 04-application.sh      # By: Dev team
└── 05-finalize.sh         # By: DevOps team
```

### 2. Single External Script

See [provisioner example](../provisioner)

```hcl
provisioner_script_path = "${path.module}/scripts/install.sh"
```

**✅ Best for:**
- Single-purpose provisioning (just Docker, just PostgreSQL)
- Simple linear workflows
- Small teams or solo projects

### 3. Inline Commands

See [basic example](../basic) or module documentation

```hcl
provisioner_commands = [
  "apt-get update",
  "apt-get install -y docker.io",
]
```

**✅ Best for:**
- Quick testing
- Very simple provisioning (1-5 commands)
- Proof of concepts

---

## Prerequisites

### 1. Proxmox Environment

- **Proxmox VE** 7.x or 8.x
- **Storage** named `nas` available
- **Network bridge** `vmbr0` configured
- **Static IP available**: `192.168.1.221/24`
- **LXC template**: Ubuntu 22.04

### 2. Local Tools

- **Terraform** >= 1.6.0 **OR OpenTofu** >= 1.6.0
- **direnv** for environment variable loading
- **SSH client** with key pair
- **Git** for cloning

### 3. Network Requirements

⚠️ **CRITICAL**: Static IP is **required** for provisioners!

```hcl
# ✅ CORRECT - Static IP
network_ip = "192.168.1.221/24"

# ❌ WRONG - DHCP won't work with provisioners
network_ip = "dhcp"
```

**Why?** Terraform needs to know the SSH host **before** applying. DHCP assigns IPs dynamically.

---

## Quick Start

### Step 1: Setup Environment

```bash
# Navigate to example directory
cd examples/provisioner-multi-scripts

# Copy environment configuration
cp .env.example .env

# Edit with your Proxmox credentials
nano .env  # or vim .env

# Allow direnv to load variables
direnv allow .
```

### Step 2: Generate SSH Keys (if not exists)

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "proxmox-multi-scripts" -f ~/.ssh/id_rsa -N ""

# Verify keys
ls -la ~/.ssh/id_rsa*
```

### Step 3: Download LXC Template

```bash
# SSH into Proxmox host
ssh root@proxmox-host

# Update template list
pveam update

# Download Ubuntu 22.04 template
pveam download nas ubuntu-22.04-standard_22.04-1_amd64.tar.zst

# Verify
pveam list nas | grep ubuntu-22.04
```

### Step 4: Review Scripts

Before applying, understand what will be executed:

```bash
# List all scripts
ls -l scripts/
# Output:
# 01-system-update.sh
# 02-configure-timezone.sh
# 03-create-user.sh
# 04-install-docker.sh
# 05-configure-logging.sh

# Review each script
cat scripts/01-system-update.sh
cat scripts/02-configure-timezone.sh
# ... and so on
```

### Step 5: Customize Configuration

Edit `main.tf` to match your environment:

```hcl
module "lxc_with_multi_scripts" {
  source = "../.."

  # Update these:
  hostname    = "your-container-name"
  target_node = "pve01"                           # Your node
  ostemplate  = "nas:vztmpl/ubuntu-22.04..."      # Your template

  # Update network:
  network_ip      = "192.168.1.221/24"            # Available IP
  network_gateway = "192.168.1.1"                 # Your gateway

  # Update SSH key:
  ssh_public_keys = file("~/.ssh/id_rsa.pub")

  # Provisioner configuration:
  provisioner_enabled         = true
  provisioner_ssh_user        = "root"
  provisioner_ssh_private_key = "~/.ssh/id_rsa"
  provisioner_scripts_dir     = "${path.module}/scripts"
  provisioner_timeout         = "10m"             # Increased for multiple scripts
}
```

### Step 6: Verify Static IP

```bash
# Ping the IP - should NOT respond
ping -c 3 192.168.1.221
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
module.lxc_with_multi_scripts.proxmox_lxc.this: Creating...
module.lxc_with_multi_scripts.proxmox_lxc.this: Creation complete after 25s

module.lxc_with_multi_scripts.null_resource.provisioner[0]: Creating...
module.lxc_with_multi_scripts.null_resource.provisioner[0]: Provisioning with 'remote-exec'...
module.lxc_with_multi_scripts.null_resource.provisioner[0]: Connected!

============================================================
Executing script: 01-system-update.sh
============================================================
Reading package lists...
Building dependency tree...
Upgrading packages...
Installing utilities...
Done!

============================================================
Executing script: 02-configure-timezone.sh
============================================================
Current time: 2024-01-15 14:30:00 -03
Timezone set: America/Sao_Paulo
NTP sync enabled
Done!

============================================================
Executing script: 03-create-user.sh
============================================================
Created group: appgroup (GID: 1001)
Created user: appuser (UID: 1001)
Home directory: /opt/appuser
Done!

============================================================
Executing script: 04-install-docker.sh
============================================================
Adding Docker repository...
Installing Docker CE...
Docker version 24.0.7, build afdd53b
Docker is running
Hello from Docker!
Done!

============================================================
Executing script: 05-configure-logging.sh
============================================================
Created log directory: /var/log/myapp
Configured logrotate
Log retention: 30 days
Done!

module.lxc_with_multi_scripts.null_resource.provisioner[0]: Creation complete after 2m15s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

container_hostname = "lxc-multi-scripts-demo"
container_id = "pve01/lxc/401"
container_ip = "192.168.1.221"
container_vmid = 401
```

**Typical timing:**
- Container creation: 20-30 seconds
- Script 01 (updates): 30-60 seconds
- Script 02 (timezone): 5-10 seconds
- Script 03 (user): 2-3 seconds
- Script 04 (Docker): 30-60 seconds
- Script 05 (logging): 2-3 seconds
- **Total**: ~2-3 minutes

---

## Accessing the Container

### SSH Access

```bash
# SSH using the configured key
ssh root@192.168.1.221

# Or explicitly specify key
ssh -i ~/.ssh/id_rsa root@192.168.1.221
```

### Verify All Provisioning Steps

```bash
# SSH into container
ssh root@192.168.1.221

# 1. Check system packages (from script 01)
which curl wget vim git htop
# All should be found

# 2. Check timezone (from script 02)
timedatectl
# Output should show: Time zone: America/Sao_Paulo

# Check NTP sync
systemctl status systemd-timesyncd
# Should be: active (running)

# 3. Check user creation (from script 03)
id appuser
# Output: uid=1001(appuser) gid=1001(appgroup) groups=1001(appgroup)

ls -ld /opt/appuser
# Output: drwxr-xr-x 2 appuser appgroup ... /opt/appuser

# 4. Check Docker (from script 04)
docker --version
# Output: Docker version 24.0.x

systemctl status docker
# Should be: active (running)

docker run hello-world
# Should print: Hello from Docker!

# 5. Check logging (from script 05)
ls -ld /var/log/myapp
# Output: drwxr-xr-x 2 appuser appuser ... /var/log/myapp

cat /etc/logrotate.d/myapp
# Should show rotation config

# Test logging
echo "Test log entry" > /var/log/myapp/app.log
ls -l /var/log/myapp/
# Should show app.log owned by appuser
```

### Test Docker Installation

```bash
# SSH into container
ssh root@192.168.1.221

# Run nginx container
docker run -d -p 80:80 --name web nginx

# Check from your machine
curl http://192.168.1.221
# Should return nginx welcome page

# Check logs
docker logs web

# Stop and remove
docker stop web && docker rm web
```

---

## Understanding Script Execution

### How Scripts Are Discovered

```hcl
provisioner_scripts_dir = "${path.module}/scripts"
```

**Module behavior:**
1. Reads all `.sh` files from the directory
2. Sorts filenames lexicographically (alphabetically)
3. Concatenates all scripts with headers
4. Executes as single SSH session

### Change Detection

The module uses **MD5 hash** of all scripts combined:

```hcl
triggers = {
  scripts = md5(join("\n", [for f in fileset(var.provisioner_scripts_dir, "*.sh") :
    file("${var.provisioner_scripts_dir}/${f}")
  ]))
}
```

**What this means:**
- Modifying **any** script triggers re-provisioning
- Adding a new script triggers re-provisioning
- Removing a script triggers re-provisioning
- Renaming a script (changing order) triggers re-provisioning

### Script Headers

Each script executes with a debug header:

```bash
============================================================
Executing script: 01-system-update.sh
============================================================
<script output here>
```

This helps identify which script is running during long provisioning.

---

## Customizing Scripts

### Adding a New Script

```bash
# Create new script (will execute between 04 and 05)
cat > scripts/04.5-install-postgresql.sh <<'EOF'
#!/bin/bash
set -euo pipefail

echo "Installing PostgreSQL..."
apt-get install -y postgresql postgresql-contrib

systemctl enable postgresql
systemctl start postgresql

echo "PostgreSQL installed successfully!"
EOF

# Make executable
chmod +x scripts/04.5-install-postgresql.sh

# Apply (provisioner will re-run)
terraform apply
```

**Execution order after adding:**
```
01-system-update.sh
02-configure-timezone.sh
03-create-user.sh
04-install-docker.sh
04.5-install-postgresql.sh    ← NEW
05-configure-logging.sh
```

### Modifying an Existing Script

```bash
# Edit timezone script to use different timezone
nano scripts/02-configure-timezone.sh

# Change:
TIMEZONE="America/Sao_Paulo"
# To:
TIMEZONE="America/New_York"

# Save and apply
terraform apply

# Provisioner detects MD5 change and re-runs ALL scripts
```

### Removing a Script

```bash
# Remove user creation script
rm scripts/03-create-user.sh

# Apply
terraform apply

# All remaining scripts re-run (without 03)
```

### Best Practices for Scripts

1. **Error Handling**
   ```bash
   #!/bin/bash
   set -euo pipefail  # Exit on error, undefined vars, pipe failures
   ```

2. **Idempotency** - Scripts should be safe to run multiple times
   ```bash
   # Check before creating
   if ! id -u appuser > /dev/null 2>&1; then
       useradd -r -s /bin/bash appuser
   fi
   ```

3. **Clear Output**
   ```bash
   echo "Installing Docker..."
   # ... commands ...
   echo "Docker installed successfully!"
   ```

4. **Minimal Dependencies** - Don't assume previous scripts succeeded
   ```bash
   # Install prerequisites within the script
   apt-get install -y curl
   ```

5. **Variables at Top**
   ```bash
   #!/bin/bash
   set -euo pipefail

   # Configuration
   TIMEZONE="America/Sao_Paulo"
   USERNAME="appuser"

   # Script logic below
   ```

---

## Common Use Cases

### Web Application Stack

```
scripts/
├── 01-system-update.sh           # Base packages
├── 02-security-hardening.sh      # Firewall, fail2ban
├── 03-install-nginx.sh           # Web server
├── 04-install-nodejs.sh          # Runtime
├── 05-deploy-application.sh      # App code
└── 06-configure-monitoring.sh    # Logging, metrics
```

### Database Server

```
scripts/
├── 01-system-update.sh           # Base packages
├── 02-configure-storage.sh       # Optimize filesystem
├── 03-install-postgresql.sh      # Database
├── 04-configure-postgresql.sh    # Tuning, users
└── 05-setup-backup.sh            # Backup scripts
```

### Development Environment

```
scripts/
├── 01-system-update.sh           # Base packages
├── 02-install-docker.sh          # Docker
├── 03-install-devtools.sh        # Git, vim, tmux
├── 04-configure-shell.sh         # Bash/zsh customization
└── 05-clone-repos.sh             # Clone project repos
```

### CI/CD Runner

```
scripts/
├── 01-system-update.sh           # Base packages
├── 02-install-docker.sh          # Docker for builds
├── 03-install-buildtools.sh      # gcc, make, etc.
├── 04-install-runner.sh          # GitLab/GitHub runner
└── 05-configure-runner.sh        # Register with CI server
```

---

## Troubleshooting

### 1. Script Fails in the Middle

**Scenario:** Script 03 fails, scripts 04-05 don't execute

**Error:**
```
============================================================
Executing script: 03-create-user.sh
============================================================
useradd: user 'appuser' already exists
Error: remote-exec provisioner error
```

**Solution:**

```bash
# Make script idempotent
nano scripts/03-create-user.sh

# Change from:
useradd -r -s /bin/bash appuser

# To:
if ! id -u appuser > /dev/null 2>&1; then
    useradd -r -s /bin/bash appuser
fi

# Apply again
terraform apply
```

### 2. Scripts Execute Out of Order

**Problem:** Docker installs before system update

**Cause:** Incorrect naming (1-, 2- instead of 01-, 02-)

**Solution:**

```bash
# Rename scripts with double digits
mv scripts/1-update.sh scripts/01-update.sh
mv scripts/2-timezone.sh scripts/02-timezone.sh
mv scripts/10-docker.sh scripts/03-docker.sh  # Now comes after 02

# Verify order
ls scripts/
# Should show: 01-update.sh, 02-timezone.sh, 03-docker.sh

terraform apply
```

### 3. One Script Changed, All Re-run

**Problem:** Modified one script but all 5 re-executed

**Explanation:** This is **expected behavior**!

The provisioner uses MD5 hash of **all scripts combined**. Any change to any script triggers full re-provisioning.

**Why?** Scripts may depend on each other. Re-running all ensures consistency.

**Alternative:** Use separate modules for independent provisioning:

```hcl
# Module for base system (scripts 01-03)
module "lxc_base" {
  source = "../.."
  provisioner_scripts_dir = "${path.module}/scripts/base"
}

# Module for applications (scripts 04-05)
# Will only re-run when application scripts change
module "lxc_apps" {
  source = "../.."
  depends_on = [module.lxc_base]
  provisioner_scripts_dir = "${path.module}/scripts/apps"
}
```

### 4. Script Times Out

**Error:**
```
Error: timeout while waiting for remote-exec provisioner
```

**Causes:**
- Script takes too long (default timeout: 5m)
- Script waits for user input
- Network issues during package download

**Solutions:**

```hcl
# Increase timeout in main.tf
provisioner_timeout = "15m"  # For slow package downloads

# Apply again
terraform apply
```

```bash
# Check script for interactive prompts
grep -r "read " scripts/
# Remove any user input requirements

# Use -y flag for all apt commands
apt-get install -y docker-ce
```

### 5. Permission Denied on Scripts

**Error:**
```
Error: Failed to read file: scripts/01-system-update.sh: permission denied
```

**Solution:**

```bash
# Make all scripts executable
chmod +x scripts/*.sh

# Verify
ls -l scripts/
# All should have: -rwxr-xr-x

terraform apply
```

### 6. Script Not Found

**Error:**
```
No *.sh files found in: /path/to/scripts
```

**Causes:**
- Scripts directory doesn't exist
- No `.sh` files in directory
- Path is incorrect

**Solutions:**

```bash
# Verify directory exists
ls -la scripts/

# Verify .sh files exist
ls -la scripts/*.sh

# Check path in main.tf
provisioner_scripts_dir = "${path.module}/scripts"  # Correct?
```

---

## Testing Scripts Independently

Before applying, test scripts manually:

### Test Individual Script

```bash
# SSH into container
ssh root@192.168.1.221

# Copy script
exit
scp scripts/04-install-docker.sh root@192.168.1.221:/tmp/

# SSH back and test
ssh root@192.168.1.221
bash -x /tmp/04-install-docker.sh  # Debug mode

# If successful, script is ready for Terraform
```

### Test All Scripts in Order

```bash
# Copy all scripts
scp scripts/*.sh root@192.168.1.221:/tmp/

# SSH and execute in order
ssh root@192.168.1.221
cd /tmp
for script in $(ls *.sh | sort); do
    echo "============================================================"
    echo "Executing: $script"
    echo "============================================================"
    bash -euo pipefail "$script"
done
```

### Dry-Run Scripts

Add dry-run mode to your scripts:

```bash
#!/bin/bash
set -euo pipefail

DRY_RUN=${DRY_RUN:-false}

if [ "$DRY_RUN" = "true" ]; then
    echo "[DRY RUN] Would install Docker"
else
    apt-get install -y docker-ce
fi
```

```bash
# Test without making changes
ssh root@192.168.1.221 "DRY_RUN=true bash" < scripts/04-install-docker.sh
```

---

## Cleanup

```bash
# Destroy container and provisioner
terraform destroy  # or: tofu destroy

# Type 'yes' when prompted
```

**What gets deleted:**
- ✅ Container (VMID 401)
- ✅ Container disk
- ✅ Provisioner resource

**What remains:**
- ❌ Scripts (local files)
- ❌ SSH keys
- ❌ LXC template

---

## Next Steps

### Explore Other Examples

- **[Basic Example](../basic)** - Simple DHCP container (no provisioning)
- **[Provisioner Example](../provisioner)** - Single external script
- **[Advanced Example](../advanced)** - All features, production-ready
- **[Hookscript Example](../hookscript)** - Proxmox host-side execution

### Extend This Example

Create your own script collection:

```bash
# Create scripts directory structure
mkdir -p scripts/{base,security,apps}

# Base system scripts
scripts/base/
├── 01-system-update.sh
├── 02-configure-timezone.sh
└── 03-install-utilities.sh

# Security scripts
scripts/security/
├── 10-configure-firewall.sh
├── 11-install-fail2ban.sh
└── 12-harden-ssh.sh

# Application scripts
scripts/apps/
├── 20-install-nginx.sh
├── 21-install-nodejs.sh
└── 22-deploy-app.sh

# Use in main.tf
provisioner_scripts_dir = "${path.module}/scripts/base"
# Or combine all:
provisioner_scripts_dir = "${path.module}/scripts"
```

### Production Checklist

Before using in production:

- [ ] All scripts have error handling (`set -euo pipefail`)
- [ ] Scripts are idempotent (safe to run multiple times)
- [ ] Scripts have clear output messages
- [ ] Numeric prefixes ensure correct order
- [ ] All scripts are executable (`chmod +x`)
- [ ] Scripts tested independently before Terraform
- [ ] Timeout configured appropriately
- [ ] No interactive prompts in scripts
- [ ] Sensitive data handled securely (not hardcoded)
- [ ] Scripts documented (comments, README)
- [ ] Scripts version controlled in Git
- [ ] Team members understand ordering and dependencies

---

## Additional Resources

### Documentation

- [Terraform remote-exec Provisioner](https://www.terraform.io/docs/provisioners/remote-exec.html)
- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc)
- [Bash Best Practices](https://www.gnu.org/software/bash/manual/)
- [Shell Script Idempotency](https://en.wikipedia.org/wiki/Idempotence)

### Module Files

- [Module README](../../README.md)
- [Provisioner Variables](../../variables.tf#L650-L750)
- [Module Outputs](../../outputs.tf)

### Community

- [Terraform Discussions](https://discuss.hashicorp.com/c/terraform-core)
- [Proxmox Forum](https://forum.proxmox.com/)
- [OpenTofu Community](https://opentofu.org/community)

---

## Summary

This example demonstrates:

✅ **Multiple modular scripts** for organized provisioning
✅ **Controlled execution order** via numeric prefixes
✅ **Modular approach** - system, user, Docker, logging separated
✅ **Clear debugging** with script execution headers
✅ **Change detection** via combined MD5 hash
✅ **Reusable components** across projects
✅ **Team collaboration** - different owners for different scripts
✅ **Production-ready** approach to complex provisioning

Use this as a template for your multi-phase LXC container configuration! 🚀
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.2-rc07 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lxc_with_multi_scripts"></a> [lxc\_with\_multi\_scripts](#module\_lxc\_with\_multi\_scripts) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_check_logs"></a> [check\_logs](#output\_check\_logs) | Command to check application logs configuration |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Container VMID |
| <a name="output_container_ip"></a> [container\_ip](#output\_container\_ip) | Container IP address |
| <a name="output_docker_test_command"></a> [docker\_test\_command](#output\_docker\_test\_command) | Command to test Docker installation |
| <a name="output_scripts_executed"></a> [scripts\_executed](#output\_scripts\_executed) | Scripts that were executed in order |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | SSH command for container |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

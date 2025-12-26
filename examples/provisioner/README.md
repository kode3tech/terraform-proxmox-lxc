# Provisioner Example - Single External Script

This example demonstrates how to use the **remote-exec provisioner** to automatically configure LXC containers after creation using a **single external shell script**.

## OpenTofu Compatibility

**This module is fully compatible with OpenTofu!**

All `terraform` commands in this guide can be replaced with `tofu`:

```bash
# Using Terraform
terraform init && terraform apply

# Using OpenTofu
tofu init && tofu apply
```

## What This Example Creates

- **LXC container** with static IP (192.168.1.220/24)
- **Docker installed** automatically via external script
- **SSH key authentication** configured
- **Nested virtualization** enabled (required for Docker)
- **Automatic provisioning** on first boot

## What is remote-exec Provisioner?

The `remote-exec` provisioner executes commands **inside the container** via SSH after it's created. This is different from hookscripts:

| Feature | Provisioner (remote-exec) | Hookscript |
|---------|---------------------------|------------|
| **Execution location** | Inside container (via SSH) | Proxmox host |
| **Manual upload required** | No (embedded in Terraform) | Yes (upload to Proxmox) |
| **When executes** | Once after creation | Every lifecycle event |
| **Access to container** | Via SSH | Via `pct exec` |
| **Language** | Any (bash, python, etc.) | Perl only |
| **Network required** | Yes (static IP) | No |
| **Best for** | Initial configuration | Lifecycle management |

## Provisioner Methods Comparison

This module supports **three** provisioning methods:

### 1. External Script (This Example)

```hcl
provisioner_script_path = "${path.module}/scripts/install-docker.sh"
```

**Best for:**
- Complex multi-step installations
- Reusable scripts across projects
- Better maintainability and version control
- Clear separation of infrastructure and configuration logic

**Example use cases:**
- Installing Docker
- Setting up web servers
- Configuring databases
- Creating users and permissions

### 2. Multiple Scripts Directory

See [provisioner-multi-scripts example](../provisioner-multi-scripts)

```hcl
provisioner_scripts_dir = "${path.module}/scripts"
```

**Best for:**
- Modular provisioning with multiple logical steps
- Ordered execution (01-, 02-, 03- prefixes)
- Team collaboration (different scripts for different tasks)
- Mixing system setup, application install, and configuration

**Example use cases:**
- System update → timezone → users → Docker → logging
- Base packages → security → monitoring → application
- Ordered multi-tier setup

### 3. Inline Commands

See [basic example](../basic) or module documentation

```hcl
provisioner_commands = [
  "apt-get update",
  "apt-get install -y curl",
]
```

**Best for:**
- Simple one-liners
- Quick testing
- Minimal configuration

---

## Prerequisites

### 1. Proxmox Environment

- **Proxmox VE** 7.x or 8.x
- **Storage** named `nas` available
- **Network bridge** `vmbr0` configured
- **Static IP available**: `192.168.1.220/24`
- **LXC template**: Ubuntu 22.04

### 2. Local Tools

- **Terraform** >= 1.6.0 **OR OpenTofu** >= 1.6.0
- **direnv** for environment variable loading
- **SSH client** with key pair
- **Git** for cloning

### 3. Network Requirements

WARNING: **CRITICAL**: Static IP is **required** for provisioners!

```hcl
# CORRECT - Static IP
network_ip = "192.168.1.220/24"

# WRONG - DHCP won't work with provisioners
network_ip = "dhcp"
```

**Why?** Terraform needs to know the SSH host **before** applying. DHCP assigns IPs dynamically, making this impossible.

**For DHCP examples**, see the [basic example](../basic) without provisioners.

---

## Quick Start

### Step 1: Setup Environment

```bash
# Navigate to example directory
cd examples/provisioner

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
ssh-keygen -t ed25519 -C "proxmox-provisioner" -f ~/.ssh/id_rsa -N ""

# Verify keys
ls -la ~/.ssh/id_rsa*
# Should show:
# ~/.ssh/id_rsa (private key)
# ~/.ssh/id_rsa.pub (public key)
```

**Using existing keys?** Just ensure the paths in `main.tf` match your key locations.

### Step 3: Download LXC Template

```bash
# SSH into Proxmox host
ssh root@proxmox-host

# Update template list
pveam update

# Download Ubuntu 22.04 template
pveam download nas ubuntu-22.04-standard_22.04-1_amd64.tar.zst

# Verify template
pveam list nas | grep ubuntu-22.04
```

### Step 4: Verify Static IP Availability

```bash
# Ping the IP - should NOT respond
ping -c 3 192.168.1.220

# If it responds, choose a different IP or remove the conflict
```

### Step 5: Review the Provisioning Script

This example uses an **external script** for better maintainability:

```bash
# View the Docker installation script
cat scripts/install-docker.sh
```

**What the script does:**
1. Updates package lists
2. Installs prerequisites
3. Adds Docker's official GPG key
4. Adds Docker repository
5. Installs Docker CE
6. Starts and enables Docker service
7. Verifies installation
8. Runs hello-world container

### Step 6: Customize Configuration

Edit `main.tf` to match your environment:

```hcl
module "lxc_with_script" {
  source = "../.."

  # Update these:
  hostname    = "your-container-name"
  target_node = "pve01"              # Your Proxmox node
  ostemplate  = "nas:vztmpl/ubuntu-22.04..."  # Your template path

  # Update network:
  network_ip      = "192.168.1.220/24"  # Available static IP
  network_gateway = "192.168.1.1"        # Your gateway

  # Update SSH key:
  ssh_public_keys = file("~/.ssh/id_rsa.pub")  # Your public key

  # Provisioner configuration:
  provisioner_enabled         = true
  provisioner_ssh_user        = "root"
  provisioner_ssh_private_key = "~/.ssh/id_rsa"  # Your private key
  provisioner_script_path     = "${path.module}/scripts/install-docker.sh"
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

# Watch the provisioner output
```

**Expected Output:**

```
module.lxc_with_script.proxmox_lxc.this: Creating...
module.lxc_with_script.proxmox_lxc.this: Still creating... [10s elapsed]
module.lxc_with_script.proxmox_lxc.this: Creation complete after 25s

module.lxc_with_script.null_resource.provisioner[0]: Creating...
module.lxc_with_script.null_resource.provisioner[0]: Provisioning with 'remote-exec'...
module.lxc_with_script.null_resource.provisioner[0]: Connecting to remote host via SSH...
module.lxc_with_script.null_resource.provisioner[0]: Connected!
module.lxc_with_script.null_resource.provisioner[0]: Reading package lists...
module.lxc_with_script.null_resource.provisioner[0]: Installing Docker...
module.lxc_with_script.null_resource.provisioner[0]: Docker installed successfully!
module.lxc_with_script.null_resource.provisioner[0]: Creation complete after 45s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

container_hostname = "lxc-script-demo"
container_id = "pve01/lxc/400"
container_ip = "192.168.1.220"
container_vmid = 400
```

**Typical timing:**
- Container creation: 20-30 seconds
- Provisioner execution: 30-60 seconds
- **Total**: ~1-2 minutes

---

## Accessing the Container

### SSH Access

```bash
# SSH using the configured key
ssh root@192.168.1.220

# Or explicitly specify key
ssh -i ~/.ssh/id_rsa root@192.168.1.220
```

### Verify Docker Installation

```bash
# SSH into container
ssh root@192.168.1.220

# Check Docker version
docker --version
# Output: Docker version 24.0.x, build xxxxx

# Check Docker service
systemctl status docker
# Should be: active (running)

# Verify Docker works
docker run hello-world

# Test with a real container
docker run -d -p 80:80 nginx

# Check from your machine
curl http://192.168.1.220
# Should return nginx welcome page
```

### Verify System Configuration

```bash
# SSH into container
ssh root@192.168.1.220

# Check hostname
hostname
# Output: lxc-script-demo

# Check network
ip addr show eth0
ip route

# Check nested virtualization (required for Docker)
ls -l /dev/kvm  # Should exist if host supports it

# Check memory and CPU
free -h
nproc
```

---

## Understanding the Script

The provisioning script `scripts/install-docker.sh` follows best practices:

### Script Structure

```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Update system
apt-get update

# Install prerequisites
apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker
systemctl enable docker
systemctl start docker

# Verify installation
docker run hello-world
```

### Best Practices Used

1. **Error handling**: `set -euo pipefail`
2. **Idempotency**: Can run multiple times safely
3. **Official sources**: Uses Docker's official repository
4. **Verification**: Tests installation with hello-world
5. **Service management**: Enables Docker to start on boot

### Customizing the Script

You can modify `scripts/install-docker.sh` for your needs:

```bash
# Add user to docker group (no sudo needed)
usermod -aG docker yourusername

# Install Docker Compose
apt-get install -y docker-compose-plugin

# Pull common images
docker pull nginx
docker pull postgres
docker pull redis

# Set up firewall rules
ufw allow 80/tcp
ufw allow 443/tcp

# Configure Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
systemctl restart docker
```

---

## Provisioner Configuration Deep Dive

### SSH Authentication

The module supports SSH key authentication (recommended):

```hcl
# Public key - added to container during creation
ssh_public_keys = file("~/.ssh/id_rsa.pub")

# Private key - used by provisioner to connect
provisioner_ssh_private_key = "~/.ssh/id_rsa"  # File path (recommended)
# OR
provisioner_ssh_private_key = <<-EOT
<private key content here>
EOT  # Inline key (not recommended for security)
```

### Script Path

```hcl
provisioner_script_path = "${path.module}/scripts/install-docker.sh"
```

**Supported formats:**
- Relative path: `${path.module}/scripts/script.sh`
- Absolute path: `/path/to/script.sh`
- Home directory: `~/scripts/script.sh`

**Script requirements:**
- Must be executable (`chmod +x script.sh`)
- Must have shebang (`#!/bin/bash`)
- Should use `set -euo pipefail` for error handling

### Change Detection

The provisioner uses **MD5 hash** of the script content as trigger:

```hcl
triggers = {
  script_md5 = filemd5(var.provisioner_script_path)
}
```

**What this means:**
- If you modify the script, Terraform will re-run the provisioner
- If you run `terraform apply` without changes, provisioner is skipped
- Container recreation also re-runs the provisioner

**To force re-provisioning:**
```bash
# Option 1: Taint the provisioner resource
terraform taint 'module.lxc_with_script.null_resource.provisioner[0]'
terraform apply

# Option 2: Recreate the container
terraform taint 'module.lxc_with_script.proxmox_lxc.this'
terraform apply
```

---

## Making Changes

### Updating the Script

```bash
# Edit the provisioning script
nano scripts/install-docker.sh

# Add new steps, for example:
echo "Installing Docker Compose..."
apt-get install -y docker-compose-plugin

# Apply changes (provisioner will re-run)
terraform apply
```

**Terraform detects the change:**
```
module.lxc_with_script.null_resource.provisioner[0]: Refreshing state...

Terraform will perform the following actions:

  # module.lxc_with_script.null_resource.provisioner[0] must be replaced
-/+ resource "null_resource" "provisioner" {
      ~ triggers = {
          ~ "script_md5" = "abc123..." -> "def456..." # forces replacement
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

### Changing Container Configuration

Most container changes **don't** re-run the provisioner:

```hcl
# Edit main.tf
cores  = 8      # Increase CPUs
memory = 8192   # Increase RAM
```

```bash
# Apply (provisioner won't re-run)
terraform apply
```

**To re-provision after container changes:**
```bash
terraform taint 'module.lxc_with_script.null_resource.provisioner[0]'
terraform apply
```

### Testing Script Changes Manually

Before applying, test your script manually:

```bash
# Copy script to container
scp scripts/install-docker.sh root@192.168.1.220:/tmp/

# SSH and test
ssh root@192.168.1.220
bash -x /tmp/install-docker.sh  # Debug mode

# If successful, apply via Terraform
terraform apply
```

---

## Troubleshooting

### 1. Provisioner Connection Timeout

**Error:**
```
Error: timeout - last error: dial tcp 192.168.1.220:22: connect: no route to host
```

**Causes & Solutions:**

```bash
# Check container is running
ssh root@proxmox-host "pct status 400"

# Ping the container
ping 192.168.1.220

# Check SSH is running inside container
ssh root@proxmox-host "pct enter 400"
systemctl status sshd

# Check firewall on Proxmox host
ssh root@proxmox-host "iptables -L -n | grep 22"
```

### 2. SSH Permission Denied

**Error:**
```
Error: ssh: handshake failed: ssh: unable to authenticate
```

**Solutions:**

```bash
# Verify public key is in container
ssh root@proxmox-host "pct enter 400"
cat ~/.ssh/authorized_keys

# Verify private key matches public key
ssh-keygen -y -f ~/.ssh/id_rsa
# Compare output with ~/.ssh/id_rsa.pub

# Test SSH manually
ssh -i ~/.ssh/id_rsa root@192.168.1.220 -v
# Check output for authentication errors

# Verify private key path in main.tf
provisioner_ssh_private_key = "~/.ssh/id_rsa"  # Correct path?
```

### 3. Script Execution Fails

**Error:**
```
Error: remote-exec provisioner error
...
E: Unable to locate package docker-ce
```

**Solutions:**

```bash
# Test script manually first
ssh root@192.168.1.220 "bash -x" < scripts/install-docker.sh

# Check for typos in script
cat scripts/install-docker.sh

# Verify Ubuntu version compatibility
ssh root@192.168.1.220 "cat /etc/os-release"

# Check network connectivity inside container
ssh root@192.168.1.220
ping 8.8.8.8
curl -I https://download.docker.com
```

### 4. Container Has DHCP (Not Static IP)

**Error:**
```
Error: provisioner requires static IP, but network_ip is set to "dhcp"
```

**Solution:**

```hcl
# Change from DHCP to static IP in main.tf
network_ip = "192.168.1.220/24"  # Not "dhcp"
network_gateway = "192.168.1.1"

# Apply
terraform apply
```

**Why?** Provisioners need to know the SSH host before applying. DHCP assigns IPs dynamically.

### 5. Provisioner Runs on Every Apply

**Problem:**
```bash
terraform apply
# Provisioner re-runs every time, even without changes
```

**Cause:** Trigger not stable

**Solutions:**

```bash
# Check if script path is correct
file scripts/install-docker.sh

# Check if script is being modified externally
git status scripts/

# Check trigger in state
terraform show | grep -A 5 triggers

# If still occurring, check module version
terraform init -upgrade
```

### 6. Docker Not Working After Provisioning

**Error:**
```bash
ssh root@192.168.1.220
docker run hello-world
# docker: Cannot connect to the Docker daemon
```

**Solutions:**

```bash
# Check if nesting is enabled
ssh root@proxmox-host "pct config 400 | grep features"
# Should show: features: nesting=1

# If missing, enable nesting in main.tf:
features = {
  nesting = true
}

# Apply changes
terraform apply

# Restart container
ssh root@proxmox-host "pct reboot 400"

# Wait 30 seconds, then try Docker again
ssh root@192.168.1.220 "docker run hello-world"
```

---

## Comparison with Other Examples

### When to Use This Example

**Use external script when:**
- Installing complex software (Docker, Kubernetes, databases)
- Script is reusable across multiple projects
- Need version control and code review for provisioning logic
- Configuration has multiple steps
- Team collaboration on provisioning scripts

### When to Use Multi-Scripts Example

See [provisioner-multi-scripts](../provisioner-multi-scripts)

**Use multiple scripts when:**
- Provisioning has distinct logical phases
- Want to reuse individual scripts across projects
- Different team members maintain different parts
- Need clear separation of concerns (system, security, app)

**Example scenario:**
```
scripts/
├── 01-system-update.sh      # System updates
├── 02-security-hardening.sh # Security tools
├── 03-install-docker.sh     # Docker
├── 04-deploy-app.sh         # Application
└── 05-configure-monitoring.sh # Monitoring
```

### When to Use Inline Commands

See module documentation or [basic example](../basic)

**Use inline commands when:**
- Very simple provisioning (1-5 commands)
- Quick testing
- No reusability needed

**Example:**
```hcl
provisioner_commands = [
  "apt-get update && apt-get install -y curl",
  "curl -fsSL https://get.docker.com | sh",
]
```

---

## Cleanup

```bash
# Destroy container and provisioner
terraform destroy  # or: tofu destroy

# Type 'yes' when prompted
```

**What gets deleted:**
- Container (VMID 400)
- Container disk
- Provisioner resource

**What remains:**
- LXC template
- SSH keys
- Scripts (local files)

---

## Next Steps

### Explore Other Examples

- **[Basic Example](../basic)** - Simple DHCP container (no provisioning)
- **[Multi-Scripts Example](../provisioner-multi-scripts)** - Multiple ordered scripts
- **[Advanced Example](../advanced)** - All features, production-ready
- **[Hookscript Example](../hookscript)** - Proxmox host-side execution

### Extend This Example

```bash
# Create your own provisioning script
cp scripts/install-docker.sh scripts/install-kubernetes.sh

# Edit for Kubernetes
nano scripts/install-kubernetes.sh

# Update main.tf to use new script
provisioner_script_path = "${path.module}/scripts/install-kubernetes.sh"

# Apply
terraform apply
```

### Production Checklist

Before using in production:

- [ ] Test script manually before applying
- [ ] Add error handling (`set -euo pipefail`)
- [ ] Make script idempotent (can run multiple times)
- [ ] Document script purpose and requirements
- [ ] Version control your scripts
- [ ] Use variables for configurable values
- [ ] Add logging to script output
- [ ] Test provisioning on clean container
- [ ] Plan for script updates (taint/recreate strategy)
- [ ] Consider secrets management (vault, env vars)

---

## Additional Resources

### Documentation

- [Terraform remote-exec Provisioner](https://www.terraform.io/docs/provisioners/remote-exec.html)
- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc)
- [Docker Installation](https://docs.docker.com/engine/install/ubuntu/)
- [Bash Error Handling](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

### Module Files

- [Module README](../../README.md)
- [Provisioner Variables](../../variables.tf#L650-L750)
- [Module Outputs](../../outputs.tf)

### Community

- [Terraform Provisioners Discuss](https://discuss.hashicorp.com/c/terraform-core)
- [Proxmox Forum](https://forum.proxmox.com/)
- [OpenTofu Community](https://opentofu.org/community)

---

## Summary

This example demonstrates:

**Single external script** provisioning for maintainability
**SSH key authentication** for security
**Docker installation** as real-world use case
**Static IP requirement** for reliable SSH connection
**Change detection** via script MD5 hash
**Error handling** with proper script practices
**Production-ready** approach to container provisioning

Use this as a template for your automated LXC container configuration! 🚀
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
| <a name="module_lxc_with_script"></a> [lxc\_with\_script](#module\_lxc\_with\_script) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores allocated to container | `number` | `4` | no |
| <a name="input_description"></a> [description](#input\_description) | Container description | `string` | `"LXC container with Docker installed via external script"` | no |
| <a name="input_features_nesting"></a> [features\_nesting](#input\_features\_nesting) | Enable nested virtualization (required for Docker) | `bool` | `true` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname for the LXC container | `string` | `"lxc-script-demo"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of RAM allocated to container in MB | `number` | `4096` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to attach the container to | `string` | `"vmbr0"` | no |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Network gateway IP address | `string` | `"192.168.1.1"` | no |
| <a name="input_network_ip"></a> [network\_ip](#input\_network\_ip) | Static IP address with CIDR notation (required for provisioner) | `string` | `"192.168.1.220/24"` | no |
| <a name="input_onboot"></a> [onboot](#input\_onboot) | Start container automatically when host boots | `bool` | `true` | no |
| <a name="input_ostemplate"></a> [ostemplate](#input\_ostemplate) | OS template to use for the container | `string` | `"nas:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"` | no |
| <a name="input_password"></a> [password](#input\_password) | Root password for the container | `string` | `"YourSecurePassword123!"` | no |
| <a name="input_rootfs_size"></a> [rootfs\_size](#input\_rootfs\_size) | Size of the root filesystem | `string` | `"16G"` | no |
| <a name="input_rootfs_storage"></a> [rootfs\_storage](#input\_rootfs\_storage) | Storage pool for the root filesystem | `string` | `"nas"` | no |
| <a name="input_start"></a> [start](#input\_start) | Start container immediately after creation | `bool` | `true` | no |
| <a name="input_swap"></a> [swap](#input\_swap) | Amount of swap memory in MB | `number` | `2048` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for organization | `map(string)` | <pre>{<br>  "environment": "demo",<br>  "purpose": "provisioner-script",<br>  "stack": "docker"<br>}</pre> | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | Proxmox node name where the LXC container will be created | `string` | `"pve01"` | no |
| <a name="input_unprivileged"></a> [unprivileged](#input\_unprivileged) | Run container as unprivileged user | `bool` | `true` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | Unique container ID in Proxmox | `number` | `400` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_check_logs"></a> [check\_logs](#output\_check\_logs) | Command to check initialization logs |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Container VMID |
| <a name="output_container_ip"></a> [container\_ip](#output\_container\_ip) | Container IP address |
| <a name="output_docker_test_command"></a> [docker\_test\_command](#output\_docker\_test\_command) | Command to test Docker installation |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | SSH command for container |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

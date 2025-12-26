# Basic LXC Container Example

This example demonstrates how to create a basic LXC container on Proxmox VE using the `terraform-proxmox-lxc` module with minimal configuration.

## OpenTofu Compatibility

**This module is fully compatible with OpenTofu!**

OpenTofu is an open-source Terraform fork that maintains compatibility with Terraform configurations. You can use either tool interchangeably:

```bash
# Using Terraform
terraform init
terraform plan
terraform apply

# Using OpenTofu (just replace 'terraform' with 'tofu')
tofu init
tofu plan
tofu apply
```

**Throughout this documentation:**
- All `terraform` commands can be replaced with `tofu`
- Configuration syntax is identical
- Module behavior is the **OR OpenTofu** >= 1.6.0 installed
  - [Terraform Downloads](https://www.terraform.io/downloads)
  - [OpenTofu Downloads](https://opentofu.org/docs/intro/install/)
  - Both tools are fully compatible with this module

**Installation:**
- [Terraform Downloads](https://www.terraform.io/downloads)
- [OpenTofu Downloads](https://opentofu.org/docs/intro/install/)

## What This Example Creates

- Ubuntu 20.04 LXC container
- DHCP network configuration (automatic IP assignment)
- Password authentication for root user
- 8GB root filesystem on your specified storage
- Container starts automatically after creation

## Prerequisites

Before running this example, ensure you have:

### 1. Proxmox Environment

- **Proxmox VE** installed and running (tested with versions 7.x and 8.x)
- **Network access** to Proxmox web interface (default: `https://proxmox-host:8006`)
- **Storage available** for container creation
- **LXC template** downloaded (Ubuntu 20.04 in this example)

### 2. Local Tools

- **Terraform** >= 1.6.0 installed ([Download](https://www.terraform.io/downloads))
- **Git** for cloning the module repository
- **direnv** for automatic environment variable loading (optional but recommended)
- **SSH client** for accessing the container after creation

### 3. Proxmox Credentials

You'll need **ONE** of these authentication methods:

**Option A: API Token (Recommended)**
- API token with appropriate permissions
- More secure, granular permissions, no password exposure

**Option B: User/Password (Fallback)**
- Username and password with sufficient privileges
- Simpler setup, less secure

---

## Step-by-Step Setup Guide

### Step 1: Install Required Tools

#### Install Terraform or OpenTofu

**Choose ONE of the following:**

##### Option A: Terraform

```bash
# macOS (using Homebrew)
brew install terraform

# Linux (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform --version
```

##### Option B: OpenTofu (Terraform-compatible)

```bash
# macOS (using Homebrew)
brew install opentofu

# Linux (Ubuntu/Debian)
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm install-opentofu.sh

# Verify installation
tofu --version
```

**Note:** Throughout this guide, `terraform` commands can be replaced with `tofu` if using OpenTofu.

#### Install direnv (Optional but Recommended)

```bash
# macOS
brew install direnv

# Linux (Ubuntu/Debian)
sudo apt install direnv

# Add to your shell (choose your shell)
# For Zsh:
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

# For Bash:
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
direnv --version
```

---

### Step 2: Create Proxmox API Token

#### Via Proxmox Web UI (Easiest)

1. **Login** to Proxmox web interface: `https://your-proxmox-host:8006`

2. **Navigate** to: `Datacenter` > `Permissions` > `API Tokens`

3. **Click** `Add` button

4. **Configure** token:
   ```
   User: root@pam
   Token ID: terraform
   Privilege Separation: Unchecked (for simplicity)
   ```

5. **Copy** the generated secret immediately (shown only once!)
   ```
   Token ID: root@pam!terraform
   Secret: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

#### Via Proxmox CLI (Advanced)

```bash
# SSH into your Proxmox host
ssh root@proxmox-host

# Create API token for root user
pveum user token add root@pam terraform --privsep 0

# Output will show:
# ┌──────────────┬──────────────────────────────────────┐
# │ key          │ value                                │
# ╞══════════════╪══════════════════════════════════════╡
# │ full-tokenid │ root@pam!terraform                   │
# ├──────────────┼──────────────────────────────────────┤
# │ info         │ {"privsep":0}                        │
# ├──────────────┼──────────────────────────────────────┤
# │ value        │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx │
# └──────────────┴──────────────────────────────────────┘

# IMPORTANT: Copy the 'value' field - this is your secret!
```

---

### Step 3: Download LXC Template

The container needs an OS template to use as base. Download Ubuntu 20.04:

#### Via Proxmox Web UI

1. **Navigate** to: `Storage` (e.g., `local`) > `CT Templates`
2. **Click** `Templates` button
3. **Search** for: `ubuntu-20.04-standard`
4. **Download** the template
5. **Wait** for download to complete

#### Via Proxmox CLI

```bash
# SSH into your Proxmox host
ssh root@proxmox-host

# Update available templates list
pveam update

# List available Ubuntu templates
pveam available | grep ubuntu

# Download Ubuntu 20.04 template
pveam download local ubuntu-20.04-standard_20.04-1_amd64.tar.gz

# Verify download
pveam list local
```

**Note the storage location!** In this example, we use `nas` storage. Change `rootfs_storage` in `main.tf` to match your storage name (e.g., `local`, `local-lvm`, etc.).

---

### Step 4: Configure Environment Variables

#### Create .env File

```bash
# Navigate to the example directory
cd examples/basic

# Copy the example environment file
cp .env.example .env

# Edit with your favorite editor
nano .env
# or
vim .env
```

#### Fill in Your Proxmox Credentials

Edit `.env` with your actual values:

```bash
# =============================================================================
# PROXMOX API CONFIGURATION
# =============================================================================

# Your Proxmox host IP or hostname
PM_API_URL=https://192.168.1.100:8006/api2/json

# API Token authentication (RECOMMENDED)
PM_API_TOKEN_ID=root@pam!terraform
PM_API_TOKEN_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# TLS Configuration
# Set to 'true' for self-signed certificates (common in home labs)
# Set to 'false' in production with valid certificates
PM_TLS_INSECURE=true
```

**Important Notes:**

- Replace `192.168.1.100` with your Proxmox host IP
- Replace `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` with your actual token secret
- Never commit `.env` to git (already in `.gitignore`)
- Keep your token secret secure

#### Enable direnv

```bash
# Create .envrc file (already exists, just needs to be allowed)
direnv allow .

# You should see output like:
# direnv: loading ~/path/to/examples/basic/.envrc
# direnv: export +PM_API_TOKEN_ID +PM_API_TOKEN_SECRET +PM_API_URL +PM_TLS_INSECURE
```

**What just happened?**

- direnv detected `.envrc` file
- Loaded all variables from `.env`
- Made them available to Terraform
- Variables are **only** available in this directory (project isolation)

#### Verify Environment Variables

```bash
# Check if variables are loaded
env | grep PM_

# You should see:
# PM_API_URL=https://192.168.1.100:8006/api2/json
# PM_API_TOKEN_ID=root@pam!terraform
# PM_API_TOKEN_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# PM_TLS_INSECURE=true
```

---

### Step 5: Customize Container Configuration

Edit `main.tf` to match your environment:

```hcl
module "lxc_container" {
  source = "../.."

  # Change to match your environment
  hostname    = "my-test-container"  # Your desired hostname
  target_node = "pve01"               # Your Proxmox node name

  # Update storage name to match your Proxmox storage
  rootfs_storage = "local-lvm"        # Change 'nas' to your storage name

  # Update template location to match where you downloaded it
  ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  # Set a secure root password
  password = "ChangeMe123!"           # Use a strong password!

  # Network configuration (DHCP is simplest for testing)
  network_bridge = "vmbr0"
  network_ip     = "dhcp"
}
```

**Important Configuration Points:**

1. **target_node**: Must match your Proxmox node name
   ```bash
   # Check node name via Proxmox CLI:
   pvesh get /nodes
   ```

2. **rootfs_storage**: Must be a valid storage on your Proxmox
   ```bash
   # List available storage:
   pvesm status
   ```

3. **ostemplate**: Format is `storage:vztmpl/template-name`
   ```bash
   # List downloaded templates:
   pveam list local
   ```

4. **password**: Set a strong password for root access

---

### Step 6: Initialize Terraform

```bash
# Initialize Terraform (downloads providers)
terraform init

# Expected output:
# Initializing modules...
# Initializing the backend...
# Initializing provider plugins...
# - Finding telmate/proxmox versions matching "3.0.2-rc07"...
# - Installing telmate/proxmox v3.0.2-rc07...
# Terraform has been successfully initialized!
```

**What happened?**

- Downloaded Telmate Proxmox provider
- Initialized the module
- Created `.terraform` directory with provider binaries
- Created `.terraform.lock.hcl` file (dependency lock)

---

### Step 7: Plan the Deployment

```bash
# Generate execution plan
terraform plan

# Expected output:
# Terraform will perform the following actions:
#
#   # module.lxc_container.proxmox_lxc.this will be created
#   + resource "proxmox_lxc" "this" {
#       + arch         = "amd64"
#       + cores        = 1
#       + hostname     = "my-test-container"
#       + memory       = 512
#       + network_ip   = "dhcp"
#       + target_node  = "pve01"
#       ...
#     }
#
# Plan: 1 to add, 0 to change, 0 to destroy.
```

**Review the plan carefully!**

- Verify hostname is correct
- Check target node matches your Proxmox node
- Confirm storage and template paths are correct
- Ensure network configuration is as expected

---

### Step 8: Deploy the Container

```bash
# Apply the configuration
terraform apply

# Terraform will show the plan again and ask for confirmation:
# Do you want to perform these actions?
# Terraform will perform the actions described above.
# Only 'yes' will be accepted to approve.
#
# Enter a value: yes

# Expected output:
# module.lxc_container.proxmox_lxc.this: Creating...
# module.lxc_container.proxmox_lxc.this: Still creating... [10s elapsed]
# module.lxc_container.proxmox_lxc.this: Creation complete after 15s [id=pve01/lxc/100]
#
# Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
#
# Outputs:
# container_hostname = "my-test-container"
# container_id = "pve01/lxc/100"
# container_ip = "<dynamic>"
# container_vmid = "100"
```

**Congratulations! 🎉** Your container is now running on Proxmox!

---

## Accessing Your Container

### Method 1: Find the DHCP IP Address

Since we're using DHCP, you need to discover the assigned IP:

#### Via Proxmox Web UI

1. **Navigate** to your container in the left sidebar
2. **Click** on the container (e.g., `100 (my-test-container)`)
3. **View** the `Summary` tab
4. **Look** for `IP Address` field under Network section

#### Via Proxmox CLI

```bash
# SSH to Proxmox host
ssh root@proxmox-host

# Get IP address of container (replace 100 with your VMID)
pct exec 100 -- hostname -I

# Output example:
# 192.168.1.150

# Or check from host's perspective:
pct config 100 | grep net0
```

#### Via Terraform Output

```bash
# If the module exposes the IP (with static IP only):
terraform output container_ip

# Note: With DHCP, this will show "<dynamic>"
# You must use one of the methods above to find the actual IP
```

### Method 2: SSH into the Container

Once you have the IP address:

```bash
# SSH using root and the password you set
ssh root@192.168.1.150

# Enter the password when prompted
# You should see:
# Welcome to Ubuntu 20.04.x LTS ...
# root@my-test-container:~#
```

**Troubleshooting SSH:**

If SSH fails:

```bash
# 1. Verify container is running
ssh root@proxmox-host "pct status 100"
# Output should be: status: running

# 2. Verify network is configured
ssh root@proxmox-host "pct exec 100 -- ip addr"

# 3. Test ping
ping 192.168.1.150

# 4. Check SSH service in container
ssh root@proxmox-host "pct exec 100 -- systemctl status sshd"
```

### Method 3: Proxmox Console (No Network Required)

If you can't get SSH working:

```bash
# Via Proxmox CLI
ssh root@proxmox-host
pct enter 100

# Now you're inside the container
# root@my-test-container:~#

# Check IP address
hostname -I

# Exit the console
exit
```

---

## Verifying the Deployment

### Check Container Status

```bash
# Via Terraform
terraform show

# Via Proxmox CLI
ssh root@proxmox-host "pct list"

# Output example:
# VMID       Status     Lock         Name
# 100        running                 my-test-container
```

### Inspect Container Details

```bash
# Get full container configuration
ssh root@proxmox-host "pct config 100"

# Output shows:
# arch: amd64
# cores: 1
# hostname: my-test-container
# memory: 512
# net0: name=eth0,bridge=vmbr0,ip=dhcp
# ostype: ubuntu
# rootfs: nas:vm-100-disk-0,size=8G
# swap: 512
```

### Test Container Functionality

```bash
# SSH into the container
ssh root@192.168.1.150

# Update package lists
apt update

# Check system info
uname -a
cat /etc/os-release

# Check network
ip addr
ip route
ping -c 3 8.8.8.8

# Check disk space
df -h

# Exit
exit
```

---

## Making Changes

### Modify Container Resources

Edit `main.tf` to change resources:

```hcl
module "lxc_container" {
  source = "../.."

  # ... existing config ...

  # Uncomment and modify to change resources:
  cores  = 2     # Increase CPU cores
  memory = 1024  # Increase RAM to 1GB
  swap   = 1024  # Increase swap
}
```

Apply changes:

```bash
# Review changes
terraform plan

# Apply if everything looks good
terraform apply
```

**Warning:** Some changes may require container restart!

### Switch to Static IP

Edit `main.tf`:

```hcl
module "lxc_container" {
  source = "../.."

  # ... existing config ...

  # Change from DHCP to static IP
  network_ip      = "192.168.1.200/24"
  network_gateway = "192.168.1.1"
}
```

Apply changes:

```bash
terraform apply
```

---

## Cleanup

### Destroy the Container

```bash
# Destroy all resources
terraform destroy

# Terraform will ask for confirmation:
# Do you really want to destroy all resources?
# Terraform will destroy all your managed infrastructure, as shown above.
# There is no undo. Only 'yes' will be accepted to confirm.
#
# Enter a value: yes

# Expected output:
# module.lxc_container.proxmox_lxc.this: Destroying... [id=pve01/lxc/100]
# module.lxc_container.proxmox_lxc.this: Destruction complete after 5s
#
# Destroy complete! Resources: 1 destroyed.
```

**What gets deleted:**

- LXC container (VMID 100)
- Container disk (rootfs)
- All container data

**What remains:**

- Terraform state file (`terraform.tfstate`)
- Template (still available for reuse)
- Proxmox node and storage

---

## Troubleshooting

### Common Issues

#### 1. Authentication Failed

**Error:**
```
Error: error creating LXC: 401 Unauthorized
```

**Solution:**
```bash
# Verify environment variables are loaded
env | grep PM_

# Check token in Proxmox UI:
# Datacenter > Permissions > API Tokens

# Verify token has correct permissions

# Re-allow direnv
direnv allow .
```

#### 2. Template Not Found

**Error:**
```
Error: unable to find ostemplate
```

**Solution:**
```bash
# List available templates
ssh root@proxmox-host "pveam list local"

# Update ostemplate in main.tf to match exact name

# Or download template:
ssh root@proxmox-host "pveam download local ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
```

#### 3. Storage Not Found

**Error:**
```
Error: storage 'nas' does not exist
```

**Solution:**
```bash
# List available storage
ssh root@proxmox-host "pvesm status"

# Update rootfs_storage in main.tf to match your storage name
# Common names: local, local-lvm, nas, cephfs, etc.
```

#### 4. Node Not Found

**Error:**
```
Error: node 'pve01' does not exist
```

**Solution:**
```bash
# List cluster nodes
ssh root@proxmox-host "pvesh get /nodes"

# Update target_node in main.tf to match your node name
```

#### 5. Cannot SSH to Container

**Problem:** Container created but SSH fails

**Solution:**
```bash
# 1. Find the IP address
ssh root@proxmox-host "pct exec 100 -- hostname -I"

# 2. Verify SSH service is running
ssh root@proxmox-host "pct exec 100 -- systemctl status sshd"

# 3. Check if password is set correctly
# Access via console and reset password:
ssh root@proxmox-host "pct enter 100"
passwd root
exit

# 4. Try SSH again
ssh root@<container-ip>
```

#### 6. TLS Certificate Error

**Error:**
```
Error: x509: certificate signed by unknown authority
```

**Solution:**
```bash
# For self-signed certificates, set in .env:
PM_TLS_INSECURE=true

# Reload environment
direnv allow .

# Try again
terraform plan
```

---

## Next Steps

### Try Other Examples

Now that you have the basics working:

1. **[Advanced Example](../advanced)** - Multiple features, custom resources
2. **[Provisioner Example](../provisioner)** - Automatic software installation
3. **[Multi-Scripts Example](../provisioner-multi-scripts)** - Modular provisioning
4. **[Hookscript Example](../hookscript)** - Proxmox lifecycle hooks

### Production Considerations

Before using in production:

#### 1. Switch to SSH Keys

```hcl
# In main.tf, replace password with:
ssh_public_keys = file("~/.ssh/id_rsa.pub")
# And remove:
# password = "..."
```

#### 2. Use Static IP

```hcl
network_ip      = "192.168.1.200/24"
network_gateway = "192.168.1.1"
```

#### 3. Enable Backup

```hcl
# Add to main.tf:
onboot = true  # Start on host boot
```

#### 4. Add Resource Limits

```hcl
cores  = 2
memory = 2048
swap   = 2048
```

#### 5. Use Proper Secrets Management

Instead of `.env`, consider:
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- Environment variables in CI/CD

---

## Additional Resources

### Documentation

- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Linux_Container)
- [Terraform Documentation](https://www.terraform.io/docs)

### Module Repository

- [Module README](../../README.md)
- [Module Variables](../../variables.tf)
- [Module Outputs](../../outputs.tf)

### Community

- [Proxmox Forum](https://forum.proxmox.com/)
- [Terraform Discussions](https://discuss.hashicorp.com/c/terraform-core)

---

## Support

If you encounter issues:

1. Check this README's [Troubleshooting](#troubleshooting) section
2. Review Terraform plan output carefully
3. Check Proxmox logs: `/var/log/pve/`
4. Verify all prerequisites are met
5. Open an issue in the repository with:
   - Terraform version
   - Provider version
   - Error messages
   - Steps to reproduce

## Advanced Examples

### Static IP Configuration

Uncomment in `main.tf`:

```hcl
network_ip      = "192.168.1.100/24"
network_gateway = "192.168.1.1"
```

### Enable Docker Support

```hcl
features = {
  nesting = true
  fuse    = true
}
```

### SSH Access

```hcl
ssh_public_keys = <<-EOT
  ssh-rsa AAAAB3NzaC1yc2E... user@example.com
EOT
```

## Troubleshooting

| Error | Solution |
|-------|----------|
| `401 authentication failure` | Verify API token credentials |
| `template does not exist` | Download template with `pveam download` |
| `node 'pve' not found` | Update `target_node` to match your node name |

## References

- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Linux_Container)

---

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
| <a name="module_lxc_container"></a> [lxc\_container](#module\_lxc\_container) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname for the LXC container | `string` | `"app-dev-web-01"` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to attach the container to | `string` | `"vmbr0"` | no |
| <a name="input_network_ip"></a> [network\_ip](#input\_network\_ip) | IP address configuration (dhcp, manual, or CIDR notation) | `string` | `"dhcp"` | no |
| <a name="input_ostemplate"></a> [ostemplate](#input\_ostemplate) | OS template to use for the container (storage:vztmpl/template-name.tar.gz) | `string` | `"nas:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"` | no |
| <a name="input_root_password"></a> [root\_password](#input\_root\_password) | Root password for the container (use ssh\_public\_keys in production instead) | `string` | `"YourSecurePassword123!"` | no |
| <a name="input_rootfs_size"></a> [rootfs\_size](#input\_rootfs\_size) | Size of the root filesystem | `string` | `"8G"` | no |
| <a name="input_rootfs_storage"></a> [rootfs\_storage](#input\_rootfs\_storage) | Storage pool for the root filesystem | `string` | `"nas"` | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | Proxmox node name where the LXC container will be created | `string` | `"pve01"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_hostname"></a> [container\_hostname](#output\_container\_hostname) | Container hostname |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Container ID |
| <a name="output_container_ip"></a> [container\_ip](#output\_container\_ip) | Container IP address |
| <a name="output_container_vmid"></a> [container\_vmid](#output\_container\_vmid) | Container VMID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

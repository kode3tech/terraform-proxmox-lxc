# Testing Examples

This guide explains how to test each example in this repository.

## Prerequisites

### 1. Proxmox Environment

```bash
export PM_API_URL="https://your-proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pam!mytoken"
export PM_API_TOKEN_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export PM_TLS_INSECURE="true"  # Only if using self-signed certificate
```

### 2. Available Resources

Ensure your Proxmox environment has:
- **Storage:** A storage pool named `nas` (or update `rootfs_storage` variable)
- **Template:** Ubuntu 20.04/22.04 LXC template downloaded
- **Network:** Bridge `vmbr0` configured
- **IP Range:** Adjust network IPs in variables.tf to match your network

---

## Testing Each Example

### Basic Example

**Purpose:** Minimal configuration with DHCP networking.

```bash
cd examples/basic

# Customize variables (optional)
cat > terraform.tfvars <<EOF
target_node    = "pve01"          # Your Proxmox node name
hostname       = "test-basic-01"
ostemplate     = "nas:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
rootfs_storage = "nas"            # Your storage pool
network_bridge = "vmbr0"          # Your network bridge
EOF

# Test
terraform init
terraform plan
terraform apply -auto-approve

# Verify
# Since DHCP is used, find IP via Proxmox UI or:
# ssh root@proxmox-host "pct exec <vmid> -- hostname -I"

# Cleanup
terraform destroy -auto-approve
```

---

### Advanced Example

**Purpose:** Comprehensive configuration with all features enabled.

```bash
cd examples/advanced

# Customize variables
cat > terraform.tfvars <<EOF
target_node      = "pve01"
hostname         = "test-advanced-01"
ostemplate       = "nas:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
vmid             = 200
rootfs_storage   = "nas"
network_bridge   = "vmbr0"
network_ip       = "192.168.1.200/24"  # Adjust to your network
network_gateway  = "192.168.1.1"
EOF

# Test
terraform init
terraform plan
terraform apply -auto-approve

# Access
ssh root@192.168.1.200  # Use password: YourSecurePassword123!

# Cleanup
terraform destroy -auto-approve
```

**Note:** For production testing with SSH keys:
1. Generate SSH key pair if needed: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa`
2. Uncomment `ssh_public_keys` line in main.tf
3. Update to use your real key: `ssh_public_keys = file("~/.ssh/id_rsa.pub")`
4. Remove or comment the `password` line

---

### Provisioner Example

**Purpose:** Automated configuration via SSH with script execution.

**⚠️ IMPORTANT:** This example requires static IP (not DHCP) and SSH access.

#### Option 1: Testing WITHOUT Provisioner (Quick Test)

```bash
cd examples/provisioner

# Test container creation only (provisioner disabled by default)
terraform init
terraform apply -auto-approve

# Verify container is created and accessible
ssh root@192.168.1.220  # Password: YourSecurePassword123!

# Cleanup
terraform destroy -auto-approve
```

#### Option 2: Testing WITH Provisioner (Full Test)

```bash
cd examples/provisioner

# 1. Generate SSH key pair (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# 2. Edit main.tf - uncomment and enable provisioner:
# Line ~75: provisioner_enabled = true
# Line ~77: provisioner_ssh_user = "root"
# Line ~78: provisioner_ssh_private_key = file("~/.ssh/id_rsa")
# Line ~79: provisioner_script_path = "${path.module}/scripts/install-docker.sh"
# Line ~58: ssh_public_keys = file("~/.ssh/id_rsa.pub")

# 3. Verify network settings match your environment
cat > terraform.tfvars <<EOF
network_ip      = "192.168.1.220/24"  # Must be static, adjust to your network
network_gateway = "192.168.1.1"
EOF

# 4. Apply
terraform init
terraform apply -auto-approve

# 5. Verify provisioning worked
ssh -i ~/.ssh/id_rsa root@192.168.1.220
docker --version  # Should show Docker is installed

# 6. Cleanup
terraform destroy -auto-approve
```

---

### Provisioner Multi-Scripts Example

**Purpose:** Execute multiple ordered scripts during provisioning.

**Testing steps are identical to Provisioner Example**, but this one executes:
- 01-system-update.sh
- 02-configure-timezone.sh
- 03-create-user.sh
- 04-install-docker.sh
- 05-configure-logging.sh

```bash
cd examples/provisioner-multi-scripts

# Follow same steps as Provisioner Example
# Update network_ip to 192.168.1.221 (avoid conflicts)
```

---

### Hookscript Example

**Purpose:** Demonstrate lifecycle hooks with Proxmox hookscripts.

**Prerequisites:**
1. Upload hookscript to Proxmox:
```bash
scp examples/hookscript/hookscript.sh root@proxmox-host:/var/lib/vz/snippets/
ssh root@proxmox-host "chmod +x /var/lib/vz/snippets/hookscript.sh"
```

2. Ensure storage has snippets enabled:
```bash
ssh root@proxmox-host "pvesm set local --content vztmpl,iso,snippets"
```

**Testing:**
```bash
cd examples/hookscript

cat > terraform.tfvars <<EOF
target_node     = "pve01"
hookscript      = "local:snippets/hookscript.sh"
network_ip      = "192.168.1.210/24"
network_gateway = "192.168.1.1"
EOF

terraform init
terraform apply -auto-approve

# Check hookscript execution logs
ssh root@proxmox-host "cat /var/log/pve-hook-<vmid>.log"

terraform destroy -auto-approve
```

---

## Common Issues

### SSH Key Validation Error

**Error:** `SSH public key validation error`

**Cause:** Invalid or fake SSH public key.

**Solution:**
- Remove or comment `ssh_public_keys` line
- Use `password` for testing instead
- Or provide your real SSH public key: `file("~/.ssh/id_rsa.pub")`

### Storage Not Found

**Error:** `storage 'nas' does not exist`

**Solution:** Update `rootfs_storage` variable to match your storage pool name.

### Network Already in Use

**Error:** IP address already assigned.

**Solution:** Change `network_ip` in terraform.tfvars to an available IP in your network.

### Template Not Found

**Error:** `ostemplate 'nas:vztmpl/...' not found`

**Solution:**
1. Download template: `ssh root@proxmox-host "pveam download nas ubuntu-20.04-standard_20.04-1_amd64.tar.gz"`
2. Or update `ostemplate` variable to match an available template
3. List templates: `ssh root@proxmox-host "pveam list nas"`

---

## Best Practices for Testing

1. **Use terraform.tfvars:** Don't edit main.tf or variables.tf directly. Override values in terraform.tfvars.

2. **Test incrementally:**
   - Start with basic example
   - Progress to advanced
   - Test provisioner examples last

3. **Clean up:** Always run `terraform destroy` after testing to avoid resource conflicts.

4. **Network planning:** Use a dedicated test subnet or ensure IPs don't conflict with existing infrastructure.

5. **SSH keys:** Use dedicated test keys, never commit real keys to git.

6. **Documentation:** Update this file if you discover new issues or solutions.

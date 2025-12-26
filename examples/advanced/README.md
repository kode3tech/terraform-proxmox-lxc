# Advanced LXC Container Example

This example demonstrates a **comprehensive configuration** using most available features of the `terraform-proxmox-lxc` module. It serves as a reference for production-ready deployments and advanced use cases.

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

- ✅ **Production-grade LXC container** with custom VMID (200)
- ✅ **Docker-ready environment** with nested virtualization
- ✅ **Static IP configuration** (192.168.1.200/24)
- ✅ **Resource limits** (8 cores, 4GB RAM, custom CPU weights)
- ✅ **SSH key authentication** (secure, passwordless access)
- ✅ **Protection enabled** (prevents accidental deletion)
- ✅ **Auto-start on boot** with startup order
- ✅ **Resource pool assignment** for organization
- ✅ **Custom features** (nesting, FUSE, keyctl, NFS mounts)

## Features Demonstrated

### 🔧 Resource Allocation
- Custom VMID assignment (consistent IDs across environments)
- CPU cores (8), limits (4), and units (4096) configuration
- Memory (4096MB) and swap (2048MB) allocation
- Bandwidth limiting (10MB/s I/O)

### 💾 Storage
- Custom storage pool selection
- Root filesystem size (20GB)
- I/O bandwidth limiting

### 🌐 Networking
- **Static IPv4** configuration with gateway
- **IPv6 auto-configuration**
- MTU customization (1450)
- Rate limiting (1000 Mbps)
- VLAN support (commented example)
- Proxmox firewall integration

### 🚀 Advanced Features
- **Nested virtualization** (`nesting = true`) - Required for Docker/Podman
- **FUSE mounts** (`fuse = true`) - Required for SSHFS and similar
- **keyctl support** (`keyctl = true`) - Required for systemd features
- **Custom mount types** (`mount = "nfs;cifs"`) - NFS and CIFS mounts

### 🔐 Security & Access
- **SSH public key authentication** (no passwords)
- **Unprivileged container** (enhanced security)
- **Protection enabled** (prevents accidental `terraform destroy`)

### ⚡ High Availability
- **Startup order** configuration (automatic ordering on boot)
- **Resource pool** assignment (`production`)
- **HA state and group** (commented - requires cluster HA setup)

### 📋 Metadata
- Custom description with environment info
- Custom tags for organization and filtering

---

## Prerequisites

### 1. Proxmox Environment

- **Proxmox VE** 7.x or 8.x
- **Storage** named `nas` available (or modify `rootfs_storage`)
- **Network bridge** `vmbr0` configured
- **Static IP available**: `192.168.1.200/24` (or modify `network_ip`)
- **Resource pool** `production` created (or modify `pool`)
- **LXC template** downloaded: Ubuntu 20.04

### 2. Local Tools

- **Terraform** >= 1.6.0 **OR OpenTofu** >= 1.6.0
- **direnv** for automatic environment variable loading
- **SSH client** with public/private key pair
- **Git** for cloning the repository

### 3. Network Requirements

- **Available static IP** in your network range
- **Gateway** accessible at `192.168.1.1` (or modify)
- **DNS server** configured (defaults to Proxmox host)

---

## Quick Start

### Step 1: Setup Environment

```bash
# Navigate to example directory
cd examples/advanced

# Copy environment configuration
cp .env.example .env

# Edit with your Proxmox credentials
nano .env  # or vim .env

# Allow direnv to load variables
direnv allow .
```

### Step 2: Create Resource Pool (if not exists)

```bash
# Via Proxmox CLI
ssh root@proxmox-host "pvesh create /pools --poolid production --comment 'Production containers'"

# Or via Proxmox Web UI:
# Datacenter > Permissions > Pools > Create
```

### Step 3: Download LXC Template

```bash
# SSH into Proxmox host
ssh root@proxmox-host

# Update template list
pveam update

# Download Ubuntu 20.04 template
pveam download local ubuntu-20.04-standard_20.04-1_amd64.tar.gz

# Verify template location matches ostemplate in main.tf
pveam list nas  # or pveam list local
```

### Step 4: Generate SSH Keys (if not exists)

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "proxmox-lxc" -f ~/.ssh/proxmox_lxc -N ""

# Or use existing key
# Just ensure the public key path is correct in main.tf
```

### Step 5: Customize Configuration

Edit `main.tf` to match your environment:

```hcl
module "lxc_advanced" {
  source = "../.."

  # Update these values:
  hostname       = "your-container-name"    # Your desired hostname
  target_node    = "pve01"                  # Your Proxmox node name
  rootfs_storage = "local-lvm"              # Your storage name
  ostemplate     = "local:vztmpl/ubuntu-20.04..." # Your template path

  # Update network configuration:
  network_ip      = "192.168.1.200/24"      # Available IP in your network
  network_gateway = "192.168.1.1"           # Your network gateway

  # Update SSH key path:
  ssh_public_keys = file("~/.ssh/id_rsa.pub")  # Your public key

  # Update pool if different:
  pool = "production"  # Or your resource pool name
}
```

### Step 6: Verify Static IP Availability

```bash
# Ping the IP you want to assign - should NOT respond
ping 192.168.1.200

# If it responds, choose a different IP or remove the conflicting device
```

### Step 7: Deploy

```bash
# Initialize Terraform/OpenTofu
terraform init  # or: tofu init

# Review the execution plan
terraform plan  # or: tofu plan

# Apply the configuration
terraform apply  # or: tofu apply
# Type 'yes' when prompted

# Wait for creation (typically 20-30 seconds)
```

**Expected Output:**
```
module.lxc_advanced.proxmox_lxc.this: Creating...
module.lxc_advanced.proxmox_lxc.this: Still creating... [10s elapsed]
module.lxc_advanced.proxmox_lxc.this: Creation complete after 25s [id=pve01/lxc/200]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

container_hostname = "docker-prd-app-01"
container_id = "pve01/lxc/200"
container_ip = "192.168.1.200"
container_vmid = 200
```

---

## Accessing the Container

### SSH Access

```bash
# SSH using the static IP
ssh root@192.168.1.200

# Or using the configured key explicitly
ssh -i ~/.ssh/proxmox_lxc root@192.168.1.200

# Add to ~/.ssh/config for convenience:
cat >> ~/.ssh/config <<EOF
Host docker-container
  HostName 192.168.1.200
  User root
  IdentityFile ~/.ssh/proxmox_lxc
EOF

# Then simply:
ssh docker-container
```

### Verify Container Features

```bash
# SSH into container
ssh root@192.168.1.200

# Check hostname
hostname
# Output: docker-prd-app-01

# Check network configuration
ip addr show eth0
ip route

# Test DNS
dig google.com

# Check IPv6 (if available on your network)
ip -6 addr show eth0

# Verify CPU allocation
nproc
lscpu

# Check memory
free -h

# Check disk space
df -h

# Verify nested virtualization (required for Docker)
cat /proc/cpuinfo | grep vmx  # For Intel
cat /proc/cpuinfo | grep svm  # For AMD

# Or check if KVM is available
ls -l /dev/kvm
```

---

## Installing Docker

This container is configured with `nesting = true`, making it Docker-ready:

```bash
# SSH into container
ssh root@192.168.1.200

# Install Docker
curl -fsSL https://get.docker.com | sh

# Start Docker service
systemctl start docker
systemctl enable docker

# Verify Docker works
docker run hello-world

# Test with a real container
docker run -d -p 80:80 nginx

# Check from your machine
curl http://192.168.1.200
```

---

## Configuration Deep Dive

### Resource Limits Explained

```hcl
cores    = 8      # Container can use UP TO 8 CPU cores
cpulimit = 4      # Container limited to 4 cores worth of CPU time
cpuunits = 4096   # 4x normal CPU priority (default is 1024)
memory   = 4096   # 4GB RAM
swap     = 2048   # 2GB swap
```

**What this means:**
- Container sees 8 cores but can only consume 4 cores of CPU time
- If another container needs CPU, this one gets 4x priority
- Useful for production workloads that need guaranteed performance

### Network Configuration

```hcl
network_bridge = "vmbr0"                    # Physical bridge
network_ip     = "192.168.1.200/24"         # Static IPv4
network_gateway = "192.168.1.1"             # IPv4 gateway
network_ip6    = "auto"                     # IPv6 SLAAC
network_mtu    = 1450                       # Custom MTU (default: 1500)
network_rate   = 1000                       # 1 Gbps rate limit
```

**Use cases:**
- **Static IP**: Required for production servers, databases
- **IPv6 auto**: Automatic IPv6 configuration via router advertisements
- **Custom MTU**: For VPNs, tunnels, or networks requiring smaller packets
- **Rate limit**: Prevent one container from saturating network

### Advanced Features

```hcl
features = {
  nesting = true          # REQUIRED for Docker, Podman, LXD
  fuse    = true          # REQUIRED for SSHFS, user-space filesystems
  keyctl  = true          # REQUIRED for full systemd functionality
  mount   = "nfs;cifs"    # Allow NFS and CIFS mounts
}
```

**When to enable:**
- **nesting**: Always for container-in-container or Docker
- **fuse**: If using SSHFS, AppImage, or user-space filesystems
- **keyctl**: If using systemd features requiring kernel keyrings
- **mount**: If mounting network storage (NFS shares, Windows CIFS)

### Protection

```hcl
protection = true
```

**What it does:**
- Prevents `terraform destroy` from working
- Prevents deletion via Proxmox UI (requires unchecking protection first)
- Useful for critical production containers

**To destroy a protected container:**
```bash
# Option 1: Remove protection in main.tf, then apply
# Set: protection = false
terraform apply
terraform destroy

# Option 2: Remove protection via Proxmox
ssh root@proxmox-host "pct set 200 --protection 0"
terraform destroy
```

---

## Modifying the Container

### Changing Resources (Hot)

Some changes can be applied without restart:

```hcl
# Edit main.tf
cores    = 16      # Increase CPU cores
memory   = 8192    # Increase RAM to 8GB
cpulimit = 8       # Increase CPU limit
```

```bash
# Apply changes
terraform apply

# Verify (from inside container)
ssh root@192.168.1.200
nproc      # Should show 16
free -h    # Should show 8GB
```

### Changing Network (Cold)

Network changes require container restart:

```hcl
# Edit main.tf
network_ip = "192.168.1.201/24"  # New IP
```

```bash
# Apply (will restart container)
terraform apply

# Wait for restart
sleep 10

# SSH with new IP
ssh root@192.168.1.201
```

### Resizing Disk (Hot)

Disk can be increased without restart:

```hcl
# Edit main.tf
rootfs_size = "40G"  # Increase from 20G to 40G
```

```bash
# Apply changes
terraform apply

# Verify (from inside container)
ssh root@192.168.1.200
df -h /
# Should show ~40GB total
```

**Note**: Disk can only be **increased**, never decreased!

---

## Startup Order

This example configures automatic startup:

```hcl
onboot  = true
startup = "order=1,up=60,down=60"
```

**Explained:**
- `order=1`: Start this container first (lower numbers start earlier)
- `up=60`: Wait 60 seconds after starting before considering it "up"
- `down=60`: Wait 60 seconds for graceful shutdown

**Use case:**
```
order=1: Database container (starts first)
order=2: Application container (waits for database)
order=3: Web server container (waits for application)
```

---

## Resource Pool Integration

```hcl
pool = "production"
```

**Benefits:**
- **Organization**: Group related containers
- **Permissions**: Assign users/groups to pools
- **Monitoring**: Filter by pool in Proxmox UI
- **Quotas**: Set resource limits per pool (Proxmox feature)

**Managing pools:**
```bash
# List all pools
ssh root@proxmox-host "pvesh get /pools"

# List containers in a pool
ssh root@proxmox-host "pvesh get /pools/production"

# Create new pool
ssh root@proxmox-host "pvesh create /pools --poolid staging"

# Move container to different pool
# Edit main.tf, change pool, then:
terraform apply
```

---

## High Availability (Optional)

This example includes commented HA configuration:

```hcl
# Uncomment and configure for HA clusters:
# hastate = "started"   # HA state: started/stopped/enabled/disabled
# hagroup = "ha-group1" # HA group name
```

**Prerequisites:**
- Proxmox cluster (3+ nodes recommended)
- Shared storage accessible by all nodes
- HA configured in Proxmox

**Enable HA:**
1. Uncomment `hastate` and `hagroup` in `main.tf`
2. Create HA group in Proxmox:
   ```bash
   ssh root@proxmox-host "ha-manager groupconfig add ha-group1 --nodes pve01,pve02,pve03"
   ```
3. Apply configuration:
   ```bash
   terraform apply
   ```

---

## Monitoring and Troubleshooting

### Check Container Status

```bash
# Via Terraform
terraform show

# Via Proxmox CLI
ssh root@proxmox-host "pct status 200"
# Output: status: running

# Get full configuration
ssh root@proxmox-host "pct config 200"
```

### View Resource Usage

```bash
# Via Proxmox CLI
ssh root@proxmox-host "pct exec 200 -- top -bn1 | head -20"

# Or SSH and use monitoring tools
ssh root@192.168.1.200
htop          # Install: apt install htop
iotop         # Install: apt install iotop
iftop         # Install: apt install iftop
```

### Check Logs

```bash
# Container boot logs
ssh root@proxmox-host "pct exec 200 -- journalctl -b"

# Systemd logs
ssh root@192.168.1.200 "journalctl -xe"

# Proxmox host logs for this container
ssh root@proxmox-host "grep 'vmid 200' /var/log/pve/tasks/active"
```

### Common Issues

#### 1. Container Won't Start

```bash
# Check status
ssh root@proxmox-host "pct status 200"

# Try manual start
ssh root@proxmox-host "pct start 200"

# Check for errors
ssh root@proxmox-host "pct start 200 --debug"
```

#### 2. Network Not Working

```bash
# Enter container console
ssh root@proxmox-host "pct enter 200"

# Check network interface
ip addr show eth0
ip route

# Restart networking
systemctl restart systemd-networkd

# Check DNS
cat /etc/resolv.conf
ping 8.8.8.8
```

#### 3. Docker Not Working

```bash
# Verify nesting is enabled
ssh root@proxmox-host "pct config 200 | grep features"
# Should show: features: nesting=1

# Check kernel modules
ssh root@192.168.1.200 "lsmod | grep overlay"

# Restart Docker
ssh root@192.168.1.200 "systemctl restart docker"
```

#### 4. Cannot Delete (Protection Enabled)

```bash
# Check protection status
ssh root@proxmox-host "pct config 200 | grep protection"

# Disable protection
ssh root@proxmox-host "pct set 200 --protection 0"

# Then destroy
terraform destroy
```

---

## Cleanup

### Destroy Container

```bash
# IMPORTANT: Protection must be disabled first!
# Edit main.tf:
protection = false

# Apply to remove protection
terraform apply

# Now destroy
terraform destroy

# Type 'yes' when prompted
```

**What gets deleted:**
- ✅ Container (VMID 200)
- ✅ Container disk
- ✅ All container data
- ✅ Pool membership (pool itself remains)

**What remains:**
- ❌ LXC template
- ❌ Resource pool
- ❌ Network configuration
- ❌ SSH keys

---

## Next Steps

### Other Examples

- **[Basic Example](../basic)** - Simple DHCP container
- **[Provisioner Example](../provisioner)** - Automatic software installation
- **[Multi-Scripts Example](../provisioner-multi-scripts)** - Modular provisioning
- **[Hookscript Example](../hookscript)** - Lifecycle hooks

### Production Checklist

Before deploying to production:

- [ ] Static IP configured and documented
- [ ] SSH keys used (no passwords)
- [ ] Backups configured in Proxmox
- [ ] Resource limits appropriate for workload
- [ ] Startup order configured if part of stack
- [ ] Monitoring configured (Prometheus, Zabbix, etc.)
- [ ] Firewall rules configured
- [ ] DNS records created
- [ ] Documentation updated with IP and purpose
- [ ] Protection enabled after testing
- [ ] Pool assignment correct
- [ ] Tags added for organization

---

## Additional Resources

### Documentation

- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc)
- [Proxmox LXC](https://pve.proxmox.com/wiki/Linux_Container)
- [Proxmox Networking](https://pve.proxmox.com/wiki/Network_Configuration)
- [Terraform/OpenTofu](https://www.terraform.io/docs)

### Module Files

- [Module README](../../README.md)
- [All Variables](../../variables.tf)
- [All Outputs](../../outputs.tf)

### Community

- [Proxmox Forum](https://forum.proxmox.com/)
- [Terraform Discussions](https://discuss.hashicorp.com/c/terraform-core)
- [OpenTofu Community](https://opentofu.org/community)

---

## Summary

This advanced example demonstrates:

✅ **Production-ready configuration** with resource limits and protection
✅ **Docker support** via nested virtualization
✅ **Static networking** with IPv4/IPv6
✅ **Security** via SSH keys and unprivileged containers
✅ **Organization** via resource pools and tags
✅ **Automation** via startup ordering
✅ **Flexibility** with advanced features (FUSE, keyctl, NFS)

Use this as a template for your production LXC containers! 🚀
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
| <a name="module_lxc_advanced"></a> [lxc\_advanced](#module\_lxc\_advanced) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_networks"></a> [additional\_networks](#input\_additional\_networks) | Additional network interfaces beyond eth0 | <pre>list(object({<br>    name     = string<br>    bridge   = string<br>    ip       = string<br>    gw       = string<br>    tag      = number<br>    firewall = bool<br>  }))</pre> | <pre>[<br>  {<br>    "bridge": "vmbr0",<br>    "firewall": false,<br>    "gw": "10.10.0.1",<br>    "ip": "10.10.0.10/20",<br>    "name": "eth1",<br>    "tag": 10<br>  },<br>  {<br>    "bridge": "vmbr0",<br>    "firewall": false,<br>    "gw": "10.60.0.1",<br>    "ip": "10.60.0.10/23",<br>    "name": "eth2",<br>    "tag": 60<br>  }<br>]</pre> | no |
| <a name="input_arch"></a> [arch](#input\_arch) | Container CPU architecture (amd64, arm64, armhf, i386) | `string` | `"amd64"` | no |
| <a name="input_bwlimit"></a> [bwlimit](#input\_bwlimit) | I/O bandwidth limit in KiB/s (null = no limit) | `number` | `null` | no |
| <a name="input_cmode"></a> [cmode](#input\_cmode) | Container console mode (tty, console, shell) | `string` | `"console"` | no |
| <a name="input_console"></a> [console](#input\_console) | Enable console device | `bool` | `true` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores allocated to container | `number` | `8` | no |
| <a name="input_cpulimit"></a> [cpulimit](#input\_cpulimit) | CPU usage limit in number of cores (0 = no limit) | `number` | `4` | no |
| <a name="input_cpuunits"></a> [cpuunits](#input\_cpuunits) | CPU weight for kernel scheduler | `number` | `4096` | no |
| <a name="input_description"></a> [description](#input\_description) | Container description | `string` | `"Production Docker container for web applications"` | no |
| <a name="input_features_nesting"></a> [features\_nesting](#input\_features\_nesting) | Enable nested virtualization (required for Docker) | `bool` | `true` | no |
| <a name="input_force"></a> [force](#input\_force) | Force creation overwriting existing container | `bool` | `false` | no |
| <a name="input_hookscript"></a> [hookscript](#input\_hookscript) | Script executed on lifecycle events | `string` | `null` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname for the LXC container | `string` | `"docker-prd-app-01"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of RAM allocated to container in MB | `number` | `4096` | no |
| <a name="input_mountpoints"></a> [mountpoints](#input\_mountpoints) | Additional storage volumes beyond root filesystem | <pre>list(object({<br>    slot      = string<br>    storage   = string<br>    mp        = string<br>    size      = string<br>    backup    = bool<br>    replicate = optional(bool)<br>  }))</pre> | <pre>[<br>  {<br>    "backup": true,<br>    "mp": "/mnt/data",<br>    "size": "50G",<br>    "slot": "0",<br>    "storage": "nas"<br>  },<br>  {<br>    "backup": true,<br>    "mp": "/var/lib/docker",<br>    "replicate": false,<br>    "size": "100G",<br>    "slot": "1",<br>    "storage": "nas"<br>  }<br>]</pre> | no |
| <a name="input_nameserver"></a> [nameserver](#input\_nameserver) | DNS server IP address | `string` | `"8.8.4.4"` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to attach the container to | `string` | `"vmbr0"` | no |
| <a name="input_network_firewall"></a> [network\_firewall](#input\_network\_firewall) | Enable Proxmox firewall on interface | `bool` | `false` | no |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Network gateway IP address | `string` | `"192.168.1.1"` | no |
| <a name="input_network_gw6"></a> [network\_gw6](#input\_network\_gw6) | IPv6 gateway address | `string` | `null` | no |
| <a name="input_network_hwaddr"></a> [network\_hwaddr](#input\_network\_hwaddr) | Custom MAC address | `string` | `null` | no |
| <a name="input_network_ip"></a> [network\_ip](#input\_network\_ip) | Static IP address with CIDR notation | `string` | `"192.168.1.201/24"` | no |
| <a name="input_network_ip6"></a> [network\_ip6](#input\_network\_ip6) | IPv6 address configuration (auto, dhcp, manual, or CIDR) | `string` | `"auto"` | no |
| <a name="input_network_mtu"></a> [network\_mtu](#input\_network\_mtu) | Maximum Transmission Unit (packet size) | `number` | `1500` | no |
| <a name="input_network_rate"></a> [network\_rate](#input\_network\_rate) | Network rate limit in Mbps | `number` | `100` | no |
| <a name="input_network_vlan"></a> [network\_vlan](#input\_network\_vlan) | VLAN tag for network segmentation | `number` | `null` | no |
| <a name="input_onboot"></a> [onboot](#input\_onboot) | Start container automatically when host boots | `bool` | `false` | no |
| <a name="input_ostemplate"></a> [ostemplate](#input\_ostemplate) | OS template to use for the container | `string` | `"nas:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"` | no |
| <a name="input_ostype"></a> [ostype](#input\_ostype) | Container operating system type | `string` | `null` | no |
| <a name="input_password"></a> [password](#input\_password) | Root password for the container | `string` | `"YourSecurePassword123!"` | no |
| <a name="input_pool"></a> [pool](#input\_pool) | Proxmox resource pool name | `string` | `null` | no |
| <a name="input_protection"></a> [protection](#input\_protection) | Protection against accidental removal | `bool` | `false` | no |
| <a name="input_restore"></a> [restore](#input\_restore) | Mark operation as backup restore | `bool` | `false` | no |
| <a name="input_rootfs_size"></a> [rootfs\_size](#input\_rootfs\_size) | Root filesystem size | `string` | `"20G"` | no |
| <a name="input_rootfs_storage"></a> [rootfs\_storage](#input\_rootfs\_storage) | Storage pool for the root filesystem | `string` | `"nas"` | no |
| <a name="input_searchdomain"></a> [searchdomain](#input\_searchdomain) | DNS search domain | `string` | `"kode3.intra"` | no |
| <a name="input_start"></a> [start](#input\_start) | Start container immediately after creation | `bool` | `true` | no |
| <a name="input_startup"></a> [startup](#input\_startup) | Boot order and timing configuration (format: order=N,up=N,down=N) | `string` | `"order=2,up=30,down=60"` | no |
| <a name="input_swap"></a> [swap](#input\_swap) | Amount of swap memory in MB | `number` | `2048` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for organization | `map(string)` | <pre>{<br>  "application": "web-server",<br>  "backup": "daily",<br>  "environment": "production",<br>  "team": "devops",<br>  "test": "true"<br>}</pre> | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | Proxmox node name where the LXC container will be created | `string` | `"pve01"` | no |
| <a name="input_template"></a> [template](#input\_template) | Mark container as template | `bool` | `false` | no |
| <a name="input_tty"></a> [tty](#input\_tty) | Number of TTY terminals available | `number` | `2` | no |
| <a name="input_unique"></a> [unique](#input\_unique) | Generate random unique MAC address | `bool` | `false` | no |
| <a name="input_unprivileged"></a> [unprivileged](#input\_unprivileged) | Run container as unprivileged user | `bool` | `true` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | Unique container ID in Proxmox | `number` | `200` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The VMID of the created LXC container |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | The hostname of the created LXC container |
| <a name="output_container_vmid"></a> [container\_vmid](#output\_container\_vmid) | The VMID of the created LXC container |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

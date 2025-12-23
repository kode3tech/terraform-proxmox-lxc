# Terraform Proxmox LXC Module

A Terraform module for creating and managing LXC (Linux Container) instances on Proxmox VE using the Telmate/proxmox provider.

## Features

- **Standardized Naming**: Enforces consistent naming convention (`<prefix>-<env>-<workload>-<index>`)
- **Environment Support**: Built-in validation for dev, stg, and prd environments
- **Resource Validation**: Input validation for cores, memory, networking, and other configurations
- **Mandatory Tagging**: Automatic tagging with `managed-by=terraform` and `module=lxc`
- **Flexible Networking**: Support for static IP, DHCP, VLAN tagging
- **Security First**: Defaults to unprivileged containers, supports SSH key injection
- **Opinionated Defaults**: Sensible defaults for quick deployment

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| proxmox | ~> 3.0 |

## Proxmox Permissions

The Proxmox API token/user needs the following permissions:
- `VM.Allocate` - Create/remove VMs
- `VM.Config.Network` - Configure network
- `VM.Config.Disk` - Configure storage
- `Datastore.AllocateSpace` - Allocate storage space
- `Sys.Console` - Access to container console (optional)

## Usage

### Basic Example

```hcl
module "web_container" {
  source = "github.com/yourorg/terraform-proxmox-lxc"

  # Naming
  prefix   = "app"
  env      = "dev"
  workload = "web"
  index    = "01"

  # Proxmox
  target_node = "pve-node01"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

  # Resources
  cores  = 2
  memory = 2048
  swap   = 1024

  # Storage
  rootfs_storage = "local-lvm"
  rootfs_size    = "10G"

  # Network
  network_bridge  = "vmbr0"
  network_ip      = "192.168.1.100/24"
  network_gateway = "192.168.1.1"

  # SSH access
  ssh_public_keys = file("~/.ssh/id_rsa.pub")

  # Tags
  tags = {
    project = "web-app"
    owner   = "devops-team"
  }
}
```

### Provider Configuration

Set environment variables for authentication:

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pam!your-token-id"
export PM_API_TOKEN_SECRET="your-secret-token"
```

Or configure in your Terraform code:

```hcl
provider "proxmox" {
  pm_api_url          = "https://proxmox.example.com:8006/api2/json"
  pm_api_token_id     = "terraform@pam!your-token-id"
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Prefix for resource naming | `string` | n/a | yes |
| env | Environment identifier (dev, stg, or prd) | `string` | n/a | yes |
| workload | Workload identifier for the container | `string` | n/a | yes |
| index | Numeric index for the container (01-99) | `string` | `"01"` | no |
| target_node | Name of the Proxmox node | `string` | n/a | yes |
| ostemplate | OS template for the container | `string` | n/a | yes |
| vmid | VM ID for the LXC container | `number` | `null` | no |
| arch | Container architecture | `string` | `"amd64"` | no |
| cores | Number of CPU cores | `number` | `1` | no |
| memory | Memory allocation in MB | `number` | `512` | no |
| swap | Swap allocation in MB | `number` | `512` | no |
| rootfs_storage | Storage pool for root filesystem | `string` | `"local-lvm"` | no |
| rootfs_size | Size of root filesystem (e.g., '8G') | `string` | `"8G"` | no |
| network_bridge | Network bridge | `string` | `"vmbr0"` | no |
| network_ip | IP address configuration | `string` | `"dhcp"` | no |
| network_gateway | Gateway IP address | `string` | `null` | no |
| network_vlan | VLAN tag | `number` | `null` | no |
| unprivileged | Create unprivileged container | `bool` | `true` | no |
| onboot | Start container on host boot | `bool` | `false` | no |
| start | Start container after creation | `bool` | `true` | no |
| ssh_public_keys | SSH public keys to inject | `string` | `null` | no |
| password | Root password (use with caution) | `string` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |
| description | Container description | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the LXC container resource |
| hostname | The hostname of the LXC container |
| vmid | The VM ID assigned to the LXC container |
| ipv4_address | The IPv4 address (if static IP configured) |
| network_config | Network configuration applied to the container |

## Naming Convention

The module generates hostnames following this pattern:

```
<prefix>-<env>-<workload>-<index>
```

**Example**: `app-dev-web-01`

**Constraints**:
- Total length must not exceed 64 characters
- Only lowercase letters, numbers, and hyphens allowed
- `prefix`: 1-10 characters
- `env`: Must be one of `dev`, `stg`, `prd`
- `workload`: 1-20 characters
- `index`: 01-99

## Tagging

All containers are tagged with mandatory tags:
- `managed-by = "terraform"`
- `module = "lxc"`
- `env = "<environment>"`
- `workload = "<workload>"`

Additional tags can be provided via the `tags` variable and will be merged with mandatory tags.

## Examples

See the [examples/basic](examples/basic) directory for a complete working example.

To test the example:

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

## Limitations

- Single network interface (eth0) - for multiple interfaces, compose in root module
- No support for additional mount points - keep module simple, compose for complex needs
- No HA configuration - handle at cluster/root module level

## Contributing

This module follows strict design principles:
- Single responsibility (LXC containers only)
- Minimal interface with opinionated defaults
- All inputs must have validation
- Changes must maintain backward compatibility (or bump MAJOR version)

## License

MIT

## Authors

Infrastructure Team

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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 2.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 2.9.14 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_lxc.this](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arch"></a> [arch](#input\_arch) | Container architecture | `string` | `"amd64"` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores allocated to the container | `number` | `1` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the container | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment identifier (dev, stg, or prd) | `string` | n/a | yes |
| <a name="input_index"></a> [index](#input\_index) | Numeric index for the container (01-99) | `string` | `"01"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocation in MB for the container | `number` | `512` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to attach the container to | `string` | `"vmbr0"` | no |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Gateway IP address for the container network | `string` | `null` | no |
| <a name="input_network_ip"></a> [network\_ip](#input\_network\_ip) | IP address configuration for the container (e.g., '192.168.1.100/24' or 'dhcp') | `string` | `"dhcp"` | no |
| <a name="input_network_vlan"></a> [network\_vlan](#input\_network\_vlan) | VLAN tag for the network interface | `number` | `null` | no |
| <a name="input_onboot"></a> [onboot](#input\_onboot) | Start container on host boot | `bool` | `false` | no |
| <a name="input_ostemplate"></a> [ostemplate](#input\_ostemplate) | OS template for the container (e.g., 'local:vztmpl/ubuntu-22.04-standard\_22.04-1\_amd64.tar.zst') | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | Root password for the container (use with caution) | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource naming | `string` | n/a | yes |
| <a name="input_rootfs_size"></a> [rootfs\_size](#input\_rootfs\_size) | Size of the root filesystem (e.g., '8G', '20G') | `string` | `"8G"` | no |
| <a name="input_rootfs_storage"></a> [rootfs\_storage](#input\_rootfs\_storage) | Storage pool for the root filesystem | `string` | `"local-lvm"` | no |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | SSH public keys to inject into the container | `string` | `null` | no |
| <a name="input_start"></a> [start](#input\_start) | Start the container after creation | `bool` | `true` | no |
| <a name="input_swap"></a> [swap](#input\_swap) | Swap allocation in MB for the container | `number` | `512` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to the container (will be merged with mandatory tags) | `map(string)` | `{}` | no |
| <a name="input_target_node"></a> [target\_node](#input\_target\_node) | Name of the Proxmox node where the container will be created | `string` | n/a | yes |
| <a name="input_unprivileged"></a> [unprivileged](#input\_unprivileged) | Create an unprivileged container (recommended for security) | `bool` | `true` | no |
| <a name="input_vmid"></a> [vmid](#input\_vmid) | VM ID for the LXC container. If not set, Proxmox will auto-assign | `number` | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier for the container | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The hostname of the LXC container |
| <a name="output_id"></a> [id](#output\_id) | The ID of the LXC container resource |
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | The IPv4 address of the LXC container (if static IP is configured) |
| <a name="output_network_config"></a> [network\_config](#output\_network\_config) | Network configuration applied to the container |
| <a name="output_vmid"></a> [vmid](#output\_vmid) | The VM ID assigned to the LXC container |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

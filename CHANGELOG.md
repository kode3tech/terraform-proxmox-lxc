# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Integration tests with Terratest
- Automated security scanning
- Performance benchmarks
- Additional provisioning examples

---

## [1.0.0] - 2025-12-26

### Added

#### Core Module
- **Complete LXC module** for Proxmox VE using Telmate/proxmox provider
- **Hostname validation**: RFC-compliant hostname validation (1-63 characters, alphanumeric and hyphens)
- **Comprehensive input validation** with educational error messages
- **Mandatory tagging system**: automatic `managed-by` and `module` tags
- **Flexible networking**: Support for static IP, DHCP, IPv6, VLAN tagging, MTU customization
- **Security-first defaults**: Unprivileged containers, SSH key authentication
- **Resource management**: CPU, memory, swap allocation with validation
- **Storage configuration**: Flexible rootfs and mountpoint options
- **Advanced features**: Nested virtualization, FUSE, NFS/CIFS mounts, keyctl support
- **High availability**: Startup ordering, protection, pool assignment, HA state

#### Provisioning System
- **Three provisioning modes**:
  1. Inline commands via `provisioner_commands`
  2. Single external script via `provisioner_script_path`
  3. Multiple ordered scripts via `provisioner_scripts_dir`
- **SSH authentication**: Private key (file path or inline) support
- **Change detection**: MD5 hash-based triggers for re-provisioning
- **Script execution**: Lexicographic ordering with numeric prefixes (01-, 02-, etc.)
- **Timeout configuration**: Customizable timeouts and retry intervals
- **DHCP validation**: Prevents provisioner use with DHCP (requires static IP)

#### Hookscript Support
- **Lifecycle hooks**: Integration with Proxmox hookscripts
- **Storage validation**: Ensures storage supports snippets content type
- **Example hookscript**: Perl template demonstrating all phases

#### Examples
- **Basic example**: Simple DHCP container with SSH authentication
- **Advanced example**: Production-ready with all features
- **Provisioner example**: Single script provisioning with Docker
- **Multi-scripts example**: Modular provisioning with ordered scripts
- **Hookscript example**: Lifecycle management examples

#### Documentation
- **Comprehensive README**: Usage, inputs, outputs, examples
- **Example documentation**: Detailed documentation per example with troubleshooting
- **OpenTofu compatibility**: Documented throughout all examples
- **Contributing guide**: PR guidelines and commit format
- **Code of Conduct**: Community guidelines
- **Pre-commit documentation**: Hook configuration and usage

#### Development Tools
- **Pre-commit hooks**: Format, validate, lint, docs generation
- **TFLint configuration**: Custom rules for Terraform best practices
- **EditorConfig**: Consistent coding style
- **direnv support**: Automatic environment variable loading in examples
- **CI/CD pipeline**: GitHub Actions with validation and linting

#### Community Files
- **MIT License**: Permissive open source license
- **Contributing guidelines**: How to contribute effectively
- **Code of Conduct**: Contributor Covenant

### Technical Details

#### Provider Requirements
- Terraform/OpenTofu: >= 1.6.0
- Telmate/proxmox provider: 3.0.2-rc07 (tested and recommended)
- hashicorp/null provider: >= 3.0 (for provisioners)
- Proxmox VE: Compatible with versions 8.x and 9.x

#### Validation Features
- Hostname validation (1-63 characters, RFC-compliant format)
- VMID range validation (100-999999999)
- OS template format validation
- CPU cores limit (1-64)
- Memory minimum (512MB)
- Network configuration validation
- DHCP + provisioner incompatibility check
- Storage size format validation
- SSH key requirements validation

#### Security
- Unprivileged containers by default
- SSH key authentication (password optional)
- Private key detection in pre-commit hooks
- No hardcoded credentials in examples
- Environment variable-based authentication

---

## Version History

### How to Read This Changelog

- **[Unreleased]**: Changes in `main` branch not yet released
- **[X.Y.Z]**: Released versions following Semantic Versioning

### Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version (X.0.0): Incompatible API changes
- **MINOR** version (0.X.0): New functionality, backward compatible
- **PATCH** version (0.0.X): Bug fixes, backward compatible

### Breaking Changes

Breaking changes are marked with **BREAKING** in the changelog and will increment the MAJOR version. Check migration guides before upgrading major versions.

---

## [1.0.0-rc.1] - 2025-12-20

### Added
- Initial release candidate
- Complete module implementation
- All examples with comprehensive documentation

### Changed
- Final documentation polish
- Example standardization

### Fixed
- Network configuration variables in examples
- DHCP validation logic

---

## Migration Guides

### Upgrading to 1.0.0

This is the initial stable release. If you were using pre-release versions:

1. **Update module source** to use tagged version:
   ```hcl
   source = "github.com/kode3tech/terraform-proxmox-lxc?ref=v1.0.0"
   ```

2. **Review breaking changes** (if any) in this changelog

3. **Test in non-production** environment first

4. **Update examples** if customized from templates

---

## Notes

### Changelog Maintenance

- All notable changes are documented here
- Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
- Versions follow [Semantic Versioning](https://semver.org/)
- Dates use ISO 8601 format (YYYY-MM-DD)

### Categories

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security fixes

### Links

[Unreleased]: https://github.com/kode3tech/terraform-proxmox-lxc/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/kode3tech/terraform-proxmox-lxc/releases/tag/v1.0.0
[1.0.0-rc.1]: https://github.com/kode3tech/terraform-proxmox-lxc/releases/tag/v1.0.0-rc.1

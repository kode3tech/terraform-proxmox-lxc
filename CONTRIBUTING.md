# Contributing to terraform-proxmox-lxc

Thank you for your interest in contributing to this Terraform module. This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- Clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Terraform/OpenTofu version
- Proxmox provider version
- Proxmox VE version

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- Clear and descriptive title
- Detailed description of the proposed functionality
- Explanation of why this enhancement would be useful
- Code examples demonstrating the proposed usage

### Pull Requests

1. Fork the repository and create your branch from `main`
2. Follow the module design principles outlined in `.github/copilot-instructions.md`
3. Ensure your code follows Terraform best practices
4. Add or update tests in `examples/` as needed
5. Update documentation (README.md) if you change functionality
6. Ensure all CI checks pass

#### Pull Request Guidelines

- Keep changes focused and atomic
- Write clear commit messages following Conventional Commits format
- Update the README.md with details of changes to the interface
- Ensure backward compatibility or clearly mark breaking changes
- Add validation blocks for new variables
- Test your changes with both Terraform and OpenTofu

#### Commit Message Format

Follow the Conventional Commits specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or updating tests
- `chore`: Changes to build process or auxiliary tools

Example:
```
feat(network): add support for multiple network interfaces

Extends the module to support multiple network configurations
through a new `networks` variable.

BREAKING CHANGE: `network_*` variables are deprecated in favor of `networks` list
```

## Development Setup

### Prerequisites

- Terraform >= 1.6.0 or OpenTofu >= 1.6.0
- Access to a Proxmox VE instance for testing
- ASDF for version management (optional but recommended)

### Local Development

1. Clone the repository:
```bash
git clone https://github.com/kode3tech/terraform-proxmox-lxc.git
cd terraform-proxmox-lxc
```

2. Install required versions using ASDF:
```bash
asdf install
```

3. Install pre-commit hooks:
```bash
pip install pre-commit
pre-commit install
pre-commit install --hook-type commit-msg
```

4. Initialize the module:
```bash
terraform init
```

5. Run formatting:
```bash
terraform fmt -recursive
```

6. Run validation:
```bash
terraform validate
```

### Testing

Test your changes using the examples:

```bash
cd examples/basic
terraform init
terraform plan
# Only run apply if you have a test Proxmox environment
# terraform apply
```

### Code Quality Checks

Before submitting a PR, ensure:

```bash
# Run all pre-commit hooks
pre-commit run --all-files

# Or individually:
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Example validation
cd examples/basic
terraform init -backend=false
terraform validate
cd ../..
```

## Module Design Principles

This module follows strict design principles:

1. **Single Responsibility**: Only manage LXC containers, nothing else
2. **Minimal Interface**: Expose only necessary variables
3. **Opinionated Defaults**: Provide sensible defaults for common use cases
4. **Input Validation**: All inputs must have validation blocks
5. **Stable Outputs**: Only output stable, minimal values (id, hostname, vmid)
6. **No Resource Leakage**: Never output entire resource objects
7. **Composition Over Configuration**: Keep module simple, compose in root modules

### What NOT to Contribute

- Features that manage multiple resource types (VMs, storage, etc.)
- Complex conditional logic based on multiple boolean flags
- Exposure of all provider arguments
- Breaking changes without MAJOR version bump
- Features that significantly increase complexity without clear value

## Versioning

This project follows Semantic Versioning (SemVer):

- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

Tags are created only from `main` branch after CI passes.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue for questions or discussions about contributions.

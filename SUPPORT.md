# Support

Thank you for using the `terraform-proxmox-lxc` module! This document provides information on how to get help.

---

## 📚 Documentation

Before asking for help, please check our comprehensive documentation:

### Module Documentation

- **[README.md](README.md)** - Main module documentation
  - Features overview
  - Requirements
  - Usage examples
  - Input/output variables
  - Provider configuration

- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes
  - Breaking changes
  - New features
  - Bug fixes
  - Migration guides

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
  - How to contribute
  - Coding standards
  - Pull request process
  - Commit message format

### Example Documentation

Each example includes comprehensive documentation (900+ lines):

- **[examples/basic/README.md](examples/basic/README.md)** - Simple DHCP container
  - Step-by-step setup
  - DHCP configuration
  - SSH authentication
  - Troubleshooting

- **[examples/advanced/README.md](examples/advanced/README.md)** - Production configuration
  - All features demonstrated
  - Resource limits
  - High availability
  - Security best practices

- **[examples/provisioner/README.md](examples/provisioner/README.md)** - Single script provisioning
  - Docker installation
  - Script-based setup
  - SSH provisioning

- **[examples/provisioner-multi-scripts/README.md](examples/provisioner-multi-scripts/README.md)** - Multiple scripts
  - Modular provisioning
  - Ordered execution
  - Real-world patterns

- **[examples/hookscript/README.md](examples/hookscript/README.md)** - Lifecycle hooks
  - Proxmox hookscripts
  - Host-side execution
  - Event handling

---

## 🔍 Troubleshooting

### Common Issues

#### 1. Provider Configuration

**Error:** `Error: Failed to connect to Proxmox API`

**Solution:**
```bash
# Set environment variables
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pam!mytoken"
export PM_API_TOKEN_SECRET="your-secret-token"
export PM_TLS_INSECURE="true"  # Only for self-signed certs
```

#### 2. DHCP + Provisioner Error

**Error:** `provisioner requires static IP, but network_ip is set to "dhcp"`

**Solution:** Provisioners require static IP. Use DHCP only for basic containers without provisioning.

```hcl
# Change from:
network_ip = "dhcp"

# To:
network_ip = "192.168.1.100/24"
network_gateway = "192.168.1.1"
```

#### 3. SSH Connection Timeout

**Error:** `timeout - last error: dial tcp: connect: no route to host`

**Solution:**
- Verify static IP is correct and available
- Check network connectivity: `ping 192.168.1.100`
- Verify SSH is running in container
- Check firewall rules

#### 4. Template Not Found

**Error:** `storage does not exist`

**Solution:**
```bash
# Download template
ssh root@proxmox-host
pveam update
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst

# Verify template location
pveam list local
```

---

## 💬 Getting Help

### 1. Check Existing Resources

Before creating an issue, please search:

- **[Existing Issues](https://github.com/kode3tech/terraform-proxmox-lxc/issues)** - Someone may have already reported your problem
- **[Closed Issues](https://github.com/kode3tech/terraform-proxmox-lxc/issues?q=is%3Aissue+is%3Aclosed)** - Your question might already be answered
- **[Pull Requests](https://github.com/kode3tech/terraform-proxmox-lxc/pulls)** - Check for in-progress fixes
- **[Discussions](https://github.com/kode3tech/terraform-proxmox-lxc/discussions)** - Community Q&A

### 2. GitHub Discussions (Recommended for Questions)

For general questions, use GitHub Discussions:

**[💬 Start a Discussion](https://github.com/kode3tech/terraform-proxmox-lxc/discussions)**

**Discussion Categories:**

- **💡 Ideas** - Feature requests and suggestions
- **❓ Q&A** - Ask and answer questions
- **📣 Announcements** - Project updates
- **🙌 Show and Tell** - Share your implementations

**When to use Discussions:**
- "How do I...?"
- "What's the best way to...?"
- "Can this module...?"
- General questions
- Feature ideas

**Discussion Guidelines:**
- Search before posting
- Use clear, descriptive titles
- Provide context and examples
- Be respectful and constructive

### 3. GitHub Issues (For Bugs and Specific Problems)

For bugs, errors, or specific problems:

**[🐛 Report an Issue](https://github.com/kode3tech/terraform-proxmox-lxc/issues/new/choose)**

**Issue Types:**

1. **🐛 Bug Report** - Something isn't working
2. **✨ Feature Request** - Suggest a new feature
3. **📚 Documentation Issue** - Docs are unclear or wrong
4. **❓ Question** - General questions (prefer Discussions)

**Before Creating an Issue:**
- Search existing issues
- Check if it's already fixed in `main` branch
- Verify it's not a Proxmox or provider issue
- Read the relevant documentation

**Issue Template:**

When reporting a bug, include:

```markdown
## Environment
- Module version: v1.0.0
- Terraform version: 1.6.0 (or OpenTofu X.Y.Z)
- Proxmox provider version: 3.0.2-rc07
- Proxmox VE version: 8.0.4

## Description
Clear description of the problem

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Configuration
```hcl
module "example" {
  source = "..."
  # Your configuration
}
```

## Error Output
```
Paste error output here
```

## Additional Context
Any other relevant information
```

### 4. Community Chat (Future)

- **Slack/Discord** - Coming soon
- **Matrix** - Coming soon

---

## 🚀 Feature Requests

We welcome feature requests! Before requesting:

1. **Check the roadmap** in [MATURITY_ASSESSMENT.md](MATURITY_ASSESSMENT.md)
2. **Search existing requests** to avoid duplicates
3. **Use the feature request template**

**Feature Request Template:**

```markdown
## Feature Description
Clear description of the feature

## Use Case
Why is this feature needed? What problem does it solve?

## Proposed Solution
How should it work?

## Alternatives Considered
What other approaches did you consider?

## Additional Context
Examples, screenshots, links
```

---

## 🤝 Contributing

Want to contribute? Amazing! Please read:

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** - Community standards

**Ways to Contribute:**

- 🐛 Report bugs
- ✨ Suggest features
- 📚 Improve documentation
- 🧪 Add tests
- 💻 Submit pull requests
- 💬 Help others in discussions
- ⭐ Star the repository
- 🔄 Share with others

---

## 📖 Learning Resources

### Terraform/OpenTofu

- [Terraform Documentation](https://www.terraform.io/docs)
- [OpenTofu Documentation](https://opentofu.org/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices)
- [Learn Terraform](https://learn.hashicorp.com/terraform)

### Proxmox VE

- [Proxmox VE Documentation](https://pve.proxmox.com/wiki/Main_Page)
- [Proxmox VE API](https://pve.proxmox.com/pve-docs/api-viewer/)
- [Proxmox LXC Containers](https://pve.proxmox.com/wiki/Linux_Container)
- [Proxmox Forum](https://forum.proxmox.com/)

### Provider

- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Provider GitHub](https://github.com/Telmate/terraform-provider-proxmox)

---

## 🐛 Security Issues

**DO NOT** create public issues for security vulnerabilities!

Please read our **[Security Policy](SECURITY.md)** and report privately:

- GitHub Security Advisories (preferred)
- Email: suporte@kode3.tech
- PGP encrypted email for sensitive reports

**Response time:** 48 hours maximum

---

## 📊 Project Status

### Current Version
- **Stable:** v1.0.0
- **Development:** main branch

### Maintenance Status
- ✅ **Actively Maintained** - Regular updates and support
- Response time: 48-72 hours for issues
- Security updates: Immediate

### Roadmap

See [MATURITY_ASSESSMENT.md](MATURITY_ASSESSMENT.md) for:
- Planned features
- Known limitations
- Future improvements

---

## 📧 Contact

### Maintainers

- **Primary Maintainer:** @maintainer-username
- **Team:** @maintainers

### Communication Channels

- **Issues:** Bug reports and specific problems
- **Discussions:** Questions and general discussion
- **Security:** suporte@kode3.tech
- **Email:** suporte@kode3.tech (general inquiries)

### Response Times

| Channel | Expected Response |
|---------|------------------|
| Security issues | 48 hours maximum |
| Bug reports | 48-72 hours |
| Feature requests | 1 week |
| Questions | 2-3 days |
| Pull requests | 3-5 days |

---

## ⭐ Show Your Support

If this module helps you, please:

- ⭐ **Star the repository**
- 🐦 **Share on social media**
- 📝 **Write a blog post** about your experience
- 💬 **Recommend to colleagues**
- 🤝 **Contribute** improvements

---

## 📜 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

Thanks to:

- Proxmox VE team for the excellent platform
- Telmate for the Terraform provider
- All contributors and users
- HashiCorp for Terraform
- OpenTofu community

---

**Thank you for using terraform-proxmox-lxc!** 🚀

**Last Updated:** 2025-12-26

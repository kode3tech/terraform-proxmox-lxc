# Security Policy

## Supported Versions

We actively support the following versions of this Terraform module with security updates:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 1.x.x   | :white_check_mark: | Active support |
| < 1.0.0 | :x:                | No support (pre-release) |

**Recommendation:** Always use the latest stable version (1.x.x) for security patches and bug fixes.

---

## Security Best Practices

### Using This Module Securely

When deploying LXC containers with this module, follow these security recommendations:

#### 1. Authentication

**✅ DO:**
- Use SSH key authentication instead of passwords
- Store private keys securely (never commit to Git)
- Use separate SSH keys per environment
- Rotate SSH keys regularly

**❌ DON'T:**
- Hardcode passwords in Terraform code
- Commit private keys to version control
- Use the same SSH key across all environments
- Use weak passwords for testing

**Example:**
```hcl
# ✅ GOOD - SSH key from file
ssh_public_keys = file("~/.ssh/id_rsa.pub")

# ❌ BAD - Hardcoded password
password = "admin123"
```

#### 2. Proxmox API Credentials

**✅ DO:**
- Use API tokens instead of username/password
- Set minimal required permissions
- Use environment variables for credentials
- Rotate API tokens regularly

**❌ DON'T:**
- Hardcode API credentials in code
- Use root@pam credentials
- Grant excessive permissions
- Share API tokens across teams

**Example:**
```bash
# ✅ GOOD - Environment variables
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pam!mytoken"
export PM_API_TOKEN_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

#### 3. Container Security

**✅ DO:**
- Use unprivileged containers (default in this module)
- Enable only required features (nesting, FUSE, etc.)
- Keep container templates updated
- Use static IPs for production workloads

**❌ DON'T:**
- Enable privileged mode unless absolutely necessary
- Enable all features by default
- Use outdated container templates
- Expose containers directly to the internet

**Example:**
```hcl
# ✅ GOOD - Minimal features
unprivileged = true
features = {
  nesting = true  # Only if needed for Docker
}

# ❌ BAD - Privileged container
unprivileged = false
```

#### 4. Network Security

**✅ DO:**
- Use private IP ranges
- Configure Proxmox firewall
- Use VLANs for network segmentation
- Limit network access via security groups

**❌ DON'T:**
- Use public IPs without firewall
- Allow all traffic by default
- Mix production and dev networks
- Disable Proxmox firewall

#### 5. Provisioning Security

**✅ DO:**
- Review provisioning scripts before applying
- Use HTTPS for package downloads
- Verify GPG signatures
- Implement idempotent scripts

**❌ DON'T:**
- Run untrusted scripts
- Download packages over HTTP
- Skip signature verification
- Hardcode secrets in scripts

---

## Reporting a Vulnerability

**We take security seriously.** If you discover a security vulnerability, please follow these guidelines:

### 🔒 Private Disclosure (Preferred)

**DO NOT** create a public GitHub issue for security vulnerabilities.

**Instead, report privately via:**

1. **GitHub Security Advisories** (Recommended)
   - Go to: https://github.com/kode3tech/terraform-proxmox-lxc/security/advisories
   - Click "Report a vulnerability"
   - Provide details using the template below

2. **Email** (Alternative)
   - Email: suporte@kode3.tech
   - Subject: `[SECURITY] terraform-proxmox-lxc vulnerability`
   - Use PGP encryption (key below)

3. **PGP Encrypted Email** (For sensitive reports)
   - PGP Key: [Public Key](https://keybase.io/kode3tech)
   - Fingerprint: `1234 5678 9ABC DEF0 1234 5678 9ABC DEF0 1234 5678`

### 📝 Report Template

Please include the following information:

```markdown
## Vulnerability Report

### Summary
Brief description of the vulnerability

### Impact
What can an attacker do with this vulnerability?

### Affected Versions
- Version: X.Y.Z
- Component: main.tf / variables.tf / example

### Steps to Reproduce
1. Step one
2. Step two
3. Step three

### Proof of Concept
Code snippet or configuration demonstrating the issue

### Suggested Fix
If you have ideas on how to fix it

### Disclosure Timeline
When do you plan to publicly disclose? (We prefer 90 days)
```

### 📅 Response Timeline

We are committed to responding promptly:

| Timeline | Action |
|----------|--------|
| **48 hours** | Initial acknowledgment of your report |
| **7 days** | Preliminary assessment and severity rating |
| **30 days** | Fix development and testing |
| **60 days** | Security release and public disclosure |
| **90 days** | Full public disclosure (if fix not released) |

### 🎖️ Security Researcher Recognition

We appreciate security researchers who responsibly disclose vulnerabilities:

- Credit in CHANGELOG.md and security advisory
- Recognition in README.md (if desired)
- Early notification of the fix
- Optional mention in social media announcements

**Hall of Fame:**
- No vulnerabilities reported yet

---

## Security Scanning

This project uses automated security scanning:

### Current Tooling

- **Pre-commit hooks**: Detect private keys before commit
- **TFLint**: Terraform linting for common issues
- **GitHub Dependabot**: Dependency vulnerability scanning (planned)
- **tfsec**: Terraform security scanning (planned)
- **Checkov**: Infrastructure security scanning (planned)

### Running Security Scans Locally

```bash
# Install tfsec
brew install tfsec  # macOS
# or
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Run security scan
tfsec .

# Install checkov
pip3 install checkov

# Run checkov
checkov -d .
```

---

## Known Security Considerations

### Current Limitations

1. **No secrets encryption**
   - SSH keys and passwords stored in Terraform state
   - Recommendation: Use remote state with encryption
   - Future: Integration with Vault/SOPS

2. **Provisioner security**
   - Scripts execute with root privileges
   - Recommendation: Review all provisioning scripts
   - Future: Add script signing/verification

3. **No network isolation by default**
   - Containers use default bridge network
   - Recommendation: Use VLANs and firewall rules
   - Future: Add network policy examples

### Mitigations

- **State encryption**: Use encrypted remote backends (S3 with KMS, Terraform Cloud)
- **Least privilege**: Configure minimal Proxmox API permissions
- **Network segmentation**: Use VLANs for environment isolation
- **Audit logging**: Enable Proxmox audit logs

---

## Security Updates

### Staying Informed

- **Watch this repository** for security advisories
- **Subscribe to releases** for security patches
- **Follow CHANGELOG.md** for security-related changes

### Update Process

When a security update is released:

1. **Review the security advisory** and CHANGELOG
2. **Test in non-production** environment
3. **Update module version** in your code:
   ```hcl
   source = "github.com/kode3tech/terraform-proxmox-lxc?ref=v1.0.1"
   ```
4. **Run `terraform plan`** to review changes
5. **Apply to production** after validation

---

## Compliance

### Security Standards

This module follows these security principles:

- **Principle of Least Privilege**: Minimal default permissions
- **Defense in Depth**: Multiple security layers
- **Secure by Default**: Unprivileged containers, key-based auth
- **Security Through Transparency**: Open source, auditable code

### Certifications

- No formal certifications yet
- Future: CIS Benchmark compliance testing

---

## Security Contacts

- **Maintainer Team**: @maintainers
- **Security Email**: suporte@kode3.tech
- **Response Time**: 48 hours maximum

---

## Additional Resources

- [Proxmox Security Best Practices](https://pve.proxmox.com/wiki/Security)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [OWASP Infrastructure as Code Security](https://owasp.org/www-community/Infrastructure_as_Code_Security)
- [CIS Proxmox Benchmark](https://www.cisecurity.org/)

---

**Last Updated:** 2025-12-26
**Policy Version:** 1.0.0

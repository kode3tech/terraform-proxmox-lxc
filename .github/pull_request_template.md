# Pull Request

## Description

<!-- Provide a clear and concise description of your changes -->

### Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🧪 Test improvements
- [ ] 🔧 Configuration/infrastructure changes
- [ ] ♻️ Code refactoring (no functional changes)
- [ ] ⚡ Performance improvement

### Related Issue

<!-- Link to the issue this PR addresses -->

Fixes #(issue number)
Related to #(issue number)

---

## Changes Made

<!-- Describe the changes you made in detail -->

### Summary

<!-- Brief summary of changes -->

### Detailed Changes

<!-- List specific changes made -->

- Change 1
- Change 2
- Change 3

---

## Testing

### Testing Performed

<!-- Describe the tests you ran to verify your changes -->

- [ ] Tested with Terraform version: <!-- e.g., 1.6.0 -->
- [ ] Tested with OpenTofu version: <!-- e.g., 1.6.0 (if applicable) -->
- [ ] Tested with Proxmox provider version: <!-- e.g., 3.0.2-rc07 -->
- [ ] Tested with Proxmox VE version: <!-- e.g., 8.0.4 -->

### Test Configuration

<!-- If applicable, provide test configuration used -->

```hcl
module "test" {
  source = "../../"

  # Test configuration
}
```

### Test Results

<!-- Describe test results -->

```
terraform init   # ✅ Success
terraform validate  # ✅ Success
terraform plan   # ✅ Success
terraform apply  # ✅ Success
```

---

## Checklist

### Code Quality

- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings or errors
- [ ] I have run `terraform fmt` and code is properly formatted
- [ ] I have run `terraform validate` and there are no errors
- [ ] I have run TFLint and addressed all issues

### Documentation

- [ ] I have updated the README.md (if needed)
- [ ] I have updated the CHANGELOG.md with my changes
- [ ] I have updated variable descriptions in variables.tf
- [ ] I have updated output descriptions in outputs.tf
- [ ] I have added/updated examples (if applicable)
- [ ] I have updated relevant example documentation (if applicable)
- [ ] Documentation builds successfully (`terraform-docs` passes)

### Testing

- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally
- [ ] I have tested with Terraform/OpenTofu
- [ ] I have tested all affected examples
- [ ] I have verified backward compatibility (or marked as breaking change)

### Security

- [ ] My changes do not introduce security vulnerabilities
- [ ] I have not committed sensitive data (credentials, keys, etc.)
- [ ] I have updated SECURITY.md (if security-related changes)
- [ ] Pre-commit hooks pass (including private key detection)

### Breaking Changes

- [ ] This PR introduces breaking changes (check if true)
- [ ] I have documented breaking changes in CHANGELOG.md
- [ ] I have created a migration guide (if needed)
- [ ] I have updated the major version number (if breaking changes)

---

## Screenshots/Output

<!-- If applicable, add screenshots or command output to help explain your changes -->

### Before

```
<!-- Output or screenshot before changes -->
```

### After

```
<!-- Output or screenshot after changes -->
```

---

## Additional Context

<!-- Add any other context about the PR here -->

### Dependencies

<!-- List any dependencies required for this change -->

- Depends on PR #XXX
- Requires module version X.Y.Z
- Requires provider version X.Y.Z

### Migration Notes

<!-- If this is a breaking change, provide migration instructions -->

```hcl
# Before (old configuration)
old_variable = "value"

# After (new configuration)
new_variable = "value"
```

### Performance Impact

<!-- Describe any performance implications -->

- [ ] No performance impact
- [ ] Performance improved
- [ ] Performance degraded (explain why acceptable)

---

## Reviewer Notes

### Review Focus Areas

<!-- Help reviewers by highlighting areas that need special attention -->

- Please review X carefully because...
- Pay special attention to Y...
- I'm unsure about Z...

### Questions for Reviewers

<!-- Any specific questions for reviewers? -->

1. Question 1?
2. Question 2?

---

## Post-Merge Tasks

<!-- Tasks to complete after merging (if any) -->

- [ ] Update documentation website
- [ ] Announce in discussions
- [ ] Create release notes
- [ ] Update examples
- [ ] Other: _________

---

## Maintainer Checklist

<!-- For maintainers only - do not fill out -->

- [ ] Code review completed
- [ ] Tests pass in CI
- [ ] Documentation reviewed
- [ ] CHANGELOG.md updated correctly
- [ ] Version number updated (if needed)
- [ ] Ready to merge

---

**By submitting this pull request, I confirm that:**

- [ ] I have read and agree to the [Code of Conduct](CODE_OF_CONDUCT.md)
- [ ] I have read the [Contributing Guidelines](CONTRIBUTING.md)
- [ ] My contribution is original work or properly attributed
- [ ] I license my contribution under the MIT License

---

<!-- Thank you for contributing! 🚀 -->

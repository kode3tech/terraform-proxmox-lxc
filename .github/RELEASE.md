# Release Workflow

This document describes the automated release process for this Terraform module.

## Overview

Releases are **fully automated** when you push a Git tag. No manual GitHub Release creation needed!

## How It Works

### 1. **You Create a Tag**
```bash
# Update CHANGELOG.md first!
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 2. **GitHub Actions Automatically:**
1. ✅ Validates tag format (must be `vX.Y.Z`)
2. ✅ Checks that version exists in CHANGELOG.md
3. ✅ Extracts changelog content for this version
4. ✅ Runs full CI pipeline (format, validate, lint, security)
5. ✅ Creates GitHub Release with changelog
6. ✅ Notifies that Terraform Registry will auto-sync

### 3. **Terraform Registry Auto-Syncs**
- Registry detects new GitHub Release
- Indexes module within 5-10 minutes
- Version becomes available at `registry.terraform.io/modules/kode3tech/lxc/proxmox`

## Step-by-Step Release Process

### Prerequisites

- [ ] All changes merged to `main` branch
- [ ] CI pipeline passing on `main`
- [ ] CHANGELOG.md updated with new version

### Release Steps

#### 1. Update CHANGELOG.md

Add your version to `CHANGELOG.md`:

```markdown
## [1.0.0] - 2025-12-26

### Added
- New feature X
- New feature Y

### Fixed
- Bug fix Z

### Changed
- Updated behavior of feature A
```

**Important:**
- Version header must be exactly: `## [X.Y.Z] - YYYY-MM-DD`
- Must appear before `## [Unreleased]` section
- Must include date in ISO format

#### 2. Commit CHANGELOG

```bash
git add CHANGELOG.md
git commit -m "docs: prepare v1.0.0 release"
git push origin main
```

#### 3. Wait for CI

```bash
# Wait for CI to pass on main branch
# Check: https://github.com/kode3tech/terraform-proxmox-lxc/actions
```

#### 4. Create and Push Tag

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0 - Brief description

See CHANGELOG.md for complete details."

# Push tag to trigger release workflow
git push origin v1.0.0
```

#### 5. Monitor Release Workflow

```bash
# Watch workflow execution
# https://github.com/kode3tech/terraform-proxmox-lxc/actions/workflows/release.yml
```

**Workflow will:**
- Validate tag format ✅
- Check CHANGELOG.md has version ✅
- Extract changelog content ✅
- Run full CI suite ✅
- Create GitHub Release ✅

#### 6. Verify Release

```bash
# Check release was created
# https://github.com/kode3tech/terraform-proxmox-lxc/releases

# Wait 5-10 minutes for Terraform Registry sync
# https://registry.terraform.io/modules/kode3tech/lxc/proxmox
```

## Tag Format Requirements

### Valid Tags ✅
```
v1.0.0
v2.1.3
v10.22.5
```

### Invalid Tags ❌
```
1.0.0          # Missing 'v' prefix
v1.0           # Missing patch version
v1.0.0-beta    # Pre-release suffix not allowed (will be supported in future)
release-1.0.0  # Wrong format
```

## CHANGELOG Format Requirements

### Valid CHANGELOG Entry ✅

```markdown
## [1.0.0] - 2025-12-26

### Added
- Feature description

### Fixed
- Bug fix description
```

### Invalid CHANGELOG Entry ❌

```markdown
## 1.0.0 - 2025-12-26          # Missing brackets
## [1.0.0]                     # Missing date
## [1.0.0] - 2025/12/26        # Wrong date format
# 1.0.0 - 2025-12-26           # Wrong heading level
```

## What Happens on Error?

### Tag Format Invalid
```
❌ Invalid tag format: v1.0
Expected format: vX.Y.Z (e.g., v1.0.0)
```
**Fix:** Delete tag, create new one with correct format

### Version Missing from CHANGELOG
```
❌ Version 1.0.0 not found in CHANGELOG.md
Please add release notes to CHANGELOG.md before creating a tag
```
**Fix:** Update CHANGELOG.md, commit, push, then create tag again

### CI Pipeline Fails
```
❌ CI checks failed
```
**Fix:** Fix CI issues on main branch first, then create tag

## Deleting/Replacing a Release

### Delete Tag Locally and Remotely
```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0
```

### Delete GitHub Release
```bash
# Via GitHub UI:
# 1. Go to Releases
# 2. Find the release
# 3. Click "Delete"

# Or via GitHub CLI:
gh release delete v1.0.0 --yes
```

### Recreate Release
```bash
# Fix issues, update CHANGELOG
git add CHANGELOG.md
git commit -m "docs: update v1.0.0 changelog"
git push origin main

# Recreate tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## Semantic Versioning Guide

### MAJOR Version (X.0.0)
**Breaking changes** - incompatible API changes

Examples:
- Removing a variable
- Changing variable type
- Renaming output
- Changing default behavior significantly

### MINOR Version (0.X.0)
**New features** - backward-compatible additions

Examples:
- Adding new variable (with default)
- Adding new output
- Adding new feature (opt-in)
- Supporting new provider version

### PATCH Version (0.0.X)
**Bug fixes** - backward-compatible fixes

Examples:
- Fixing validation error
- Correcting documentation
- Fixing edge case bug
- Updating dependencies (patch level)

## Release Checklist Template

Copy this to your issue/PR when preparing a release:

```markdown
## Release Checklist - vX.Y.Z

### Pre-Release
- [ ] All PRs merged to main
- [ ] CI passing on main
- [ ] CHANGELOG.md updated with version and date
- [ ] Breaking changes documented (if MAJOR)
- [ ] Migration guide written (if MAJOR)

### Release
- [ ] CHANGELOG committed and pushed
- [ ] Tag created: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Tag pushed: `git push origin vX.Y.Z`
- [ ] Release workflow passed
- [ ] GitHub Release created automatically

### Post-Release
- [ ] GitHub Release verified
- [ ] Terraform Registry synced (wait 5-10 min)
- [ ] Module version available in registry
- [ ] Tested module installation from registry
- [ ] Announced release (if applicable)

### Rollback (if needed)
- [ ] Delete tag: `git push origin :refs/tags/vX.Y.Z`
- [ ] Delete release from GitHub
- [ ] Fix issues
- [ ] Repeat release process
```

## Troubleshooting

### Workflow Not Triggered
**Problem:** Pushed tag but workflow didn't run

**Solutions:**
1. Check tag format: `git tag -l`
2. Verify tag was pushed: `git ls-remote --tags origin`
3. Check workflow file exists: `.github/workflows/release.yml`
4. Verify GitHub Actions enabled in repository settings

### Workflow Failed at Validation
**Problem:** Workflow stops at "Validate Tag" or "Check CHANGELOG"

**Solutions:**
1. Read error message in workflow logs
2. Verify CHANGELOG.md has exact version: `## [1.0.0] - YYYY-MM-DD`
3. Fix CHANGELOG, commit, delete tag, recreate tag

### Workflow Failed at CI
**Problem:** Release workflow fails during CI checks

**Solutions:**
1. CI must pass on `main` branch first
2. Fix CI issues on main
3. Delete tag: `git push origin :refs/tags/v1.0.0`
4. Recreate tag after CI passes

### Release Created but Empty Changelog
**Problem:** Release created but changelog section is empty

**Solutions:**
1. Verify CHANGELOG.md format
2. Version header must be: `## [X.Y.Z] - YYYY-MM-DD`
3. Delete release and tag
4. Fix CHANGELOG format
5. Recreate tag

## Advanced: Pre-releases

Currently, the workflow only supports stable releases (`vX.Y.Z`).

To support pre-releases (coming soon):
- `v1.0.0-alpha.1`
- `v1.0.0-beta.2`
- `v1.0.0-rc.1`

Will require workflow update to:
1. Detect pre-release suffix
2. Mark GitHub Release as "pre-release"
3. Not trigger Terraform Registry sync

## Examples

### Example 1: Patch Release

```bash
# Update CHANGELOG.md
## [1.0.1] - 2025-12-26
### Fixed
- Fixed validation error for empty tags

# Commit and push
git add CHANGELOG.md
git commit -m "docs: prepare v1.0.1 release"
git push origin main

# Create and push tag
git tag -a v1.0.1 -m "Release v1.0.1 - Bug fixes"
git push origin v1.0.1

# ✅ Release automatically created!
```

### Example 2: Minor Release

```bash
# Update CHANGELOG.md
## [1.1.0] - 2025-12-26
### Added
- Support for multiple network interfaces
- New `additional_networks` variable

# Commit and push
git add CHANGELOG.md
git commit -m "docs: prepare v1.1.0 release"
git push origin main

# Create and push tag
git tag -a v1.1.0 -m "Release v1.1.0 - Multiple network support"
git push origin v1.1.0

# ✅ Release automatically created!
```

### Example 3: Major Release (Breaking Changes)

```bash
# Update CHANGELOG.md
## [2.0.0] - 2025-12-26
### BREAKING CHANGES
- Removed deprecated `naming_prefix` variable
- Changed `network_config` from string to object

### Migration Guide
**Old (v1.x):**
```hcl
naming_prefix = "app"
network_config = "dhcp"
```

**New (v2.x):**
```hcl
hostname = "app-server-01"
network = {
  mode = "dhcp"
}
```

### Added
- New validation for hostname format

# Commit and push
git add CHANGELOG.md
git commit -m "docs: prepare v2.0.0 release with breaking changes"
git push origin main

# Create and push tag
git tag -a v2.0.0 -m "Release v2.0.0 - BREAKING CHANGES

See CHANGELOG.md for migration guide."
git push origin v2.0.0

# ✅ Release automatically created!
```

## CI Integration

The release workflow integrates with CI:

```
Tag pushed (v1.0.0)
    ↓
Validate tag format
    ↓
Check CHANGELOG.md
    ↓
Extract changelog content
    ↓
Run full CI pipeline ← Uses .github/workflows/ci.yml
    ↓
Create GitHub Release
    ↓
Terraform Registry auto-syncs
```

This ensures that **only code that passes CI gets released**.

## Security

- Workflow uses `GITHUB_TOKEN` (automatic)
- No secrets required
- Read-only access to code
- Write access to create releases only
- Minimal permissions (principle of least privilege)

## Support

If you encounter issues with the release workflow:

1. Check [workflow runs](https://github.com/kode3tech/terraform-proxmox-lxc/actions/workflows/release.yml)
2. Read error messages in failed steps
3. Consult this documentation
4. Open an issue if problem persists

---

**Last Updated:** 2025-12-26
**Workflow Version:** 1.0.0

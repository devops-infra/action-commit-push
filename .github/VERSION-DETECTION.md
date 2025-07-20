# Version Detection Test Examples

This file demonstrates how the automated version detection works with different branch merges and commit patterns.

## Branch-Based Version Detection

### ✅ Major Version Bump (v0.10.2 → v0.11.0)
**Trigger**: Merging from `feat*` branches

```bash
# Developer workflow:
git checkout master
git checkout -b feat/new-user-authentication
git commit -m "add OAuth login support"
git commit -m "add user profile management"
git push origin feat/new-user-authentication

# Create PR and merge to master
# Result: Automatic major version bump v0.10.2 → v0.11.0
```

### ✅ Minor Version Bump (v0.10.2 → v0.10.3)  
**Trigger**: Merging from any other branch

```bash
# Bug fix:
git checkout -b fix/login-timeout
git commit -m "fix: resolve session timeout issue"
# Result: v0.10.2 → v0.10.3

# Documentation:
git checkout -b docs/update-api-guide
git commit -m "docs: update API documentation"
# Result: v0.10.2 → v0.10.3

# Refactoring:
git checkout -b refactor/cleanup-auth
git commit -m "refactor: simplify authentication flow"
# Result: v0.10.2 → v0.10.3
```

## Detection Priority

The system checks in this order:

1. **Feature branches** (highest priority)
   - Checks merged branch names for `feat*` pattern
   - Also checks commit messages for `feat:` prefix
   - Results in major version bump

2. **Everything else** (default)
   - All other branch merges and commits
   - Results in minor version bump

## Example Scenarios

| Branch Name | Commit Message | Version Change | Reason |
|-------------|----------------|----------------|---------|
| `feat/auth` | "add login system" | v0.10.2 → v0.11.0 | feat branch |
| `fix/bug` | "fix: resolve crash" | v0.10.2 → v0.10.3 | non-feat branch |
| `docs/readme` | "docs: update guide" | v0.10.2 → v0.10.3 | non-feat branch |
| `fix/bug` | "feat: add new feature" | v0.10.2 → v0.11.0 | feat in commit |
| `refactor/code` | "refactor: improve structure" | v0.10.2 → v0.10.3 | non-feat branch |

This ensures that:
- ✅ New features always increment major version (minor number)
- ✅ Bug fixes and other changes increment minor version (patch number)
- ✅ Documentation and dependency updates don't trigger releases
- ✅ No manual version management needed

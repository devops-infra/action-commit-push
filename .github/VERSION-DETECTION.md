# Version Detection Test Examples

This file demonstrates how the automated version detection works with different branch merges and commit patterns.

## Branch-Based Version Detection

### ✅ Minor Version Bump (v0.10.2 → v0.11.0)
**Trigger**: Merging from `feat*` branches or commits with `feat:` prefix

```bash
# Feature branch workflow:
git checkout master
git checkout -b feat/new-user-authentication
git commit -m "feat: add OAuth login support"
git commit -m "feat: add user profile management"
git push origin feat/new-user-authentication

# Create PR and merge to master
# Result: Automatic minor version bump v0.10.2 → v0.11.0
```

### ✅ Patch Version Bump (v0.10.2 → v0.10.3)  
**Trigger**: Merging from any other branch or non-feature commits

```bash
# Bug fix:
git checkout -b fix/login-timeout
git commit -m "fix: resolve session timeout issue"
# Result: v0.10.2 → v0.10.3

# Documentation:
git checkout -b docs/update-api-guide
git commit -m "docs: update API documentation"
# Result: skipped - docs don't trigger releases

# Refactoring:
git checkout -b refactor/cleanup-auth
git commit -m "refactor: simplify authentication flow"
# Result: v0.10.2 → v0.10.3
```

## 🚫 Skipped Releases

The system automatically skips releases for:

- **Dependency updates**: Branches starting with `dep*` or `dependabot*`
- **Documentation**: Branches starting with `docs*` or commits with `docs:`
- **Release commits**: Prevents infinite loops from release automation
- **Version bumps**: Updates to dependencies or version files

```bash
# These will NOT trigger releases:
git checkout -b deps/update-actions
git commit -m "deps: update GitHub Actions to latest"

git checkout -b docs/fix-readme
git commit -m "docs: fix typos in README"

# Direct commits to master with these patterns also skip releases
```

## Detection Priority & Logic

The system checks in this order:

1. **Skip conditions** (highest priority)
   - Dependency/docs/release branch patterns
   - Dependency/docs/release commit message patterns
   - Existing release commit patterns (prevents loops)

2. **Feature detection** (second priority)
   - Merged branch names matching `feat*` pattern
   - Commit messages with `feat:`, `feat():`, or `feature:` prefix
   - Breaking change indicators (treated as minor for safety)
   - Results in minor version bump (Y)

3. **Everything else** (default)
   - All other branch merges and commits
   - Results in patch version bump (Z)

## Enhanced Example Scenarios

| Branch Name     | Commit Message               | Result            | Reason                          |
|-----------------|------------------------------|-------------------|---------------------------------|
| `feat/auth`     | "feat: add login system"     | v0.10.2 → v0.11.0 | Feature branch + feat commit    |
| `fix/bug`       | "fix: resolve crash"         | v0.10.2 → v0.10.3 | Non-feature branch              |
| `docs/readme`   | "docs: update guide"         | **Skipped**       | Documentation update            |
| `deps/actions`  | "deps: update actions"       | **Skipped**       | Dependency update               |
| `fix/bug`       | "feat: add new feature"      | v0.10.2 → v0.11.0 | feat in commit message          |
| `refactor/code` | "BREAKING CHANGE: new API"   | v0.10.2 → v0.11.0 | Breaking change (conservative)  |
| `any-branch`    | "🤖 Fully Automated Release" | **Skipped**       | Release commit (prevents loops) |

## Advanced Features

### 🔄 **Infinite Loop Prevention**
- Detects its own release commits and skips them
- Prevents cascading releases from automation

### 🎯 **Smart Branch Analysis**
- Analyzes both branch names and commit messages
- Handles various conventional commit formats
- Conservative approach to breaking changes

### ✅ **Validation & Safety**
- Validates version format before processing
- Checks for existing tags to prevent duplicates
- Provides detailed logging for debugging

### 🔧 **Manual Override**
- Supports manual workflow dispatch
- Allows override of auto-detection logic
- Useful for emergency releases or major versions

This ensures that:
- ✅ Major version (X) requires manual intervention for safety
- ✅ New features always increment minor version (Y number)
- ✅ Bug fixes and other changes increment patch version (Z number)
- ✅ Documentation and dependency updates don't clutter releases
- ✅ No manual version management needed for regular development
- ✅ Robust protection against automation loops

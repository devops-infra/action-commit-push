# GitHub Actions Workflows Documentation

This repository us**Purpose**: Fully automated release creation with zero manual intervention
- ✅ Detects when releases are needed (new commits to master, excluding docs/deps)
- ✅ Analyzes commit messages for semantic versioning
- ✅ Calculates next version automatically (major/minor)
- ✅ Creates release branches with version updates using own action
- ✅ Relies on PUSH-OTHER.yml for PR creation
- ✅ Supports manual triggering for custom releases
- ✅ Skips releases for documentation and dependency updatesmprehensive GitHub Actions setup with different workflows for different purposes.

## Workflow Overview

### 1. PUSH-MASTER.yml
**Trigger**: Push to `master` branch

**Purpose**: Continuous Integration for master branch
- ✅ Update repository labels
- ✅ Run Hadolint linting on Dockerfile
- ✅ Build Docker image (test only, no push)

**Actions**:
- Labels management
- Dockerfile linting
- Docker build test

### 2. PUSH-OTHER.yml
**Trigger**: Push to any branch except `master`

**Purpose**: Continuous Integration for feature branches
- ✅ Update repository labels (dry run)
- ✅ Run Hadolint linting on Dockerfile
- ✅ Build Docker image (test only for regular branches)
- ✅ Build & push test Docker images for `test*` branches
- ✅ Create Pull Requests based on branch naming conventions

**Special handling for test branches**:
- Branches starting with `test` → Build and push Docker images with `test-` prefix
- Other branches → Build test only (no push)

**Branch naming conventions for auto-PR creation**:
- `bug*` → Creates PR with "bugfix" label
- `dep*` → Creates PR with "dependency" label  
- `doc*` → Creates PR with "documentation" label
- `feat*` → Creates PR with "feature" label
- `test*` → Creates draft PR with "test" label + pushes test Docker images
- Other branches → Creates PR with "feature" label

### 3. RELEASE.yml
**Trigger**: 
- Push to `release/vX.Y.Z` branches (creates release PR)
- Pull request merge from `release/vX.Y.Z` branches to master (publishes release)

**Purpose**: Handle release branch workflows and Docker image publishing
- ✅ Create release PRs with version updates when pushing to `release/vX.Y.Z` branches
- ✅ Build multi-architecture Docker images (amd64, arm64) when release PRs are merged
- ✅ Push images to Docker Hub with release version tag and `latest`
- ✅ Push images to GitHub Container Registry
- ✅ Create GitHub release with version tag
- ✅ Update Docker Hub description
- ✅ Clean up release branch after merge

### 4. AUTO-VERSION.yml
**Trigger**: 
- Push to `master` branch (automatic)
- Manual workflow dispatch (optional)

**Purpose**: Fully automated release creation with zero manual intervention
- ✅ Detects when releases are needed (new commits to master)
- ✅ Analyzes commit messages for semantic versioning
- ✅ Calculates next version automatically (major/minor/patch)
- ✅ Creates release branches with version updates
- ✅ Opens detailed release PRs
- ✅ Supports manual triggering for custom releases

**Automated Release Process**:
1. New commits pushed to master (excluding docs/dependencies)
2. System analyzes merged branch names and commit messages:
   - Merged from "feat" branches → major version (v0.10.2 → v0.11.0)
   - Other changes → minor version (v0.10.2 → v0.10.3)
3. Automatically creates `release/vX.Y.Z` branch using own action
4. Updates version in `action.yml` and `Makefile`
5. PUSH-OTHER.yml workflow creates PR automatically
6. When merged → triggers RELEASE.yml workflow for publishing

### 5. AUTO-RELEASE.yml
**Trigger**: Manual workflow dispatch only

**Purpose**: Manual release creation with version input
- ✅ Allows manual specification of release version
- ✅ Supports minor/major release types
- ✅ Creates release branches using own action
- ✅ Relies on PUSH-OTHER.yml for PR creation
- ✅ Validates version format and availability

### 6. CRON.yml
**Trigger**: Weekly schedule (Sundays at 5:00 AM UTC)

**Purpose**: Weekly health check and test image refresh
- ✅ Build Docker image to ensure dependencies still work
- ✅ Push test images to keep them fresh for testing
- ✅ Test that the build process is still functional

## Security & Best Practices

### Required Secrets
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions
- `DOCKER_TOKEN`: Docker Hub access token for pushing images

### Required Variables
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_ORG_NAME`: Docker Hub organization name

### Key Features
- **Multi-architecture support**: Builds for both `amd64` and `arm64`
- **Dependency updates**: Uses Dependabot for automated dependency updates
- **Security scanning**: Hadolint for Dockerfile best practices
- **Release automation**: Automatic Docker image versioning and deployment
- **Development safety**: Prevents accidental production deployments from development branches

## Deployment Strategy

### Development Flow
1. Create feature branch with appropriate naming convention
2. Push changes → Triggers build test and auto-PR creation
3. Review and merge PR to master → Triggers automatic release detection
4. System automatically creates release (if new commits warrant it)
5. Review and merge release PR → Triggers production deployment

### Production Deployment
- **Fully automated**: No manual release creation needed
- **Smart detection**: Only releases when there are actual changes
- **Semantic versioning**: Automatic version calculation from commit messages
- **Safe process**: Release PRs provide review opportunity before publishing
- **GitHub release creation**: Automated with release notes
- **Docker Hub and GitHub Container Registry**: Automatic multi-architecture deployment

### Release Automation Strategy
- **Zero manual work**: Push to master → automatic release detection → release PR → merge → publish
- **Semantic commits**: Commit message analysis determines version type
- **Branch protection**: All releases go through PR review process
- **Failsafe mechanisms**: Version validation, duplicate prevention, format checking
- **Clean automation**: Automatic branch cleanup and proper tagging

This setup provides **complete automation** while maintaining safety through the PR review process. No manual release management required!

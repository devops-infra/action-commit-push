# GitHub Actions Workflows Documentation

This repository uses a comprehensive GitHub Actions setup with different workflows for different purposes.

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
- ✅ Build & push test Docker images for `test/*` branches
- ✅ Create Pull Requests based on branch naming conventions

**Special handling for test branches**:
- Branches starting with `test/` → Build and push Docker images with `test-` prefix
- Other branches → Build test only (no push)

**Branch naming conventions for auto-PR creation**:
- `bug/*` → Creates PR with "bugfix" label
- `dep/*` → Creates PR with "dependency" label  
- `doc/*` → Creates PR with "documentation" label
- `feat/*` → Creates PR with "feature" label
- `test/*` → Creates draft PR with "test" label + pushes test Docker images
- Other branches → Creates PR with "feature" label

### 3. RELEASE.yml
**Trigger**: GitHub release published

**Purpose**: Production deployment
- ✅ Build multi-architecture Docker images (amd64, arm64)
- ✅ Push images to Docker Hub with release version tag
- ✅ Push images to GitHub Container Registry
- ✅ Update Docker Hub description
- ✅ Update `action.yml` with new image version

**Release Process**:
1. Create GitHub release with version tag (e.g., `v0.11.0`)
2. Workflow automatically builds and pushes Docker images
3. Images are tagged with the release version
4. `action.yml` is updated to reference the new version

### 4. CRON.yml
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
3. Review and merge PR to master → Triggers master build test
4. Create GitHub release → Triggers production deployment

### Production Deployment
- Only happens on GitHub releases
- Ensures only tested, reviewed code reaches production
- Automatic versioning and tagging
- Docker Hub and GitHub Container Registry deployment

This setup ensures a safe, automated, and well-tested deployment pipeline while maintaining development velocity.

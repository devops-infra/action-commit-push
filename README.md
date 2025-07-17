# 🚀 GitHub Action for Committing Changes to Repository

### 🏗️ Multi-Architecture Support: `amd64` and `aarch64/arm64`

### ⚠️ Recent Changes in v0.11.0
- **Force behavior updated**: `force: true` now uses `git push --force` (breaking change)
- **New parameter**: `force_with_lease` for safer force pushing with `--force-with-lease`  
- **Amend improvements**: Can now combine `amend: true` with `commit_message` to change commit messages

A powerful GitHub Action for automatically committing and pushing changes back to your repository. Perfect for automation workflows and integrates seamlessly with [devops-infra/action-pull-request](https://github.com/devops-infra/action-pull-request).

## 📦 Available on
- **Docker Hub:** [devopsinfra/action-commit-push:latest](https://hub.docker.com/repository/docker/devopsinfra/action-commit-push)
- **GitHub Packages:** [ghcr.io/devops-infra/action-commit-push/action-commit-push:latest](https://github.com/orgs/devops-infra/packages/container/package/action-commit-push)


## ✨ Features

- **📝 Custom commit messages:** Add custom prefixes and messages to commits
- **🌿 Branch management:** Create new branches automatically with optional timestamps
- **⏰ Timestamp support:** Add timestamps to branch names for cron-based updates
- **🔄 Integration-ready:** Works seamlessly with other DevOps workflows
- **💪 Force push options:** Support for `--force` and `--force-with-lease` when needed
- **🔀 Pull request integration:** Perfect companion for automated PR workflows


## 📊 Badge Swag
[
![GitHub repo](https://img.shields.io/badge/GitHub-devops--infra%2Faction--commit--push-blueviolet.svg?style=plastic&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/action-commit-push?color=blueviolet&label=Code%20size&style=plastic&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/action-commit-push?color=blueviolet&logo=github&style=plastic&label=Last%20commit)
![GitHub license](https://img.shields.io/github/license/devops-infra/action-commit-push?color=blueviolet&logo=github&style=plastic&label=License)
](https://github.com/devops-infra/action-commit-push "shields.io")
<br>
[
![DockerHub](https://img.shields.io/badge/DockerHub-devopsinfra%2Faction--commit--push-blue.svg?style=plastic&logo=docker)
![Docker version](https://img.shields.io/docker/v/devopsinfra/action-commit-push?color=blue&label=Version&logo=docker&style=plastic)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/action-commit-push/latest?label=Image%20size&style=plastic&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/action-commit-push?color=blue&label=Pulls&logo=docker&style=plastic)
](https://hub.docker.com/r/devopsinfra/action-commit-push "shields.io")


## 📖 API Reference

```yaml
    - name: Run the Action
      uses: devops-infra/action-commit-push@master
      with:
        github_token: "${{ secrets.GITHUB_TOKEN }}"
        add_timestamp: true
        commit_prefix: "[AUTO]"
        commit_message: "Automatic commit"
        force: false
        force_with_lease: false
        target_branch: update/version
```


### 🔧 Input Parameters

| Input Variable      | Required | Default          | Description                                                                                                                                                        |
| ------------------- | -------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| github_token        | Yes      | `""`             | Personal Access Token for GitHub for pushing the code.                                                                                                             |
| add_timestamp       | No       | `false`          | Whether to add the timestamp to a new branch name. Uses format `%Y-%m-%dT%H-%M-%SZ`.                                                                               |
| amend               | No       | `false`          | Whether to make an amendment to the previous commit (`--amend`). Can be combined with `commit_message` to change the commit message.                              |
| commit_prefix       | No       | `""`             | Prefix added to commit message. Combines with `commit_message`.                                                                                                    |
| commit_message      | No       | `""`             | Commit message to set. Combines with `commit_prefix`. Can be used with `amend` to change the commit message.                                                      |
| force               | No       | `false`          | Whether to use force push (`--force`). Use only when you need to overwrite remote changes. Potentially dangerous.                                                 |
| force_with_lease    | No       | `false`          | Whether to use force push with lease (`--force-with-lease`). Safer than `force` as it checks for remote changes. Set `fetch-depth: 0` for `actions/checkout`.   |
| no_edit             | No       | `false`          | Whether to not edit commit message when using amend (`--no-edit`).                                                                                                 |
| organization_domain | No       | `github.com`     | GitHub Enterprise domain name.                                                                                                                                     |
| target_branch       | No       | *current branch* | Name of a new branch to push the code into. Creates branch if not existing.                                                                                        |

### 📤 Output Parameters

| Output        | Description                                                                |
| ------------- | -------------------------------------------------------------------------- |
| files_changed | List of changed files, as returned by `git diff --staged --name-status`. |
| branch_name   | Name of the branch code was pushed into.                                   |


## 💻 Usage Examples

### 📝 Basic Example: Commit and Push to Current Branch

Commit and push changes to the currently checked out branch.

```yaml
name: Push changes
on:
  push
jobs:
  change-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      - name: Change something
        run: |
          find . -type f -name "*.md" -print0 | xargs -0 sed -i "s/foo/bar/g"
      - name: Commit and push changes
        uses: devops-infra/action-commit-push@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          commit_message: "Replace foo with bar"
```

### 🔀 Advanced Example: Commit, Push, and Create Pull Request

Commit and push changes to a new branch and create a pull request using [devops-infra/action-pull-request](https://github.com/devops-infra/action-pull-request).

```yaml
name: Push changes and create PR
on:
  push
jobs:
  change-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      - name: Change something
        run: |
          find . -type f -name "*.md" -print0 | xargs -0 sed -i "s/foo/bar/g"
      - name: Commit and push changes
        uses: devops-infra/action-commit-push@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          commit_prefix: "[AUTO-COMMIT] "
          commit_message: "Replace foo with bar"
      - name: Create pull request
        uses: devops-infra/action-pull-request@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          body: "**Automated pull request**<br><br>Replaced foo with bar"
          title: ${{ github.event.commits[0].message }}
```

### 💪 Force Push Example: Amending Previous Commit

When you need to amend the previous commit and force push (useful for fixing commit messages or adding forgotten changes).

```yaml
name: Amend and force push
on:
  workflow_dispatch:
    inputs:
      new_commit_message:
        description: 'New commit message'
        required: true
        default: 'Updated commit message'

jobs:
  amend-commit:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository with full history
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for force_with_lease
      - name: Make some changes
        run: |
          echo "Additional content" >> README.md
      - name: Amend and force push with lease
        uses: devops-infra/action-commit-push@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          commit_message: ${{ github.event.inputs.new_commit_message }}
          amend: true
          force_with_lease: true  # Safer force push option
```

### 📝 Amend Options

When using `amend: true`, you have several options for handling the commit message:

1. **Change the commit message**: Set `commit_message` to provide a new message
   ```yaml
   - uses: devops-infra/action-commit-push@master
     with:
       github_token: ${{ secrets.GITHUB_TOKEN }}
       commit_message: "Fixed typo in documentation"
       amend: true
       force_with_lease: true
   ```

2. **Keep existing message**: Set `no_edit: true` to keep the original commit message
   ```yaml
   - uses: devops-infra/action-commit-push@master
     with:
       github_token: ${{ secrets.GITHUB_TOKEN }}
       amend: true
       no_edit: true
       force_with_lease: true
   ```

3. **Default behavior**: If neither is set, uses "Files changed:" with file list (when files are modified)

**💡 Note:** Amending works even without file changes - useful for just changing commit messages!


## 🚀 Release Process

This action follows a **release-based Docker image deployment strategy**:

- **Development branches**: Only build and test Docker images (no push to Docker Hub)
- **Test branches (`test/*`)**: Build and push Docker images with `test-` prefix for integration testing
- **Master branch**: Only build and test Docker images (no push to Docker Hub)
- **Releases**: Docker images are built and pushed to Docker Hub only when a new GitHub release is created
- **Weekly builds**: Automated test builds run weekly and push test images

### 🏷️ Creating a New Release

1. Create a new GitHub release with a version tag (e.g., `v0.11.0`)
2. The release workflow automatically:
   - Builds multi-architecture Docker images (`amd64`, `arm64`)
   - Pushes images to Docker Hub with the release version tag
   - Updates the `action.yml` file to reference the new Docker image version
   - Updates Docker Hub description

### 🧪 Testing with Test Branches

For testing changes before creating a release:

1. Create a branch starting with `test/` (e.g., `test/new-feature`)
2. Push your changes to this branch
3. The workflow automatically builds and pushes Docker images with `test-` prefix
4. Use the test image in other workflows: `devopsinfra/action-commit-push:test-latest`

**This ensures that:**
- ✅ Master branch merges don't accidentally publish untested images
- ✅ Test branches provide safe testing environments
- ✅ Only stable, released versions are available on Docker Hub
- ✅ Users can pin to specific, tested versions
- ✅ Development and testing don't interfere with production images

## ⚠️ Force Push Options

This action provides two force push options for different scenarios:

### 🛡️ `force_with_lease` (Recommended)
- Uses `git push --force-with-lease`
- **Safer option** that checks if someone else has pushed changes to the remote branch
- Prevents accidentally overwriting other people's work
- **Required:** Set `fetch-depth: 0` in your `actions/checkout` step
- **Use case:** Amending commits, rebasing, or other history modifications

### ⚡ `force` (Use with Caution)
- Uses `git push --force` 
- **Potentially dangerous** as it will overwrite remote changes unconditionally
- No safety checks - will overwrite any remote changes
- **Use case:** Only when you're absolutely certain you want to overwrite remote changes

**⚠️ Important:** Never use both options simultaneously. `force_with_lease` takes precedence if both are set to `true`.


## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 🔗 Related Actions

- [devops-infra/action-pull-request](https://github.com/devops-infra/action-pull-request) - Create pull requests automatically
- [devops-infra/.github](https://github.com/devops-infra/.github) - Shared GitHub configuration and templates


## 💬 Support

If you have any questions or need help, please:
- 📝 Create an [issue](https://github.com/devops-infra/action-commit-push/issues)
- 💬 Start a [discussion](https://github.com/devops-infra/action-commit-push/discussions)
- 🌟 Star this repository if you find it useful!

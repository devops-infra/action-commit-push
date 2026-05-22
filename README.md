# 🚀 GitHub Action for committing changes to repository
**Powerful GitHub Action for automatically committing and pushing changes back to your repository.**


## 📦 Available on
- **Docker Hub:** [devopsinfra/action-commit-push:latest](https://hub.docker.com/repository/docker/devopsinfra/action-commit-push)
- **GitHub Packages:** [ghcr.io/devops-infra/action-commit-push:latest](https://github.com/orgs/devops-infra/packages/container/package/action-commit-push)


## ✨ Features
- **📝 Custom commit messages:** Add custom prefixes and messages to commits
- **🌿 Branch management:** Create new branches automatically with optional timestamps
- **⏰ Timestamp support:** Add timestamps to branch names for cron-based updates
- **🔄 Integration-ready:** Works seamlessly with other DevOps workflows
- **💪 Force push options:** Support for `--force` and `--force-with-lease` when needed
- **🔀 Pull request integration:** Perfect companion for automated PR workflows
- **🎯 Deterministic branch reset:** Optionally reset target branches to a chosen base branch before committing
- **🧩 Empty commit support:** Optionally create empty commits for no-diff automation flows
- **🛡️ Rebase conflict control:** Choose strict failure or legacy best-effort behavior on rebase conflicts


## 🔗 Related Actions
**Perfect for automation workflows and integrates seamlessly with [devops-infra/action-pull-request](https://github.com/devops-infra/action-pull-request).**


## 📊 Badges
[
![GitHub repo](https://img.shields.io/badge/GitHub-devops--infra%2Faction--commit--push-blueviolet.svg?style=plastic&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/action-commit-push?color=blueviolet&logo=github&style=plastic&label=Last%20commit)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/action-commit-push?color=blueviolet&label=Code%20size&style=plastic&logo=github)
![GitHub license](https://img.shields.io/github/license/devops-infra/action-commit-push?color=blueviolet&logo=github&style=plastic&label=License)
](https://github.com/devops-infra/action-commit-push "shields.io")
<br>
[
![DockerHub](https://img.shields.io/badge/DockerHub-devopsinfra%2Faction--commit--push-blue.svg?style=plastic&logo=docker)
![Docker version](https://img.shields.io/docker/v/devopsinfra/action-commit-push?color=blue&label=Version&logo=docker&style=plastic&sort=semver)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/action-commit-push/latest?label=Image%20size&style=plastic&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/action-commit-push?color=blue&label=Pulls&logo=docker&style=plastic)
](https://hub.docker.com/r/devopsinfra/action-commit-push "shields.io")


## 🏷️ Version Tags: vX, vX.Y, vX.Y.Z
This action supports three tag levels for flexible versioning:
- `vX`: latest patch of the major version (e.g., `v1`).
- `vX.Y`: latest patch of the minor version (e.g., `v1.2`).
- `vX.Y.Z`: fixed to a specific release (e.g., `v1.2.3`).




## 📖 API Reference

```yaml
      - name: Run the Action
        uses: devops-infra/action-commit-push@v1.3.0
        with:
          github_token: "${{ secrets.GITHUB_TOKEN }}"
          add_timestamp: true
          amend: false
          commit_prefix: "[AUTO]"
          commit_message: "Automatic commit"
          force: false
          force_with_lease: false
          no_edit: false
          organization_domain: github.com
          target_branch: update/version
```


### 🔧 Input Parameters
| Input Variable            | Required | Default          | Description                                                                                                                                                   |
|---------------------------|----------|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `github_token`            | Yes      | `""`             | Personal Access Token for GitHub for pushing the code.                                                                                                        |
| `add_timestamp`           | No       | `false`          | Whether to add the timestamp to a new branch name. Uses format `%Y-%m-%dT%H-%M-%SZ`.                                                                          |
| `amend`                   | No       | `false`          | Whether to make an amendment to the previous commit (`--amend`). Can be combined with `commit_message` to change the commit message.                          |
| `commit_prefix`           | No       | `""`             | Prefix added to commit message. Combines with `commit_message`.                                                                                               |
| `commit_message`          | No       | `""`             | Commit message to set. Combines with `commit_prefix`. Can be used with `amend` to change the commit message.                                                  |
| `force`                   | No       | `false`          | Whether to use force push (`--force`). Use only when you need to overwrite remote changes. Potentially dangerous.                                             |
| `force_with_lease`        | No       | `false`          | Whether to use force push with lease (`--force-with-lease`). Safer than `force` as it checks for remote changes. Set `fetch-depth: 0` for `actions/checkout`. |
| `base_branch`             | No       | `""`             | Base branch used to sync or reset `target_branch`. When empty, the action auto-detects `main`/`master` or origin HEAD.                                        |
| `reset_target_branch`     | No       | `false`          | Whether to hard-reset `target_branch` to `origin/base_branch` before committing. Recommended for deterministic release branches.                              |
| `allow_empty_commit`      | No       | `false`          | Whether to create an empty commit when there are no file changes. Useful for workflows that must open a PR with no file diff.                                 |
| `fail_on_rebase_conflict` | No       | `true`           | Whether to fail the action if rebase onto `base_branch` conflicts. Set to `false` to keep legacy best-effort rebase behavior.                                 |
| `no_edit`                 | No       | `false`          | Whether to not edit commit message when using amend (`--no-edit`).                                                                                            |
| `organization_domain`     | No       | `github.com`     | GitHub Enterprise domain name.                                                                                                                                |
| `target_branch`           | No       | *current branch* | Name of a new branch to push the code into. Creates branch if not existing unless there are no changes and `amend` is false.                                  |
| `repository_path`         | No       | `.`              | Relative path under `${{ github.workspace }}` where the repository is checked out. Set this when `actions/checkout` uses `path:`.                             |


### 📤 Output Parameters
| Output          | Description                                                              |
|-----------------|--------------------------------------------------------------------------|
| `files_changed` | List of changed files, as returned by `git diff --staged --name-status`. |
| `branch_name`   | Name of the branch code was pushed into.                                 |


## 💻 Usage Examples

### 📝 Basic Example
Commit and push changes to the currently checked out branch.

```yaml
name: Run the Action
on:
  push
jobs:
  change-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v5
      - name: Change something
        run: |
          find . -type f -name "*.md" -print0 | xargs -0 sed -i "s/foo/bar/g"

      - name: Commit and push changes
        uses: devops-infra/action-commit-push@v1.3.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          commit_message: "Replace foo with bar"
```

### 🔀 Advanced Example
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
        uses: actions/checkout@v5
      - name: Change something
        run: |
          find . -type f -name "*.md" -print0 | xargs -0 sed -i "s/foo/bar/g"

      - name: Commit and push changes
        uses: devops-infra/action-commit-push@v1.3.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          commit_prefix: "[AUTO-COMMIT] "
          commit_message: "Replace foo with bar"

      - name: Create pull request
        uses: devops-infra/action-pull-request@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          body: "**Automated pull request**<br><br>Replaced foo with bar"
          title: ${{ github.event.commits[0].message }}
```


### 💪 Force Push Example
When you need to amend the previous commit and force push (useful when adding automatic changes to manual commit).

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
        uses: actions/checkout@v5
        with:
          fetch-depth: 0  # Required for force_with_lease
      - name: Make some changes
        run: |
          echo "Additional content" >> README.md

      - name: Amend and force push with lease
        uses: devops-infra/action-commit-push@v1.3.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          commit_message: ${{ github.event.inputs.new_commit_message }}
          amend: true
          force_with_lease: true  # Safer force push option
```

### 📁 Custom checkout path example
Commit and push when `actions/checkout` uses a custom path.

```yaml
name: Commit from custom checkout path
on:
  push
jobs:
  change-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository into custom path
        uses: actions/checkout@v6
        with:
          path: work/repo

      - name: Change something in checked out repository
        run: |
          echo "Updated" >> work/repo/README.md

      - name: Commit and push changes
        uses: devops-infra/action-commit-push@v1.3.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          repository_path: work/repo
          commit_message: "Update README"
```

## 📝 Amend Options
When using `amend: true`, you have several options for handling the commit message:

1. **Change the commit message**: Set `commit_message` to provide a new message
   ```yaml
   - uses: devops-infra/action-commit-push@v1.3.0
     with:
       github_token: ${{ secrets.GITHUB_TOKEN }}
       commit_message: "Fixed typo in documentation"
       amend: true
       force_with_lease: true
   ```

2. **Keep existing message**: Set `no_edit: true` to keep the original commit message
   ```yaml
   - uses: devops-infra/action-commit-push@v1.3.0
     with:
       github_token: ${{ secrets.GITHUB_TOKEN }}
       amend: true
       no_edit: true
       force_with_lease: true
   ```

3. **Default behavior**: If neither is set, uses "Files changed:" with file list (when files are modified)

**💡 Note:** Amending works even without file changes - useful for just changing commit messages!


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


### 🎯 Use specific version
Pick the tag level based on your stability needs:
- `vX.Y.Z`: exact immutable release (most predictable)
- `vX.Y`: latest patch within one minor line
- `vX`: latest patch within one major line

```yaml
name: Run the Action
on:
  push:
    branches-ignore: master
jobs:
  action-commit-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5

      - uses: devops-infra/action-commit-push@v1.3.0
        id: Pin patch version

      - uses: devops-infra/action-commit-push@v1.1
        id: Pin minor version

      - uses: devops-infra/action-commit-push@v1
        id: Pin major version
```


## 🤝 Contributing
Contributions are welcome! See [CONTRIBUTING](https://github.com/devops-infra/.github/blob/master/CONTRIBUTING.md).
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 💬 Support
If you have any questions or need help, please:
- 📝 Create an [issue](https://github.com/devops-infra/action-commit-push/issues)
- 🌟 Star this repository if you find it useful!

## Forking
To publish images from a fork, set these variables so Task uses your registry identities:
`DOCKER_USERNAME`, `DOCKER_ORG_NAME`, `GITHUB_USERNAME`, `GITHUB_ORG_NAME`.

Two supported options (environment variables take precedence over `.env`):
```bash
# .env (local only, not committed)
DOCKER_USERNAME=your-dockerhub-user
DOCKER_ORG_NAME=your-dockerhub-org
GITHUB_USERNAME=your-github-user
GITHUB_ORG_NAME=your-github-org
```

```bash
# Shell override
DOCKER_USERNAME=your-dockerhub-user \
DOCKER_ORG_NAME=your-dockerhub-org \
GITHUB_USERNAME=your-github-user \
GITHUB_ORG_NAME=your-github-org \
task docker:build
```

Recommended setup:
- Local development: use a `.env` file.
- GitHub Actions: set repo variables for the four values above, and secrets for `DOCKER_TOKEN` and `GITHUB_TOKEN`.

Publish images without a release:
- Run the `(Manual) Release Create` workflow with `build_only: true` to build and push images without tagging a release.

# GitHub Action for committing changes to repository

GitHub Action that will create a new commit and push it to the repository.

Dockerized as [christophshyper/action-commit-push](https://hub.docker.com/repository/docker/christophshyper/action-commit-push).

An automatic commit is using username of the last person committing to checked-out branch. But `github_token` needs to be set for that person.

Can add a custom prefix to commit message by setting `commit_prefix`.

Can create a new branch when `branch_name` is set. Good to combine with `repo-sync/pull-request@v2` action. 

Can add a timestamp to a branch name, when `branch_name` is set and `add_timestamp` is `true`.


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-ChristophShyper%2Faction--commit--push-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/christophshyper/action-commit-push?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/christophshyper/action-commit-push?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/christophshyper/action-commit-push "shields.io")
[![Push to master](https://img.shields.io/github/workflow/status/christophshyper/action-commit-push/Push%20to%20master?color=brightgreen&label=Master%20branch&logo=github&style=flat-square)
](https://github.com/ChristophShyper/action-commit-push/actions?query=workflow%3A%22Push+to+master%22)
[![Push to other](https://img.shields.io/github/workflow/status/christophshyper/action-commit-push/Push%20to%20other?color=brightgreen&label=Pull%20requests&logo=github&style=flat-square)
](https://github.com/ChristophShyper/action-commit-push/actions?query=workflow%3A%22Push+to+other%22)
<br>
[
![DockerHub](https://img.shields.io/badge/docker-christophshyper%2Faction--commit--push-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/christophshyper/action-commit-push/Dockerfile?label=Dockerfile%20size&style=flat-square&logo=docker)
![Image size](https://img.shields.io/docker/image-size/christophshyper/action-commit-push/latest?label=Image%20size&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/action-commit-push?color=blue&label=Pulls&logo=docker&style=flat-square)
![Docker version](https://img.shields.io/docker/v/christophshyper/action-commit-push?color=blue&label=Version&logo=docker&style=flat-square)
](https://hub.docker.com/r/christophshyper/action-commit-push "shields.io")


## Reference

Input Variable | Required | Default |Description
:--- | :---: | :---: | :---
github_token | Yes | `""` | Personal Access Token for GitHub for pushing the code.
commit_prefix | No | `[AUTO-COMMIT]` | Prefix added to commit message.
branch_name | No | `auto-branch` | Name of a new branch to push the code into.
add_timestamp | No | `false` | Whether to add the timestamp to a new branch name. Used when branch_name is set.

Outputs | Description
:--- | :---
files_changed | List of changed files. As returned by `git diff --staged --name-status`.


## Examples

Commit and push changes to currently checked out branch. Run the Action via GitHub.
```yaml
name: Push changes
on:
  push
jobs:
  change-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - name: Change something
        run: |
          find . -type f -name "*" -print0 | xargs -0 sed -i "s/foo/bar/g"
      - name: Commit and push changes
        uses: ChristophShyper/action-commit-push:master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

Commit and push changes to a new branch and create pull request using [repo-sync/pull-request](https://github.com/repo-sync/pull-request). Run the Action via DockerHub.
```yaml
name: Push changes
on:
  push
jobs:
  change-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - name: Change something
        run: |
          find . -type f -name "*" -print0 | xargs -0 sed -i "s/foo/bar/g"
      - name: Commit and push changes
        uses: docker://christophshyper/action-commit-push:latest
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          branch_name: enhancement/foo-bar
          commit_prefix: "[AUTO-COMMIT][foo/bar replace]"
      - name: Create pull request - other (conditional)
        uses: repo-sync/pull-request@v2
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          pr_label: "foo-bar"
          pr_body: "**Automated pull request**<br><br>Replaced foo/bar"
          pr_title: "${{ github.event.commits[0].message }}"
          pr_assignee: "${{ github.actor }}"
```

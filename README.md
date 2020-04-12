# GitHub Action template

Dockerized ([christophshyper/action-commit-push](https://hub.docker.com/repository/docker/christophshyper/action-commit-push)) GitHub Action that will create a new commit and push it back to the repository.

*WORK IN PROGRESS*

## Badge swag
[
![GitHub](https://img.shields.io/badge/github-ChristophShyper%2Faction--commit--push-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/christophshyper/action-commit-push?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/christophshyper/action-commit-push?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/christophshyper/action-commit-push "shields.io")
[![Push to master](https://img.shields.io/github/workflow/status/christophshyper/action-commit-push/Push%20to%20master?color=brightgreen&label=Master%20branch&logo=github&style=flat-square)
](https://github.com/ChristophShyper/action-commit-push/actions?query=workflow%3A%22Push+to+master%22)
[![Push to other](https://img.shields.io/github/workflow/status/christophshyper/action-commit-push/Push%20to%20other?color=brightgreen&label=Other%20branches&logo=github&style=flat-square)
](https://github.com/ChristophShyper/action-commit-push/actions?query=workflow%3A%22Push+to+other%22)
[
![DockerHub](https://img.shields.io/badge/docker-christophshyper%2Faction--commit--push-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/christophshyper/action-commit-push/Dockerfile?label=Dockerfile&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/action-commit-push?color=blue&label=Pulls&logo=docker&style=flat-square)
![Docker version](https://img.shields.io/docker/v/christophshyper/action-commit-push?color=blue&label=Version&logo=docker&style=flat-square)
](https://hub.docker.com/r/christophshyper/action-commit-push "shields.io")


## Usage

Input Variable | Required | Default |Description
:--- | :---: | :---: | :---
fail_on_error | No | `false` | Whether error in main function should fail the whole Action. 
github_token | No* | `""` | Personal Access Token for GitHub.
push_changes | No | `false` | Whether changes should be pushed back to the current branch. Excludes `fail_on_error`.

*If `push_changes` is set to `true` then `fail_on_error` will be treated as `false`.*

*If `push_changes` is set to `true` then `github_token` is required* 

## Examples

Run the Action building Docker image on a run time. Allows default values for inputs.
```yaml
name: Run the Action on each commit
on:
  push
jobs:
  terraform-copy-vars:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v2
    - name: Run the Action
      uses: ChristophShyper/action-commit-push:master
```

Run the Action using image from DockerHub. All inputs need to be defined.
```yaml
name: Run the Action on each commit
on:
  push
jobs:
  terraform-copy-vars:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repoistory
      uses: actions/checkout@v2
    - name: Run the Action
      uses: docker://christophshyper/action-commit-push:latest
      with:
        fail_on_error: true
        github_token: ${{ secrets.GITHUB_TOKEN }}
        push_changes: true
```

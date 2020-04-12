# GitHub Action template

Dockerized ([christophshyper/template-action](https://hub.docker.com/repository/docker/christophshyper/template-action)) GitHub Action template.

This is just a template repository.


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-ChristophShyper%2Ftemplate--action-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/christophshyper/template-action?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/christophshyper/template-action?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/christophshyper/template-action "shields.io")
[![Push to master](https://img.shields.io/github/workflow/status/christophshyper/template-action/Push%20to%20master?color=brightgreen&label=Master%20branch&logo=github&style=flat-square)
](https://github.com/ChristophShyper/template-action/actions?query=workflow%3A%22Push+to+master%22)
[![Push to other](https://img.shields.io/github/workflow/status/christophshyper/template-action/Push%20to%20other?color=brightgreen&label=Other%20branches&logo=github&style=flat-square)
](https://github.com/ChristophShyper/template-action/actions?query=workflow%3A%22Push+to+other%22)
[
![DockerHub](https://img.shields.io/badge/docker-christophshyper%2Ftemplate--action-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/christophshyper/template-action/Dockerfile?label=Dockerfile&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/template-action?color=blue&label=Pulls&logo=docker&style=flat-square)
![Docker version](https://img.shields.io/docker/v/christophshyper/template-action?color=blue&label=Version&logo=docker&style=flat-square)
](https://hub.docker.com/r/christophshyper/template-action "shields.io")


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
      uses: ChristophShyper/template-action:master
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
      uses: docker://christophshyper/template-action:latest
      with:
        fail_on_error: true
        github_token: ${{ secrets.GITHUB_TOKEN }}
        push_changes: true
```

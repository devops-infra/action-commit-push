#!/usr/bin/env bash

set -e

# github_token required
if [[ -z "${INPUT_GITHUB_TOKEN}" && ${INPUT_PUSH_CHANGES} == "true" ]]; then
  MESSAGE='Missing variable "github_token: ${{ secrets.GITHUB_TOKEN }}".'
  echo "[ERROR] ${MESSAGE}"
  exit 1
fi

# Run main action
echo "GitHub Action template"
RET_CODE=$?

# List of changed files
FILES_CHANGED=$(git diff --name-only)

# Get the name of the current branch
BRANCH=${GITHUB_REF/refs\/heads\//}

# Info about formatted files
if [[ ! -z ${FILES_CHANGED} ]]; then
  echo " "
  echo "[INFO] Updated files:"
  for FILE in ${FILES_CHANGED}; do
    echo "- ${FILE}"
  done
  echo " "
else
  echo " "
  echo "[INFO] No files updated."
  echo " "
fi

# Create auto commit
if [[ ${INPUT_PUSH_CHANGES} == "true" && ! -z ${FILES_CHANGED} ]]; then
  # Create auto commit
  echo " "
  REPO_URL="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  git config --global user.name ${GITHUB_ACTOR}
  git config --global user.email ${GITHUB_ACTOR}@users.noreply.github.com
  git commit -am "[AUTO][GitHub Action template] Updated files" -m "${FILES_CHANGED}"
  git push ${REPO_URL} HEAD:${BRANCH}
  echo " "
  echo "[INFO] No errors found."
  echo " "
  exit 0
fi

# Fail if needed
if [[ ${INPUT_FAIL_ON_ERROR} == "true" && ${RET_CODE} != "0" ]]; then
  echo " "
  echo "[ERROR] Check log for errors."
  echo " "
  exit 1
else
  # Pass in other cases
  echo " "
  echo "[INFO] No errors found."
  echo " "
  exit 0
fi

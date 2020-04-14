#!/usr/bin/env bash

set -e

# Return code
RET_CODE=0

echo "Inputs:"
echo "commit_prefix: ${INPUT_COMMIT_PREFIX}"
echo "branch_name:   ${INPUT_BRANCH_NAME}"
echo "add_timestamp: ${INPUT_ADD_TIMESTAMP}"
echo " "

# Required github_token
if [[ -z "${INPUT_GITHUB_TOKEN}" ]]; then
  MESSAGE='Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".'
  echo "[ERROR] ${MESSAGE}"
  exit 1
fi

# Get changed files
FILES_MODIFIED=$(git diff --name-status)
FILES_ADDED=$(git diff --staged --name-status)
FILES_CHANGED=$(echo -e "${FILES_MODIFIED}\n${FILES_ADDED}")
if [[ -n ${FILES_CHANGED} ]]; then
  echo " "
  echo -e "[INFO] Files changed:\n${FILES_CHANGED}"
  echo " "
else
  echo " "
  echo "[INFO] No files changed."
  echo " "
fi

# Set branch name
BRANCH="${GITHUB_REF/refs\/heads\//}"
if [[ -n "${INPUT_BRANCH_NAME}" && -n ${FILES_CHANGED} ]]; then
  BRANCH="${INPUT_BRANCH_NAME}"
fi

# Add timestamp to branch name
if [[ "${INPUT_ADD_TIMESTAMP}" == "true" && -n ${FILES_CHANGED} ]]; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
  BRANCH="${BRANCH}-${TIMESTAMP}"
fi

# Create a new branch
if [[ (-n "${INPUT_BRANCH_NAME}" || "${INPUT_ADD_TIMESTAMP}" == "true") && -n ${FILES_CHANGED} ]]; then
  echo "[INFO] Creating a new branch: ${BRANCH}"
  git checkout -b "${BRANCH}"
fi

# Create an auto commit
if [[ -n ${FILES_CHANGED} ]]; then
  echo "[INFO] Committing and pushing changes."
  git config --global user.name "${GITHUB_ACTOR}"
  git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  git add -A
  git commit -am "${INPUT_COMMIT_PREFIX} Files changed:" -m "${FILES_CHANGED}" --allow-empty
  git push -u origin "${BRANCH}"
  git branch -d "${BRANCH}"
fi

# Finish
echo "::set-output name=files_changed::${FILES_CHANGED}"
echo "::set-output name=branch_name::${BRANCH}"
if [[ ${RET_CODE} != "0" ]]; then
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

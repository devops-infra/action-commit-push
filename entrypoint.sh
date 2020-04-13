#!/usr/bin/env bash

set -e

# Required github_token
if [[ -z "${INPUT_GITHUB_TOKEN}" ]]; then
  MESSAGE='Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".'
  echo "[ERROR] ${MESSAGE}"
  exit 1
fi

# Set default prefix for commit
if [[ -z "${INPUT_COMMIT_PREFIX}" ]]; then
  INPUT_COMMIT_PREFIX="[AUTO-COMMIT]"
fi

# Get changed files
FILES_CHANGED=$(git diff --staged --name-status)
if [[ -n ${FILES_CHANGED} ]]; then
  echo " "
  echo "[INFO] Files changed:"
  for FILE in ${FILES_CHANGED}; do
    echo "${FILE}"
  done
  echo " "
else
  echo " "
  echo "[INFO] No files changed."
  echo " "
fi

# Set branch name
BRANCH="${GITHUB_REF/refs\/heads\//}"
if [[ -z "${INPUT_BRANCH_NAME}" ]]; then
  BRANCH="${INPUT_BRANCH_NAME}"
  git checkout -b "${BRANCH}"
  # add timestamp to branch name
  if [[ "${INPUT_ADD_TIMESTAMP}" == "true" ]]; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
    BRANCH="${BRANCH}-${TIMESTAMP}"
  fi
fi

# Create auto commit
if [[ -z ${FILES_CHANGED} ]]; then
  git config --global user.name "${GITHUB_ACTOR}"
  git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  git add -A
  git commit -am "${INPUT_COMMIT_PREFIX} Files changed:" -m "${FILES_CHANGED}" --allow-empty
  git push --set-upstream origin "${BRANCH}"
fi

# Finish
echo "::set-output name=foobar::${INPUT_BAZ}"
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

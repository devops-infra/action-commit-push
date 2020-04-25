#!/usr/bin/env bash

set -e

# Return code
RET_CODE=0

echo "Inputs:"
echo "  commit_prefix: ${INPUT_COMMIT_PREFIX}"
echo "  target_branch:   ${INPUT_TARGET_BRANCH}"
echo "  add_timestamp: ${INPUT_ADD_TIMESTAMP}"

# Require github_token
if [[ -z "${GITHUB_TOKEN}" ]]; then
  # shellcheck disable=SC2016
  MESSAGE='Missing env var "github_token: ${{ secrets.GITHUB_TOKEN }}".'
  echo -e "[ERROR] ${MESSAGE}"
  exit 1
fi

# Get changed files
FILES_MODIFIED=$(git diff --name-status)
FILES_ADDED=$(git diff --staged --name-status)
FILES_CHANGED=$(echo -e "${FILES_MODIFIED}\n${FILES_ADDED}")
if [[ -n ${FILES_CHANGED} ]]; then
  echo -e "\n[INFO] Files changed:\n${FILES_CHANGED}"
else
  echo -e "\n[INFO] No files changed."
fi

# Setting branch name
BRANCH="${INPUT_TARGET_BRANCH:-$(git symbolic-ref --short -q HEAD)}"

# Add timestamp to branch name
if [[ "${INPUT_ADD_TIMESTAMP}" == "true" && -n ${FILES_CHANGED} ]]; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
  BRANCH="${BRANCH}-${TIMESTAMP}"
fi

echo -e "\n[INFO] Target branch: ${BRANCH}"

# Create a new branch
if [[ (-n "${INPUT_TARGET_BRANCH}" || "${INPUT_ADD_TIMESTAMP}" == "true") && -n ${FILES_CHANGED} ]]; then
  git checkout -b "${BRANCH}"
fi

# Create an auto commit
if [[ -n ${FILES_CHANGED} ]]; then
  echo "[INFO] Committing and pushing changes."
  git remote set-url origin "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}"
  git config --global user.name "${GITHUB_ACTOR}"
  git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  git add -A
  git commit -am "${INPUT_COMMIT_PREFIX} Files changed:" -m "${FILES_CHANGED}" --allow-empty
  git push origin "${BRANCH}"
fi

# Finish
echo "::set-output name=files_changed::${FILES_CHANGED}"
echo "::set-output name=branch_name::${BRANCH}"
if [[ ${RET_CODE} != "0" ]]; then
  echo -e "\n[ERROR] Check log for errors."
  exit 1
else
  # Pass in other cases
  echo -e "\n[INFO] No errors found."
  exit 0
fi

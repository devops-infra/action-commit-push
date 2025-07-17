#!/usr/bin/env bash

set -e

# Return code
RET_CODE=0

echo "Inputs:"
echo "  add_timestamp:       ${INPUT_ADD_TIMESTAMP}"
echo "  amend:               ${INPUT_AMEND}"
echo "  commit_prefix:       ${INPUT_COMMIT_PREFIX}"
echo "  commit_message:      ${INPUT_COMMIT_MESSAGE}"
echo "  force:               ${INPUT_FORCE}"
echo "  force_with_lease:    ${INPUT_FORCE_WITH_LEASE}"
echo "  no_edit:             ${INPUT_NO_EDIT}"
echo "  organization_domain: ${INPUT_ORGANIZATION_DOMAIN}"
echo "  target_branch:       ${INPUT_TARGET_BRANCH}"

# Require github_token
if [[ -z "${GITHUB_TOKEN}" ]]; then
  # shellcheck disable=SC2016
  MESSAGE='Missing env var "github_token: ${{ secrets.GITHUB_TOKEN }}".'
  echo -e "[ERROR] ${MESSAGE}"
  exit 1
fi

# Set git credentials
git config --global safe.directory "${GITHUB_WORKSPACE}"
git config --global safe.directory /github/workspace
git remote set-url origin "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@${INPUT_ORGANIZATION_DOMAIN}/${GITHUB_REPOSITORY}"
git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.${INPUT_ORGANIZATION_DOMAIN}"

# Get changed files
git add -A
FILES_CHANGED=$(git diff --staged --name-status)
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
  if [[ -n ${BRANCH} ]]; then
    BRANCH="${BRANCH}-${TIMESTAMP}"
  else
    BRANCH="${TIMESTAMP}"
  fi
fi
echo -e "\n[INFO] Target branch: ${BRANCH}"

# Create a new branch
if [[ (-n "${INPUT_TARGET_BRANCH}" || "${INPUT_ADD_TIMESTAMP}" == "true") && -n ${FILES_CHANGED} ]]; then
  git checkout -b "${BRANCH}"
fi

# Create an auto commit
COMMIT_PARAMS=()
COMMIT_PARAMS+=("--allow-empty")

# Commit if there are changes OR if we're amending (even without changes)
if [[ -n ${FILES_CHANGED} || "${INPUT_AMEND}" == "true" ]]; then
  if [[ -n ${FILES_CHANGED} ]]; then
    echo "[INFO] Committing changes."
  fi
  
  if [[ "${INPUT_AMEND}" == "true" ]]; then
    COMMIT_PARAMS+=("--amend")
    echo "[INFO] Amending previous commit."
  fi
  
  if [[ "${INPUT_NO_EDIT}" == "true" ]]; then
    COMMIT_PARAMS+=("--no-edit")
    echo "[INFO] Using existing commit message (--no-edit)."
    git commit "${COMMIT_PARAMS[@]}"
  elif [[ -n "${INPUT_COMMIT_MESSAGE}" || -n "${INPUT_COMMIT_PREFIX}" ]]; then
    COMMIT_MESSAGE="${INPUT_COMMIT_PREFIX}${INPUT_COMMIT_MESSAGE}"
    if [[ "${INPUT_AMEND}" == "true" ]]; then
      echo "[INFO] Setting new commit message: ${COMMIT_MESSAGE}"
    fi
    
    if [[ -n ${FILES_CHANGED} ]]; then
      git commit "${COMMIT_PARAMS[@]}" -am "${COMMIT_MESSAGE}" -m "$(echo -e "Files changed:\n${FILES_CHANGED}")"
    else
      git commit "${COMMIT_PARAMS[@]}" -m "${COMMIT_MESSAGE}"
    fi
  elif [[ -n ${FILES_CHANGED} ]]; then
    git commit "${COMMIT_PARAMS[@]}" -am "Files changed:" -m "${FILES_CHANGED}"
  else
    # Amending without files changed and no new message - keep existing message
    COMMIT_PARAMS+=("--no-edit")
    git commit "${COMMIT_PARAMS[@]}"
  fi
fi

# Push
if [[ "${INPUT_FORCE}" == "true" ]]; then
  echo "[INFO] Force pushing changes using --force"
  git push --force origin "${BRANCH}"
elif [[ "${INPUT_FORCE_WITH_LEASE}" == "true" ]]; then
  echo "[INFO] Force pushing changes with lease"
  git push --force-with-lease origin "${BRANCH}"
elif [[ -n ${FILES_CHANGED} || "${INPUT_AMEND}" == "true" ]]; then
  echo "[INFO] Pushing changes"
  git push origin "${BRANCH}"
fi

# Finish
{
  echo "files_changed<<EOF"
  echo -e "${FILES_CHANGED}"
  echo "EOF"
  echo "branch_name=${BRANCH}"
} >> "${GITHUB_OUTPUT}"
if [[ ${RET_CODE} != "0" ]]; then
  echo -e "\n[ERROR] Check log for errors."
  exit 1
else
  # Pass in other cases
  echo -e "\n[INFO] No errors found."
  exit 0
fi

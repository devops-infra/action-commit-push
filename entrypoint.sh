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
if [[ "${INPUT_ADD_TIMESTAMP}" == "true" ]]; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
  if [[ -n ${BRANCH} ]]; then
    BRANCH="${BRANCH}-${TIMESTAMP}"
  else
    BRANCH="${TIMESTAMP}"
  fi
fi
echo -e "\n[INFO] Target branch: ${BRANCH}"

# Enhanced branch handling with proper remote synchronization
if [[ -n "${INPUT_TARGET_BRANCH}" || "${INPUT_ADD_TIMESTAMP}" == "true" ]]; then
  # Fetch latest changes from remote
  echo "[INFO] Fetching latest changes from remote..."
  git fetch origin || {
    echo "[WARNING] Could not fetch from remote. Proceeding with local operations."
  }

  # Check if remote branch exists
  REMOTE_BRANCH_EXISTS=$(git ls-remote --heads origin "${BRANCH}" 2>/dev/null | wc -l)

  # Improved main branch detection
  MAIN_BRANCH="main"
  if git show-ref --verify --quiet "refs/remotes/origin/main"; then
    MAIN_BRANCH="main"
  elif git show-ref --verify --quiet "refs/remotes/origin/master"; then
    MAIN_BRANCH="master"
  else
    # Try to get default branch from remote HEAD
    MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
  fi
  echo "[INFO] Detected main branch: ${MAIN_BRANCH}"

  if [[ ${REMOTE_BRANCH_EXISTS} -gt 0 ]]; then
    echo "[INFO] Remote branch '${BRANCH}' exists, checking out and updating..."
    # Check if local branch exists
    if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
      echo "[INFO] Local branch '${BRANCH}' exists, switching to it..."
      git checkout "${BRANCH}" || {
        echo "[ERROR] Failed to checkout branch ${BRANCH}"
        exit 1
      }
    else
      echo "[INFO] Creating local branch '${BRANCH}' from remote..."
      git checkout -b "${BRANCH}" "origin/${BRANCH}" || {
        echo "[ERROR] Failed to create local branch from remote"
        exit 1
      }
    fi

    # Ensure branch is up-to-date with main/master (only if they're different branches)
    if [[ "${BRANCH}" != "${MAIN_BRANCH}" ]] && git show-ref --verify --quiet "refs/remotes/origin/${MAIN_BRANCH}"; then
      echo "[INFO] Rebasing branch onto ${MAIN_BRANCH}..."
      git rebase "origin/${MAIN_BRANCH}" || {
        echo "[WARNING] Rebase onto ${MAIN_BRANCH} failed. This may indicate conflicts."
        echo "[INFO] Attempting to abort the rebase and continue without sync..."
        git rebase --abort 2>/dev/null || true
        echo "[INFO] Branch will remain at its current state without sync to ${MAIN_BRANCH}"
      }
    fi
  else
    echo "[INFO] Remote branch '${BRANCH}' does not exist, creating new branch..."
    # Ensure starting from the latest main/master
    if git show-ref --verify --quiet "refs/remotes/origin/${MAIN_BRANCH}"; then
      echo "[INFO] Creating branch from latest ${MAIN_BRANCH}..."
      git checkout -b "${BRANCH}" "origin/${MAIN_BRANCH}" || {
        echo "[ERROR] Failed to create branch from ${MAIN_BRANCH}"
        exit 1
      }
    else
      echo "[INFO] Creating branch from current HEAD..."
      git checkout -b "${BRANCH}" || {
        echo "[ERROR] Failed to create branch from HEAD"
        exit 1
      }
    fi
  fi
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
elif [[ -n ${FILES_CHANGED} || "${INPUT_AMEND}" == "true" || -n "${INPUT_TARGET_BRANCH}" ]]; then
  echo "[INFO] Pushing changes"
  # Check if branch has upstream tracking
  if git rev-parse --abbrev-ref "${BRANCH}@{upstream}" >/dev/null 2>&1; then
    echo "[INFO] Branch has upstream, pushing normally"
    git push origin "${BRANCH}"
  else
    echo "[INFO] Branch has no upstream, setting upstream on push"
    git push -u origin "${BRANCH}"
  fi
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

#!/usr/bin/env bash

set -e

# Detect the operating system
OS_TYPE="$(uname -s)"
echo "Running on OS: $OS_TYPE"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not available. This action requires Docker to be installed."
    echo "On Windows runners, please ensure Docker Desktop or similar is installed."
    echo "On Linux/macOS runners, Docker should be available by default."
    exit 1
fi

# Docker image to use
DOCKER_IMAGE="docker://devopsinfra/action-commit-push:v0.10.0"

# Prepare environment variables for docker run
ENV_ARGS=()
ENV_ARGS+=("-e" "GITHUB_TOKEN=${GITHUB_TOKEN}")
ENV_ARGS+=("-e" "GITHUB_ACTOR=${GITHUB_ACTOR}")
ENV_ARGS+=("-e" "GITHUB_REPOSITORY=${GITHUB_REPOSITORY}")
ENV_ARGS+=("-e" "GITHUB_WORKSPACE=${GITHUB_WORKSPACE}")
ENV_ARGS+=("-e" "GITHUB_OUTPUT=${GITHUB_OUTPUT}")

# Add input environment variables
ENV_ARGS+=("-e" "INPUT_ADD_TIMESTAMP=${INPUT_ADD_TIMESTAMP}")
ENV_ARGS+=("-e" "INPUT_AMEND=${INPUT_AMEND}")
ENV_ARGS+=("-e" "INPUT_COMMIT_PREFIX=${INPUT_COMMIT_PREFIX}")
ENV_ARGS+=("-e" "INPUT_COMMIT_MESSAGE=${INPUT_COMMIT_MESSAGE}")
ENV_ARGS+=("-e" "INPUT_FORCE=${INPUT_FORCE}")
ENV_ARGS+=("-e" "INPUT_FORCE_WITHOUT_LEASE=${INPUT_FORCE_WITHOUT_LEASE}")
ENV_ARGS+=("-e" "INPUT_NO_EDIT=${INPUT_NO_EDIT}")
ENV_ARGS+=("-e" "INPUT_ORGANIZATION_DOMAIN=${INPUT_ORGANIZATION_DOMAIN}")
ENV_ARGS+=("-e" "INPUT_TARGET_BRANCH=${INPUT_TARGET_BRANCH}")

# Volume mount arguments
VOLUME_ARGS=()
VOLUME_ARGS+=("-v" "${GITHUB_WORKSPACE}:/github/workspace")

# Working directory
WORK_DIR="/github/workspace"

# Remove docker:// prefix from image name if present
DOCKER_IMAGE_NAME="${DOCKER_IMAGE#docker://}"

echo "Using Docker image: $DOCKER_IMAGE_NAME"
echo "Workspace: $GITHUB_WORKSPACE"

# Attempt to pull the image if it doesn't exist locally
if ! docker image inspect "$DOCKER_IMAGE_NAME" &> /dev/null; then
    echo "Docker image not found locally, attempting to pull: $DOCKER_IMAGE_NAME"
    if ! docker pull "$DOCKER_IMAGE_NAME"; then
        echo "Error: Failed to pull Docker image: $DOCKER_IMAGE_NAME"
        echo "Please ensure the image exists and is accessible."
        exit 1
    fi
fi

# Run the Docker container
echo "Running Docker container..."
docker run --rm \
  "${ENV_ARGS[@]}" \
  "${VOLUME_ARGS[@]}" \
  -w "$WORK_DIR" \
  "$DOCKER_IMAGE_NAME"
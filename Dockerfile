# Use a clean tiny image to store artifacts in
FROM ubuntu:24.04

# Disable interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Multi-architecture from buildx
ARG TARGETPLATFORM

# Copy all needed files
COPY entrypoint.sh /

# Install needed packages
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN chmod +x /entrypoint.sh ;\
  apt-get update -y ;\
  apt-get install --no-install-recommends -y \
    gpg-agent \
    software-properties-common ;\
  echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections ;\
  add-apt-repository ppa:git-core/ppa ;\
  apt-get update -y ;\
  apt-get install --no-install-recommends -y \
    git ;\
  # Install git-lfs without post-install configuration to avoid dpkg errors
  apt-get download git-lfs ;\
  dpkg --unpack git-lfs*.deb ;\
  rm -f /var/lib/dpkg/info/git-lfs.postinst ;\
  dpkg --configure git-lfs ;\
  apt-get install -f --no-install-recommends -y ;\
  rm git-lfs*.deb ;\
  apt-get clean ;\
  rm -rf /var/lib/apt/lists/*


# Labels for http://label-schema.org/rc1/#build-time-labels
# And for https://github.com/opencontainers/image-spec/blob/master/annotations.md
# And for https://help.github.com/en/actions/building-actions/metadata-syntax-for-github-actions
ARG NAME="GitHub Action for committing changes to a repository"
ARG DESCRIPTION="GitHub Action that will create a new commit and push it back to the repository"
ARG REPO_URL="https://github.com/devops-infra/action-commit-push"
ARG AUTHOR="Krzysztof Szyper / ChristophShyper / biotyk@mail.com"
ARG HOMEPAGE="https://shyper.pro"
ARG BUILD_DATE=2020-04-01T00:00:00Z
ARG VCS_REF=abcdef1
ARG VERSION=v0.0
LABEL \
  com.github.actions.name="${NAME}" \
  com.github.actions.author="${AUTHOR}" \
  com.github.actions.description="${DESCRIPTION}" \
  com.github.actions.color="purple" \
  com.github.actions.icon="upload-cloud" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="${NAME}" \
  org.label-schema.description="${DESCRIPTION}" \
  org.label-schema.usage="README.md" \
  org.label-schema.url="${HOMEPAGE}" \
  org.label-schema.vcs-url="${REPO_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.vendor="${AUTHOR}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.schema-version="1.0"	\
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.authors="${AUTHOR}" \
  org.opencontainers.image.url="${HOMEPAGE}" \
  org.opencontainers.image.documentation="${REPO_URL}/blob/master/README.md" \
  org.opencontainers.image.source="${REPO_URL}" \
  org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.revision="${VCS_REF}" \
  org.opencontainers.image.vendor="${AUTHOR}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.title="${NAME}" \
  org.opencontainers.image.description="${DESCRIPTION}" \
  maintainer="${AUTHOR}" \
  repository="${REPO_URL}"

# Finish up
WORKDIR /github/workspace
ENTRYPOINT ["/entrypoint.sh"]

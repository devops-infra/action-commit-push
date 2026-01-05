FROM ubuntu:questing-20251217

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive

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
  # Install git-lfs without post-install configuration to avoid dpkg errors \
  apt-get download git-lfs ;\
  dpkg --unpack git-lfs*.deb ;\
  rm -f /var/lib/dpkg/info/git-lfs.postinst ;\
  dpkg --configure git-lfs ;\
  apt-get install -f --no-install-recommends -y ;\
  rm git-lfs*.deb ;\
  apt-get clean ;\
  rm -rf /var/lib/apt/lists/*

# Finish up
WORKDIR /github/workspace
ENTRYPOINT ["/entrypoint.sh"]

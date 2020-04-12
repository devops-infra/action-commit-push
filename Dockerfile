# Use a clean tiny image to store artifacts in
FROM alpine:3.11

ARG BUILD_DATE=2020-04-01T00:00:00Z
ARG VCS_REF=abcdef1
ARG VERSION=v0.0
# For http://label-schema.org/rc1/#build-time-labels
LABEL \
  com.github.actions.author="Krzysztof Szyper <biotyk@mail.com>" \
  com.github.actions.color="white" \
  com.github.actions.description="Template repository for GitHub Actions." \
  com.github.actions.icon="wind" \
  com.github.actions.name="GitHub Action template" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.description="Template repository for GitHub Actions." \
  org.label-schema.name="action-commit-push" \
  org.label-schema.schema-version="1.0"	\
  org.label-schema.url="https://christophshyper.github.io/" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.vcs-url="https://github.com/ChristophShyper/action-commit-push" \
  org.label-schema.vendor="Krzysztof Szyper <biotyk@mail.com>" \
  org.label-schema.version="${VERSION}" \
  maintainer="Krzysztof Szyper <biotyk@mail.com>" \
  repository="https://github.com/ChristophShyper/action-commit-push"

# Copy all needed files
COPY entrypoint.sh /

# Install needed packages
RUN set -eux \
  && chmod +x /entrypoint.sh \
  && apk update --no-cache \
  && apk upgrade --no-cache \
  && apk add --no-cache bash \
  && apk add --no-cache git \
  # Insert here
  && rm -rf /var/cache/* \
  && rm -rf /root/.cache/*

# Finish up
WORKDIR /github/workspace
ENTRYPOINT /entrypoint.sh

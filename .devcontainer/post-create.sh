#!/usr/bin/env bash
# Dev-environment setup: lint tooling for the Dockerfile and CI scripts.
# Kept intentionally small — this repo's product is a Dockerfile + a
# release workflow, so the toolbox is just "build, lint, push".
set -euo pipefail

ARCH="$(uname -m)"

# hadolint — Dockerfile linter.
HADOLINT_VERSION="v2.12.0"
case "${ARCH}" in
  x86_64) HADOLINT_ARCH="x86_64" ;;
  aarch64 | arm64) HADOLINT_ARCH="arm64" ;;
  *) HADOLINT_ARCH="x86_64" ;;
esac
sudo curl -fsSL \
  "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-${HADOLINT_ARCH}" \
  -o /usr/local/bin/hadolint
sudo chmod +x /usr/local/bin/hadolint

# shellcheck — shell-script linter (CI helper scripts).
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends shellcheck
sudo rm -rf /var/lib/apt/lists/*

echo "post-create complete: $(hadolint --version), $(shellcheck --version | sed -n '2p')"

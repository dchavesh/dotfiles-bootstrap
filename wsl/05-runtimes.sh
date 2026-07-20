#!/usr/bin/env bash
# Go (pinned tarball), Ruby, Java — plain installs, no version managers.
#
# NOTE: rustup, sdkman, rbenv, pyenv and nvm are intentionally NOT installed —
# none of them were part of the source machine's toolchain. Add a step here
# if that changes; don't install speculatively.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

apt_ensure ruby default-jdk

GO_VERSION="1.26.2"
if have_cmd go && [ "$(go version | awk '{print $3}')" = "go${GO_VERSION}" ]; then
  log_ok "go${GO_VERSION}"
else
  log_install "go${GO_VERSION}"
  ARCH="$(dpkg --print-architecture)"
  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o /tmp/go.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm -f /tmp/go.tar.gz
fi

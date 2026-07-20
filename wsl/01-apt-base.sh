#!/usr/bin/env bash
# Adds the GitHub CLI apt repo and installs the curated base package list.
# (Google Chrome gets its own repo automatically in 07-chrome-playwright.sh.)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$(cd .. && pwd)"
source lib/common.sh

NEED_UPDATE=0

if [ -f /etc/apt/sources.list.d/github-cli.list ]; then
  log_ok "github-cli apt repo"
else
  log_install "github-cli apt repo"
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  NEED_UPDATE=1
fi

if [ "$NEED_UPDATE" = "1" ] || [ ! -d /var/lib/apt/lists ] || [ -z "$(ls -A /var/lib/apt/lists 2>/dev/null)" ]; then
  sudo apt-get update
fi

mapfile -t PACKAGES < <(grep -vE '^\s*(#|$)' "$REPO_ROOT/packages/apt-packages.txt")
apt_ensure "${PACKAGES[@]}"

#!/usr/bin/env bash
# Native WSL installs of awscli v2 and azure-cli — replaces the old
# ~/.aws / ~/.azure symlink-into-Windows-profile pattern (decided: native).
# Does NOT run `aws configure` / `az login` — interactive, see ../docs/manual-steps.md.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

apt_ensure unzip curl

if have_cmd aws; then
  log_ok "awscli ($(aws --version 2>&1 | cut -d' ' -f1))"
else
  log_install "awscli v2"
  ARCH="$(uname -m)"
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip
  unzip -q -o /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
  rm -rf /tmp/awscliv2.zip /tmp/aws
fi

if have_cmd az; then
  log_ok "azure-cli"
else
  log_install "azure-cli"
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

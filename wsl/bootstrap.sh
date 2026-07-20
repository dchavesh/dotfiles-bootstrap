#!/usr/bin/env bash
# Orchestrates the WSL/Ubuntu side of the dev environment bootstrap.
# Safe to re-run — every step below is idempotent.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

STEPS=(
  00-wsl-conf.sh
  01-apt-base.sh
  02-zsh-omz-p10k.sh
  03-node-toolchain.sh
  04-python-toolchain.sh
  05-runtimes.sh
  06-cloud-cli.sh
  07-chrome-playwright.sh
  08-git-config.sh
  09-ssh-setup.sh
  10-link-dotfiles.sh
)

for step in "${STEPS[@]}"; do
  echo
  echo "── $step ──"
  bash "$step"
done

echo
echo "WSL bootstrap complete. See ../docs/manual-steps.md for what's left to do by hand."

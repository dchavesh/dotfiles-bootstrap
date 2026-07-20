#!/usr/bin/env bash
# Installs Google Chrome natively in WSL (the .deb registers its own apt repo).
# Playwright's own browser cache is project-scoped (npx playwright install) —
# not handled here. See ../playwright/README.md for wiring both this Chrome
# and the Windows-side Chrome into playwright.config.ts.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

if have_cmd google-chrome-stable || have_cmd google-chrome; then
  log_ok "google-chrome-stable"
else
  log_install "google-chrome-stable"
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/google-chrome-stable.deb
  sudo apt-get install -y /tmp/google-chrome-stable.deb
  rm -f /tmp/google-chrome-stable.deb
fi

log_info "see ../playwright/README.md for the WSL-chrome vs Windows-chrome Playwright config snippets"

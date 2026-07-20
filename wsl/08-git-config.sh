#!/usr/bin/env bash
# Links ~/.gitconfig to the tracked template, then fills in user.email
# interactively if it isn't already set (the source machine has none global).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$(cd .. && pwd)"
source lib/common.sh

backup_and_link "$REPO_ROOT/home/gitconfig.tmpl" "$HOME/.gitconfig"

if git config --global user.email >/dev/null 2>&1; then
  log_ok "git user.email"
else
  read -r -p "  git user.email (blank to skip): " EMAIL
  if [ -n "$EMAIL" ]; then
    git config --global user.email "$EMAIL"
    log_changed "git user.email -> $EMAIL"
    log_info "that wrote through the symlink into home/gitconfig.tmpl — commit it in this repo if you want it tracked"
  else
    log_warn "git user.email left unset"
  fi
fi

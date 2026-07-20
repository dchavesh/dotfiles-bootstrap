#!/usr/bin/env bash
# Applies wsl/link-manifest.txt (explicit allowlist), then seeds
# ~/.zshrc.local from its example if it doesn't exist yet. Runs last so
# every tool .zshrc references (fnm, uv, go, eza, ...) already exists.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$(cd .. && pwd)"
source lib/common.sh

mkdir -p "$HOME/.claude"

while IFS= read -r line; do
  [ -z "$line" ] && continue
  case "$line" in \#*) continue ;; esac
  src="${line%%::*}"
  dst="${line#*::}"
  backup_and_link "$REPO_ROOT/$src" "$HOME/$dst"
done < "$REPO_ROOT/wsl/link-manifest.txt"

if [ -f "$HOME/.zshrc.local" ]; then
  log_ok ".zshrc.local"
else
  cp "$REPO_ROOT/home/zshrc.local.example" "$HOME/.zshrc.local"
  log_install ".zshrc.local (copied from example — fill in real API keys; gitignored, never committed)"
fi

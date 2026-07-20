#!/usr/bin/env bash
# Node via fnm (not nvm), corepack, pnpm pinned to match the source machine,
# and the Claude Code CLI itself -- ../claude/ only restores its config,
# something has to actually install the binary that config is for.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

PNPM_VERSION="10.33.0"

if have_cmd fnm; then
  log_ok "fnm"
else
  log_install "fnm"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

if fnm list 2>/dev/null | grep -q 'v[0-9]'; then
  log_ok "node (fnm-managed)"
else
  log_install "node LTS via fnm"
  fnm install --lts
fi
fnm default lts-latest >/dev/null 2>&1 || true

corepack enable >/dev/null 2>&1 || true
CURRENT_PNPM="$(corepack pnpm --version 2>/dev/null || echo none)"
if [ "$CURRENT_PNPM" = "$PNPM_VERSION" ]; then
  log_ok "pnpm@$PNPM_VERSION"
else
  log_changed "pnpm $CURRENT_PNPM -> $PNPM_VERSION"
  corepack prepare "pnpm@${PNPM_VERSION}" --activate
fi

if have_cmd claude; then
  log_ok "claude"
else
  log_install "@anthropic-ai/claude-code"
  npm install -g @anthropic-ai/claude-code
fi

#!/usr/bin/env bash
# System python3 + uv (no pyenv/pipx/poetry — not part of the source machine).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

apt_ensure python3 python3-pip

if have_cmd uv; then
  log_ok "uv"
else
  log_install "uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

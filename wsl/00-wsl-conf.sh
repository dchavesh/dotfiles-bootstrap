#!/usr/bin/env bash
# Ensures /etc/wsl.conf enables systemd and sets the default login user.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

WANT_USER="${1:-$USER}"
TARGET=/etc/wsl.conf

tmp="$(mktemp)"
cat > "$tmp" <<EOF
[boot]
systemd=true

[user]
default=${WANT_USER}
EOF

if [ -f "$TARGET" ] && cmp -s "$tmp" "$TARGET"; then
  log_ok "$TARGET"
  rm -f "$tmp"
  exit 0
fi

log_changed "$TARGET -> writing (requires sudo)"
sudo cp "$tmp" "$TARGET"
rm -f "$tmp"
log_warn "wsl.conf changed — run 'wsl --shutdown' from Windows PowerShell, then reopen the terminal for this to take effect"

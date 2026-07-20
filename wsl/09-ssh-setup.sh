#!/usr/bin/env bash
# Generates any missing ed25519 identity keys (fresh per machine, never
# copied) and renders ~/.ssh/config from ssh/identities.conf + config.tmpl.
# No private key material ever enters the repo tree.
#
# Manifest fields are validated against a strict allowlist before use, and
# templating is pure bash substitution (no sed/awk) -- a manifest row can't
# smuggle shell/sed syntax into the generated config.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$(cd .. && pwd)"
source lib/common.sh

NAME_RE='[A-Za-z0-9_-]+'
HOST_RE='[A-Za-z0-9.-]+'

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

CONFIG_TMP="$(mktemp)"
NEW_KEYS=()

while read -r name hosts aliases label; do
  [ -z "${name:-}" ] && continue
  validate_field "$name" "identity name" "$NAME_RE"

  KEY_PATH="$HOME/.ssh/id_ed25519_${name}"
  if [ -f "$KEY_PATH" ]; then
    log_ok "id_ed25519_${name}"
  else
    log_install "id_ed25519_${name}"
    ssh-keygen -t ed25519 -C "$label" -f "$KEY_PATH"
    NEW_KEYS+=("$KEY_PATH")
  fi

  IFS=',' read -ra HOST_ARR <<< "$hosts"
  IFS=',' read -ra ALIAS_ARR <<< "$aliases"
  for i in "${!ALIAS_ARR[@]}"; do
    validate_field "${HOST_ARR[$i]}" "host" "$HOST_RE"
    validate_field "${ALIAS_ARR[$i]}" "host alias" "$NAME_RE"
    render_template "$REPO_ROOT/ssh/config.tmpl" \
      ALIAS "${ALIAS_ARR[$i]}" HOST "${HOST_ARR[$i]}" NAME "$name" >> "$CONFIG_TMP"
    echo >> "$CONFIG_TMP"
  done
done < <(grep -vE '^\s*(#|$)' "$REPO_ROOT/ssh/identities.conf")

render_if_changed "$CONFIG_TMP" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"
rm -f "$CONFIG_TMP"

if [ "${#NEW_KEYS[@]}" -gt 0 ]; then
  echo
  log_info "new SSH keys generated — paste each public key into the matching provider's web UI:"
  for k in "${NEW_KEYS[@]}"; do
    echo "  ${k}.pub"
    ssh-keygen -lf "${k}.pub"
  done
fi

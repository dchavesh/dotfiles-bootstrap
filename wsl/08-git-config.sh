#!/usr/bin/env bash
# Renders one ~/.gitconfig-<name> per row in ../git/identities.conf, and
# makes sure each identity's project directory exists. ~/.gitconfig itself
# (the includeIf skeleton pointing at these) is pure routing logic with no
# secrets or per-machine data, so it's just a plain symlinked dotfile,
# handled by 10-link-dotfiles.sh like any other.
#
# No global git user.name/email is ever set, by design -- see ../git/README.md.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$(cd .. && pwd)"
source lib/common.sh

while read -r name dir email; do
  [ -z "${name:-}" ] && continue

  expanded_dir="${dir/#\~/$HOME}"
  mkdir -p "$expanded_dir"

  rendered="$(mktemp)"
  sed "s|{{EMAIL}}|${email}|" "$REPO_ROOT/git/gitconfig-identity.tmpl" > "$rendered"
  render_if_changed "$rendered" "$HOME/.gitconfig-${name}"
  rm -f "$rendered"

  case "$email" in
    *REPLACE_ME*) log_warn ".gitconfig-${name} has a placeholder email — edit git/identities.conf and re-run this step" ;;
  esac
done < <(grep -vE '^\s*(#|$)' "$REPO_ROOT/git/identities.conf")

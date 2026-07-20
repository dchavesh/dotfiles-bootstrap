#!/usr/bin/env bash
# Shared helpers for wsl/*.sh bootstrap steps. Sourced, not executed directly.

log_ok()      { printf '  \033[32m[ok]\033[0m      %s\n' "$*"; }
log_install() { printf '  \033[36m[install]\033[0m %s\n' "$*"; }
log_changed() { printf '  \033[33m[changed]\033[0m %s\n' "$*"; }
log_info()    { printf '  \033[2m[info]\033[0m    %s\n' "$*"; }
log_warn()    { printf '  \033[31m[warn]\033[0m    %s\n' "$*" >&2; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# apt_ensure pkg1 pkg2 ... — installs only the packages not already present.
apt_ensure() {
  local missing=() pkg
  for pkg in "$@"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
      log_ok "$pkg"
    else
      missing+=("$pkg")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    log_install "${missing[*]}"
    sudo apt-get install -y "${missing[@]}"
  fi
}

# backup_and_link <source-in-repo> <target-in-home>
# Idempotent symlink: no-ops if already correctly linked, backs up whatever
# real file/dir is in the way before replacing it. Never blind-removes.
backup_and_link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    log_ok "$dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    mv "$dst" "$backup_dir/$(basename "$dst")"
    log_changed "$dst -> backed up to $backup_dir, relinked"
  else
    log_install "$dst -> linked"
  fi
  ln -s "$src" "$dst"
}

# render_if_changed <rendered-content-file> <target-file>
# Compares freshly rendered content against the target; only replaces
# (with a timestamped backup) if it actually differs.
render_if_changed() {
  local rendered="$1" dst="$2"
  if [ -f "$dst" ] && cmp -s "$rendered" "$dst"; then
    log_ok "$dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    local backup="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$dst" "$backup"
    log_changed "$dst -> backed up to $backup, updated"
  else
    log_install "$dst -> created"
  fi
  cp "$rendered" "$dst"
}

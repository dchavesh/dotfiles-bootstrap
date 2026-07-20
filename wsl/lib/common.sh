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

# validate_field <value> <description> <extended-regex>
# Aborts with a clear error if $value doesn't fully match the given regex.
# Every manifest-driven value (ssh/identities.conf, git/identities.conf)
# gets run through this before it's ever interpolated into a generated
# file, so a malformed/malicious manifest row fails loudly here instead of
# reaching a templating step.
validate_field() {
  local value="$1" description="$2" pattern="$3"
  if ! [[ "$value" =~ ^${pattern}$ ]]; then
    log_warn "manifest value '$value' failed validation ($description) — aborting"
    exit 1
  fi
}

# render_template <template-file> <PLACEHOLDER1> <value1> [<PLACEHOLDER2> <value2> ...]
# Pure bash substitution, deliberately not sed/awk -- a value can never
# escape into templating-engine syntax (e.g. sed's s///e execute flag)
# because there is no engine here, just string replacement. Prints to stdout,
# always with exactly one trailing newline (command substitution below
# strips the template's own trailing newline(s), so it's added back here --
# without this, output silently loses its trailing newline every time,
# breaking idempotency comparisons against files written some other way).
render_template() {
  local tmpl="$1"; shift
  local content
  content="$(cat "$tmpl")"
  while [ "$#" -ge 2 ]; do
    local placeholder="$1" value="$2"
    content="${content//\{\{${placeholder}\}\}/${value}}"
    shift 2
  done
  printf '%s\n' "$content"
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

#!/usr/bin/env bash
# zsh + oh-my-zsh + powerlevel10k theme + the 3 custom plugins actually in use.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

apt_ensure zsh git curl

if [ -d "$HOME/.oh-my-zsh" ]; then
  log_ok "oh-my-zsh"
else
  log_install "oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

clone_or_update() {
  local repo="$1" dir="$2"
  if [ -d "$dir" ]; then
    log_ok "$(basename "$dir")"
    git -C "$dir" pull --ff-only --quiet || log_warn "$(basename "$dir") -> local changes present, skipped update"
  else
    log_install "$(basename "$dir")"
    git clone --quiet --depth 1 "$repo" "$dir"
  fi
}

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_or_update https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_or_update https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
clone_or_update https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" = "$(command -v zsh)" ]; then
  log_ok "default shell (zsh)"
else
  log_changed "default shell -> zsh (requires sudo, takes effect next login)"
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

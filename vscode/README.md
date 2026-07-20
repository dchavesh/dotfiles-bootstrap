# VS Code

- `extensions.txt` — the 13 confirmed extension IDs (Remote-WSL install).
  Install with:
  ```powershell
  Get-Content ..\vscode\extensions.txt | ForEach-Object { code --install-extension $_ }
  ```
- `settings.json` — a one-time copy of the real `User/settings.json`,
  applied by `windows/05-vscode-settings.ps1` **only if the destination
  doesn't exist yet**. It's deliberately not re-applied on every bootstrap
  run: VS Code's settings live on the Windows side where a live symlink
  back into this repo (the way WSL-side dotfiles work) isn't practical, so
  overwriting on every run would silently clobber any customization made
  after the first install. To update the tracked copy, copy your live
  `settings.json` back here yourself and commit.
- No `keybindings.json` is tracked — none exists on the source machine
  (stock defaults).

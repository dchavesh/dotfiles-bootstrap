# WSL-side bootstrap

Requires the Ubuntu distro from `../windows/02-install-wsl.ps1` to already
exist and have completed its first-run user setup (interactive, Windows
side — nothing here can do that part for you).

```bash
sudo apt install -y git
git clone <this-repo-url> ~/dotfiles-bootstrap
cd ~/dotfiles-bootstrap/wsl
bash bootstrap.sh
```

Runs `00` through `10` in order — see the numbered filenames for what each
step does; every one of them is safe to re-run. `10-link-dotfiles.sh` runs
last on purpose, so by the time `.zshrc` gets symlinked in, every tool it
references (fnm, uv, eza, go, ...) already exists.

## After it finishes

See `../docs/manual-steps.md` for the full checklist — SSH pubkey upload,
`gh auth login`, Docker Desktop's WSL-integration toggle, cloud CLI logins,
Claude Code login, and optionally filling in `~/.zshrc.local`.

Then open a new shell (or `exec zsh`) to load the newly linked config.

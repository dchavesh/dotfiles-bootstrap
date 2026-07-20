# WSL-side bootstrap

Requires the Ubuntu distro from `../windows/02-install-wsl.ps1` to already
exist and have completed its first-run user setup (interactive, Windows
side — nothing here can do that part for you).

This repo is **private**, so cloning it needs an authenticated `gh`, not
plain `git clone`:
```bash
sudo apt update && sudo apt install -y git gh
gh auth login
gh repo clone dchavesh/dotfiles-bootstrap ~/dotfiles-bootstrap
cd ~/dotfiles-bootstrap/wsl
bash bootstrap.sh
```

`gh auth login` here also plants the credential gh uses later for
`git push`/`git pull` on this repo itself, and is the same login
`home/gitconfig.tmpl`'s `credential.helper` relies on — no separate
`gh auth login` step needed after bootstrapping.

Runs `00` through `10` in order — see the numbered filenames for what each
step does; every one of them is safe to re-run. `10-link-dotfiles.sh` runs
last on purpose, so by the time `.zshrc` gets symlinked in, every tool it
references (fnm, uv, eza, go, ...) already exists.

## After it finishes

See `../docs/manual-steps.md` for the full checklist — SSH pubkey upload,
Docker Desktop's WSL-integration toggle, cloud CLI logins, Claude Code
login, and optionally filling in `~/.zshrc.local`.

Then open a new shell (or `exec zsh`) to load the newly linked config.

# dotfiles-bootstrap

Reproduces a Windows 11 + WSL2 Ubuntu dev environment on a new machine:
Windows-side apps (winget), WSL-side runtimes/CLIs/shell (apt + a handful of
official installers), dotfiles, a curated slice of `~/.claude`, and a
multi-identity SSH setup — without ever committing secrets.

## How it's organized

```
windows/    PowerShell — .wslconfig sizing, winget packages, WSL install, VS Code settings
wsl/        bash — apt packages, zsh/oh-my-zsh/p10k, runtimes, dotfile linking
home/       tracked whole-file dotfiles (.zshrc, .p10k.zsh, gitconfig skeleton, tmux.conf, CLAUDE.md)
claude/     allowlisted subset of ~/.claude (never the whole directory)
ssh/        non-secret SSH identity manifest + Host-block template (see ssh/README.md)
git/        non-secret git identity manifest, directory-scoped (see git/README.md)
vscode/     extension ID list + one-time settings.json copy (see vscode/README.md)
playwright/ WSL-chrome vs Windows-chrome config snippets
packages/   curated apt package list
docs/       manual-steps checklist + open questions
```

**Agent navigability**: `home/projects-claude.md` is symlinked to
`~/projects/CLAUDE.md` — a short breadcrumb any Claude Code (or other
agent) session picks up automatically when working in any of the four
identity directories, pointing at this repo and flagging the `blite`
GitHub-vs-GitLab ambiguity as something to ask about, not guess.

**Linking mechanism**: a small `backup_and_link()` bash helper
(`wsl/lib/common.sh`) applied to an explicit allowlist
(`wsl/link-manifest.txt`) — not GNU stow, not chezmoi. This is a
provision-a-new-machine tool, not an ongoing multi-machine sync tool, and an
explicit allowlist is the right shape for "never track anything unless a
human added a line for it," which matters most in a directory like
`~/.claude` that mixes a handful of config files with ~1GB of runtime state.

**Secrets**: never committed. The one exception is SSH — `ssh/identities.conf`
is a non-secret manifest (names, hosts, aliases, labels) that drives fresh
`ssh-keygen` runs per machine; no private key ever enters the repo tree. See
`ssh/README.md`.

**Git identity**: no global `user.name`/`user.email`, ever — personal,
kolora, university, and blite are separate accounts, and a single global
identity makes it easy to commit under the wrong one. `git/identities.conf`
drives directory-scoped identities instead (`~/projects/<name>/` →
`~/.gitconfig-<name>`, via git's `includeIf`), mirroring the SSH setup.
Anywhere outside those four directories, `git commit` refuses until you set
a local override — intentional friction, not a bug. See `git/README.md`.

## Quick start

**On a brand-new Windows machine:**
```powershell
cd windows
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
```
(see `windows/README.md` for why `-ExecutionPolicy Bypass` is there — a
fresh download commonly comes through flagged as untrusted, which blocks
unsigned local scripts by default). Then launch Ubuntu from the Start Menu
once (interactive first-run, creates your Linux user) before moving to WSL.

**Inside WSL:** this repo is a **private** GitHub repo, so `git clone` alone
won't work yet on a fresh machine — install `gh` and authenticate first,
then use it to clone. It lives under `~/projects/personal/` since it's your
own tooling — that also gives it a working git identity the moment
`08-git-config.sh` runs (see the git identity section above):
```bash
sudo apt update && sudo apt install -y git gh
gh auth login
mkdir -p ~/projects/personal
gh repo clone dchavesh/dotfiles-bootstrap ~/projects/personal/dotfiles-bootstrap
cd ~/projects/personal/dotfiles-bootstrap/wsl
bash bootstrap.sh
```

Every script in both `windows/` and `wsl/` is idempotent — re-running is
always safe and cheap, and is how you pick up after a required reboot or a
mid-way interruption.

Finish with `docs/manual-steps.md` — SSH pubkey upload, cloud CLI logins,
Docker Desktop's WSL-integration toggle, and Claude Code's own login all
happen there, deliberately outside any script.

## What's deliberately NOT replicated

See `docs/open-questions.md` for the full list (Chocolatey, a stale
`~/.dotnet` leftover, etc.) and the plan's original context for why
micromamba/conda and an unidentified empty `~/.gateguard` directory were
dropped rather than carried forward.

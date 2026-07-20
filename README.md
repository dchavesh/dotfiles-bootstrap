# dotfiles-bootstrap

![Windows 11](https://img.shields.io/badge/Windows-11-0078D6?style=flat-square&logo=windows11&logoColor=white)
![WSL2](https://img.shields.io/badge/WSL2-Ubuntu%2024.04-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![Shell](https://img.shields.io/badge/shell-bash%20%7C%20PowerShell-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Status](https://img.shields.io/badge/status-private-lightgrey?style=flat-square)

Two scripts turn a bare Windows 11 box into *this* machine: apps, shell,
multi-identity git/SSH, and a project taxonomy — without ever committing a
secret, and without forcing a fresh Claude Code session to spend its first
ten tool calls rediscovering conventions that live only in one person's head.

### Contents

- [Why this exists](#why-this-exists)
- [Layout](#layout)
- [Identities](#identities)
- [Design](#design)
- [Quick start](#quick-start)
- [What's not replicated](#whats-not-replicated)

## Why this exists

- **Reproducible** — a new machine matches this one after two scripts, not
  a week of half-remembering what got installed and how.
- **No secrets, ever** — SSH and git identity manifests are structure
  only; real keys are generated fresh, per machine, and never enter the
  repo tree.
- **Identity-aware** — personal, kolora, university, and blite can't get
  mixed up, by construction. No global git identity exists to accidentally
  commit under the wrong one.
- **Agent-ready** — every convention an agent would otherwise have to
  guess at (which identity, which SSH alias, where a new project goes) is
  written down where it actually gets read: `~/projects/CLAUDE.md`.

## Layout

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
projects/   project taxonomy + naming conventions + the `new-project` scaffolding tool
docs/       manual-steps checklist + open questions
```

## Identities

Every project lives at `~/projects/<identity>/<category>/<slug>`. Identity
resolves your git `user.email` and the SSH key a push actually uses —
automatically, by directory, never by a global default.

| Identity | What it is | Categories | SSH alias |
|---|---|---|---|
| `personal` | Your own tooling, experiments, OSS | `clients` `labs` `learning` `oss` `public` `systems` `templates` `tools` | `github-personal` |
| `kolora` | Make-up product startup | `product` `marketing` `ops` `experiments` | `github-kolora` |
| `university` | Coursework | `coursework` (term + roman-numeral naming) | `github-university` |
| `blite` | Software dev startup | `product` `concepts` `brand` `hackathons` `clients` | `github-blite` / `gitlab-blite` |

`new-project <identity> <category> <name>` creates a correctly-placed,
git-identity-resolved, README-seeded directory in one shot — see
[`projects/README.md`](projects/README.md).

## Design

**No global git identity.** `git/identities.conf` drives one
`~/.gitconfig-<name>` per identity, wired in via git's `includeIf` on
`~/projects/<name>/`. Outside those four directories, `git commit` refuses
until you set a local override — intentional friction, not a bug. See
[`git/README.md`](git/README.md).

**Explicit-allowlist linking.** A small `backup_and_link()` bash helper
(`wsl/lib/common.sh`) applied to `wsl/link-manifest.txt` — not GNU stow,
not chezmoi. This is a provision-a-new-machine tool, not an ongoing
multi-machine sync tool, and an allowlist is the right shape for "never
track anything unless a human added a line for it" — which matters most
in a directory like `~/.claude` that mixes a handful of config files with
roughly a gigabyte of runtime state.

**Secrets stay out, structurally.** `ssh/identities.conf` is a non-secret
manifest (names, hosts, aliases, labels) that drives fresh `ssh-keygen`
runs per machine — no private key ever has a code path into the repo. See
[`ssh/README.md`](ssh/README.md).

**Agent breadcrumbs, not tribal knowledge.** `home/projects-claude.md` is
symlinked to `~/projects/CLAUDE.md`, picked up automatically by any Claude
Code (or other agent) session working in any of the four identity
directories. It points at this repo, flags the `blite`
GitHub-vs-GitLab ambiguity as something to ask about rather than guess,
and points at `new-project` so a new project lands in the right place
instead of getting created ad hoc.

## Quick start

Every script in both `windows/` and `wsl/` is idempotent — re-running is
always safe and cheap, and is how you pick up after a required reboot or a
mid-way interruption.

### Windows

```powershell
cd windows
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

(`windows/README.md` explains why `-ExecutionPolicy Bypass` is there — a
fresh download commonly comes through flagged as untrusted, which blocks
unsigned local scripts by default.) Then launch Ubuntu from the Start Menu
once — interactive first-run, creates your Linux user — before moving to WSL.

### WSL

This is a **private** GitHub repo, so plain `git clone` won't work yet on
a fresh machine — install `gh` and authenticate first. It lives under
`~/projects/personal/` since it's your own tooling, which also gives it a
working git identity the moment `08-git-config.sh` runs:

```bash
sudo apt update && sudo apt install -y git gh
gh auth login
mkdir -p ~/projects/personal
gh repo clone dchavesh/dotfiles-bootstrap ~/projects/personal/dotfiles-bootstrap
cd ~/projects/personal/dotfiles-bootstrap/wsl
bash bootstrap.sh
```

Finish with [`docs/manual-steps.md`](docs/manual-steps.md) — SSH pubkey
upload, cloud CLI logins, Docker Desktop's WSL-integration toggle, and
Claude Code's own login all happen there, deliberately outside any script.

## What's not replicated

See [`docs/open-questions.md`](docs/open-questions.md) for the full list
(Chocolatey, a stale `~/.dotnet` leftover, etc.) and the reasoning behind
why micromamba/conda and an unidentified empty `~/.gateguard` directory
were dropped rather than carried forward.

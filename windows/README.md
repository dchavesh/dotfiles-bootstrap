# Windows-side bootstrap

Run from an elevated or normal PowerShell prompt (winget itself doesn't
need admin rights for per-user installs, but some packages, like Docker
Desktop, will prompt via UAC on their own):

```powershell
cd windows
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

`-ExecutionPolicy Bypass` is scoped to this one process, not a system-wide
change — it's there because Windows' default policy refuses to run
*any* unsigned local script, including these, and a fresh download from
GitHub commonly comes through flagged as untrusted too. If you'd rather
not bypass it, right-click each `.ps1` → Properties → Unblock (or
`Get-ChildItem -Recurse *.ps1 | Unblock-File`) before running.

## What it does

0. **`00-wslconfig.ps1`** — writes `%UserProfile%\.wslconfig` sized to this
   machine's actual RAM/cores (WSL2's default caps memory at ~50%-of-host
   or 8GB, whichever is smaller — throttles anything with more RAM than
   that) plus `networkingMode=mirrored` for reliable networking under VPNs.
   Only takes effect after a `wsl --shutdown` you run yourself when
   convenient — see the warning it prints; this script never runs that
   itself, since it would kill every running WSL process on the spot.
1. **`01-winget-packages.ps1`** — installs the curated set in `packages.json`
   (WSL, Windows Terminal, VS Code, Chrome, Docker Desktop). Deliberately
   excludes personal apps (Discord, Spotify, etc.) — add IDs to
   `packages.json` yourself if you want those scripted too.
2. **`02-install-wsl.ps1`** — installs `Ubuntu-24.04` via `wsl --install`.
   On a genuinely fresh machine this commonly requires a **reboot** — the
   script tells you when that happened; re-run `bootstrap.ps1` afterward,
   already-done steps no-op.
3. **`03-fonts.ps1`** — installs MesloLGS NF (powerlevel10k's font)
   **system-wide**, which means it triggers its own UAC prompt — approve
   it. A per-user, no-admin install was tried first but proved invisible
   to Windows Terminal (a packaged app) without a sign-out; system-wide is
   what's actually verified working.
4. **`04-windows-terminal.ps1`** — sets that font on the Ubuntu profile and
   confirms it's the default profile, backing up `settings.json` first.
5. **`05-vscode-settings.ps1`** — copies `vscode/settings.json` into place
   once, only if VS Code's `settings.json` doesn't already exist. See
   `../vscode/README.md` for why it's a one-time copy, not a live sync.

## Manual steps this doesn't cover

- **First launch of Ubuntu** from the Start Menu: WSL's own first-run flow
  creates the Linux user + password interactively. Nothing outside WSL can
  script this.
- **VS Code duplicate installs**: if this machine already has the msstore
  "Visual Studio Code (User)" track installed alongside the winget one,
  uninstall the msstore copy yourself via Settings → Apps — the bootstrap
  script only installs the standard winget package going forward, it
  doesn't remove anything.
- **VS Code extensions**: see `../vscode/extensions.txt` and run
  `Get-Content ..\vscode\extensions.txt | ForEach-Object { code --install-extension $_ }`
  once `code` is on PATH.
- **Docker Desktop → Settings → Resources → WSL Integration**: toggle on
  for your Ubuntu distro. There's no config file format that's stable
  enough across Docker Desktop versions to script this reliably — do it
  by hand once per machine.
- Everything else (SSH keys, `gh auth login`, cloud CLI logins, Claude Code
  login) happens inside WSL — see `../wsl/README.md` and
  `../docs/manual-steps.md`.

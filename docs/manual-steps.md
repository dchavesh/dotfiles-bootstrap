# Manual steps — nothing here is scripted, on purpose

Things that are either inherently interactive, require a GUI toggle with no
stable config-file to script against, or are one-time account actions.

## Windows

- [ ] First launch of Ubuntu from the Start Menu — creates the Linux user
      and password. WSL's own first-run flow; unscriptable from outside.
- [ ] If `windows/02-install-wsl.ps1` reported a reboot was needed, reboot,
      then re-run `windows\bootstrap.ps1`.
- [ ] If the msstore "Visual Studio Code (User)" track is still installed
      alongside the winget one, remove the duplicate yourself via
      Settings → Apps (bootstrap scripts install, they don't uninstall).

## WSL

- [ ] **SSH keys**: after `wsl/09-ssh-setup.sh` runs, paste each newly
      printed public key into the matching provider:
      - `id_ed25519_personal.pub` → github.com (personal account)
      - `id_ed25519_kolora.pub` → github.com (kolora account)
      - `id_ed25519_university.pub` → github.com (university account)
      - `id_ed25519_blite.pub` → github.com **and** gitlab.com (blite account)
- [ ] `gh auth login` — interactive OAuth device flow.
- [ ] `aws configure` — sets up native WSL AWS credentials (this repo
      switched away from the old ~/.aws-symlinked-into-Windows pattern).
- [ ] `az login` — same, for Azure CLI.
- [ ] Launch `claude` and complete its own login/onboarding. This repo
      restores `~/.claude/settings.json`, `settings.local.json`, `rules/`,
      and the statusline script — never `.credentials.json`.
- [ ] Optionally fill in real values in `~/.zshrc.local` (copied from
      `home/zshrc.local.example` on first bootstrap run, gitignored).
- [ ] Docker Desktop → Settings → Resources → WSL Integration → toggle on
      for the Ubuntu distro. Docker Desktop's settings format isn't stable
      enough across versions to script reliably — do this by hand once.

## Verify it all worked

- New shell / `exec zsh` — prompt renders with icons (needs the Nerd Font
  from `windows/03-fonts.ps1` set on the Windows Terminal profile).
- `ssh-add -l` lists all 4 identity keys.
- `ssh -T github-personal` (etc.) succeeds for each alias once the pubkey
  is uploaded.
- `docker ps` works from WSL once the Docker Desktop integration toggle is on.
- `npx playwright test --project=wsl-chrome` and `--project=windows-chrome`
  both launch — see `../playwright/README.md`.

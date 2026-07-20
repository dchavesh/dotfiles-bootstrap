# SSH identities

This is the one place in the repo that touches SSH at all, and it never
touches key material — only the non-secret *shape* of a multi-identity setup:
which named identities exist, which host(s)/alias(es) each one covers, and
the label baked into the key comment.

`identities.conf` drives `../wsl/09-ssh-setup.sh`:
- For each unique `name`, if `~/.ssh/id_ed25519_<name>` doesn't already
  exist, a **fresh** keypair is generated on that machine
  (`ssh-keygen -t ed25519 -C "<label>"`, passphrase prompted interactively —
  never forced empty). Private keys are written only under `$HOME/.ssh/`,
  a path this repo doesn't contain, so there's no code path by which a real
  key could end up committed.
- `~/.ssh/config` is then rendered from `config.tmpl` for every
  alias/host/name triple and only replaces the existing file (with a
  timestamped backup) if the rendered content actually changed.

## Adding a 6th identity

Add a row to `identities.conf`:

```
name        hosts             host_aliases       label
newthing    github.com        github-newthing    dylan-newthing
```

Re-run `wsl/09-ssh-setup.sh` (or the full `wsl/bootstrap.sh`). It generates
the new keypair, adds the `Host` block, and prints the new public key.

## Manual step every time a key is (re)generated

Paste the freshly printed `*.pub` content into the matching provider's web
UI (GitHub → Settings → SSH and GPG keys, or GitLab → Preferences → SSH
Keys). This is inherently interactive and isn't scripted.

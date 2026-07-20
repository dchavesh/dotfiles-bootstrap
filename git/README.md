# Directory-scoped git identity

No global `user.name` or `user.email` is ever set, on purpose — with one
shared identity, GitHub can't tell which of your several accounts
(personal / kolora / university / blite) made a commit, and it's easy to
accidentally commit work under the wrong name. Instead, identity is scoped
by directory, using git's `includeIf "gitdir:...`, the same way
`../ssh/identities.conf` scopes SSH keys by `Host` alias.

## How it works

`~/.gitconfig` (tracked as `../home/gitconfig`, plain symlink, no secrets —
it's pure routing) is just:

```
[includeIf "gitdir:~/projects/personal/"]
	path = ~/.gitconfig-personal
[includeIf "gitdir:~/projects/kolora/"]
	path = ~/.gitconfig-kolora
...
```

`identities.conf` (this directory) drives `../wsl/08-git-config.sh`, which
renders one `~/.gitconfig-<name>` per row from `gitconfig-identity.tmpl` —
each just sets `user.name`/`user.email` and the `gh auth git-credential`
helper for that identity.

**Outside all 4 directories** (a one-off clone in `/tmp`, a new project you
haven't categorized yet), nothing matches, so `git commit` refuses until
you set a local override (`git config user.email you@example.com`, scoped
to that one repo's `.git/config`). This is intentional friction, not a
bug — confirmed with Dylan: forcing an explicit choice beats a silent
default that might be wrong.

## Adding/fixing an identity

Edit `identities.conf`, re-run `wsl/08-git-config.sh` (or the full
`wsl/bootstrap.sh`). A `REPLACE_ME_*` email means it's still a placeholder
— the script warns about it but still writes the file, so nothing is
silently broken, it's just non-functional until you supply a real address
verified on that identity's account.

**blite** spans both GitHub and GitLab depending on project/competition —
one `~/.gitconfig-blite` can only hold one default email. If a specific
blite sub-project needs a different one, set a local override in that
project's own `.git/config` the same way as the "outside all 4
directories" case above; it takes precedence over the directory-scoped
config automatically.

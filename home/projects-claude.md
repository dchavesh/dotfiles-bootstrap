# ~/projects/ — machine conventions

This machine uses **directory-scoped git identity + SSH host aliases**, not
a single global identity — personal, kolora, university, and blite are
separate accounts. Source of truth (scripts, manifests, full explanation):
`~/projects/personal/dotfiles-bootstrap/{git,ssh}/README.md`.

- Working in `~/projects/{personal,kolora,university,blite}/...` resolves
  the right `user.email` automatically via git's `includeIf`.
- Outside those four directories, `git commit` refuses until a local
  override is set (`git config user.email you@example.com` in that repo).
  This is intentional — ask the user which identity applies rather than
  guessing or defaulting to one.
- **`blite` is ambiguous between GitHub and GitLab** depending on
  project/competition — there is no automatic way to tell which. Ask
  before creating a remote or pushing in a new blite project; don't guess.
- SSH remotes use per-identity Host aliases (`github-personal`,
  `github-kolora`, `github-university`, `github-blite`, `gitlab-blite`) —
  use the alias matching the project's identity, not a bare `github.com`.
- If a `cat`/`ls`/`grep` Bash call ever fails with a surprising "command
  not found", it's probably a shell alias pointing at a renamed/missing
  binary (this has happened before) — try `command cat` or `\cat` instead
  of assuming the file is unreadable.

**Project layout**: every project lives at
`~/projects/<identity>/<category>/<slug>` — categories are a fixed,
per-identity manifest at
`~/projects/personal/dotfiles-bootstrap/projects/categories.conf`, not
freeform. Creating a new project by hand instead of checking that manifest
risks a stray, miscategorized folder. Use:
```
new-project <identity> <category> <name>
```
(run with no args to list valid identity/category pairs). It creates the
directory, `git init`s it with the right identity already resolved, and
seeds a README. Naming conventions differ by domain (plain kebab-case for
tech, year-prefixed for blite hackathons, term+roman-numeral for
university coursework) — see
`~/projects/personal/dotfiles-bootstrap/projects/README.md` before
inventing a new pattern.

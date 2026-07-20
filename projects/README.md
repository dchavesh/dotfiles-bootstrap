# Project taxonomy and naming conventions

Path shape: `~/projects/<identity>/<category>/<slug>`

- `<identity>` — one of `personal`, `kolora`, `university`, `blite`. Fixed;
  this is also what resolves your git identity (see `../git/README.md`).
- `<category>` — see `categories.conf`. Kept in a manifest, not hardcoded
  here, so it can evolve without editing this file. `tools/new-project`
  refuses an unknown identity/category pair rather than silently creating
  a stray folder — if a category is missing, add it to `categories.conf`
  first.
- `<slug>` — the naming convention differs by domain, matching how each
  domain is conventionally named in the real world rather than forcing one
  scheme everywhere:

## Tech (personal, kolora, blite — everything except university)

Plain kebab-case: `lab-forge-core`, `learn-quantum`, `blite-contact-api`.
This is already what every existing project uses — this just writes it
down. `tools/new-project` slugifies whatever name you give it into this
form automatically (lowercase, spaces/underscores → hyphens, strips
anything else).

## Time-boxed / competition work (blite/hackathons)

Year-prefixed kebab-case: `2026-event-name`. Matches the existing
`hackathons/2026` pattern. `new-project` doesn't auto-prefix the year for
you (a hackathon's slug is more about the event name than the exact
category), so include it yourself when you run the command.

## Academic (university/coursework)

Courses conventionally use **roman numerals** for sequence (Calculus I/II,
not Calculus 1/2) and are naturally grouped by **term** — neither of which
fits a flat kebab-case slug well. Convention:

```
~/projects/university/coursework/<term>/<course-slug>
```

- `<term>` — however you actually track terms, e.g. `2026-1` for a
  semester/quarter marker.
- `<course-slug>` — kebab-case, roman numerals preserved where the course
  name has them: `calculo-ii`, not `calculo-2`.

`new-project` doesn't try to auto-generate this — course names and terms
are naturally varied text, not something worth a slugifier for. Create it
directly (`mkdir -p`, or `new-project university coursework "2026-1/calculo-ii"`
works fine since the tool just kebab-cases what it's given and slashes are
preserved as path separators).

The existing 3 course folders (`math`, `probabilidad-y-estadística-1`,
`programacion-web-avanzada`) predate this convention and haven't been
migrated — nothing forces that retroactively; apply the convention going
forward.

## The scaffolding tool

```
new-project <identity> <category> <name>
```

Creates `~/projects/<identity>/<category>/<slug>`, `git init`s it (the
directory-scoped identity resolves automatically), and seeds a one-line
README. Run `new-project` with no arguments to see valid identity/category
pairs pulled live from `categories.conf`.

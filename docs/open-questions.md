# Open questions / punted decisions

Things noticed while building this that weren't part of the original scope
— decided by default, not silently dropped, in case any of these were
actually load-bearing and worth revisiting.

- **Chocolatey**: installed on the source machine (v2.7.1) but no packages
  were enumerated under it — looks unused now that winget is the primary
  package manager. Left alone: not scripted (bootstrap doesn't install it),
  not removed either. If you remember what it was for, add a step.
- **`.dotnet` leftover**: a stale `~/.dotnet` directory exists on the source
  machine but `dotnet` isn't on PATH — treated as dead, not replicated.
- **Nerd Font / Windows Terminal font patch**: originally scripted (install
  MesloLGS NF, set it on the Ubuntu profile) since powerlevel10k's prompt
  glyphs need one. Dropped after confirming icons never rendered reliably
  on the source machine's Windows Terminal anyway — two scripts (a font
  downloader, a settings.json patcher) for a problem that wasn't actually
  being solved. `.p10k.zsh` is unchanged and still ships as-is; it just
  renders without icons, matching current behavior exactly. Windows
  Terminal otherwise had no customization worth scripting (no custom color
  scheme, opacity, etc.).
- **Postman / alternative terminal emulators**: none were found on the
  source machine, so nothing to replicate there.

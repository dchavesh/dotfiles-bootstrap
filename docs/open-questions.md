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
- **Windows Terminal beyond font + default profile**: the source machine's
  settings.json had no other customization (no custom color scheme,
  opacity, etc.) to replicate, so `04-windows-terminal.ps1` only touches
  those two fields. If you add WT customizations later, extend that script
  rather than hand-editing settings.json on every new machine.
- **Postman / alternative terminal emulators**: none were found on the
  source machine, so nothing to replicate there.

# Installs the curated dev-relevant winget packages from packages.json.
# Idempotent: checks `winget list --id <id>` before installing each one.
# Personal apps (Discord, Spotify, etc.) are deliberately not in the manifest.
$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install 'App Installer' from the Microsoft Store first, then re-run."
    exit 1
}

# Fresh machines (or a just-installed/updated App Installer) commonly have
# missing or uninitialized source index data -- winget error 0x8a15000f,
# "Faltan los datos requeridos por el origen" / source data missing --
# which makes every subsequent `winget list`/`winget install` fail.
# `source reset --force` is winget's own documented fix (it re-registers
# and re-syncs every default source from scratch); `source update` alone
# only helps when the index is stale, not when it's missing entirely.
# `--force` skips reset's interactive "are you sure?" confirmation.
winget source reset --force | Out-Null

# One-time, deterministic agreement acceptance -- without this, the very
# first `winget list` probe below (not just `winget install`) can block on
# an interactive "Do you agree?" prompt on a genuinely fresh machine, which
# this non-interactive script has no way to answer.
winget source update --accept-source-agreements | Out-Null

$manifestPath = Join-Path $PSScriptRoot "packages.json"
$packages = (Get-Content $manifestPath -Raw | ConvertFrom-Json).packages

foreach ($pkg in $packages) {
    $id = $pkg.id
    $source = $pkg.source
    $installed = winget list --id $id -e --source $source --accept-source-agreements 2>$null | Select-String -SimpleMatch $id

    if ($installed) {
        Write-Host "  [ok]      $id"
    } else {
        Write-Host "  [install] $id"
        winget install --id $id -e --source $source --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) {
            # Don't abort the whole run over one package (e.g. Docker
            # Desktop needing a pending reboot) -- warn loudly and let the
            # next bootstrap re-run retry it, matching every other step's
            # "safe to re-run" contract.
            Write-Warning "  [failed]  $id (winget exit code $LASTEXITCODE) -- will retry on next bootstrap run"
        }
    }
}

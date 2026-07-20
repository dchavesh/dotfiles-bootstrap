# Installs the curated dev-relevant winget packages from packages.json.
# Idempotent: checks `winget list --id <id>` before installing each one.
# Personal apps (Discord, Spotify, etc.) are deliberately not in the manifest.
$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install 'App Installer' from the Microsoft Store first, then re-run."
    exit 1
}

$manifestPath = Join-Path $PSScriptRoot "packages.json"
$packages = (Get-Content $manifestPath -Raw | ConvertFrom-Json).packages

foreach ($pkg in $packages) {
    $id = $pkg.id
    $source = $pkg.source
    $installed = winget list --id $id -e --source $source 2>$null | Select-String -SimpleMatch $id

    if ($installed) {
        Write-Host "  [ok]      $id"
    } else {
        Write-Host "  [install] $id"
        winget install --id $id -e --source $source --accept-source-agreements --accept-package-agreements
    }
}

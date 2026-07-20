# Orchestrates the Windows side of the dev environment bootstrap.
# Safe to re-run -- every step below is idempotent.
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot

$steps = @(
    "01-winget-packages.ps1",
    "02-install-wsl.ps1",
    "03-fonts.ps1",
    "04-windows-terminal.ps1"
)

foreach ($step in $steps) {
    Write-Host ""
    Write-Host "-- $step --"
    & (Join-Path $here $step)
}

Write-Host ""
Write-Host "Windows bootstrap complete. Next: launch Ubuntu from the Start Menu to finish"
Write-Host "its first-run setup, then follow wsl/README.md inside WSL."

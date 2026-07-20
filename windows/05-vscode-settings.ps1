# One-time copy of vscode/settings.json into VS Code's User settings --
# only if the destination doesn't exist yet. See vscode/README.md for why
# this deliberately doesn't overwrite on re-runs.
$ErrorActionPreference = "Stop"

$src = Join-Path $PSScriptRoot "..\vscode\settings.json"
$dstDir = "$env:APPDATA\Code\User"
$dst = Join-Path $dstDir "settings.json"

if (Test-Path $dst) {
    Write-Host "  [ok]      VS Code settings.json (exists, not overwritten -- see vscode/README.md)"
    exit 0
}

New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
Copy-Item $src $dst
Write-Host "  [install] VS Code settings.json"

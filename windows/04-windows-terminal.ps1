# Patches Windows Terminal's settings.json: sets the Ubuntu profile's font
# to MesloLGS NF and confirms it's the default profile. Read-modify-write
# with a value-equality check per field (idempotent), backs up the original
# file before the first-ever change.
$ErrorActionPreference = "Stop"

$wtPackage = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Directory -Filter "Microsoft.WindowsTerminal_*" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $wtPackage) {
    Write-Warning "Windows Terminal package folder not found -- is it installed? Skipping."
    exit 0
}

$settingsPath = Join-Path $wtPackage.FullName "LocalState\settings.json"
if (-not (Test-Path $settingsPath)) {
    Write-Warning "Windows Terminal settings.json not found at $settingsPath -- skipping."
    exit 0
}

$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

$ubuntuProfile = $settings.profiles.list | Where-Object { $_.name -match "Ubuntu" } | Select-Object -First 1
if (-not $ubuntuProfile) {
    Write-Warning "No Ubuntu profile found in Windows Terminal settings -- skipping font/default-profile patch."
    exit 0
}

$changed = $false

if (-not $ubuntuProfile.font) {
    $ubuntuProfile | Add-Member -NotePropertyName font -NotePropertyValue ([PSCustomObject]@{ face = "MesloLGS NF" }) -Force
    $changed = $true
} elseif ($ubuntuProfile.font.face -ne "MesloLGS NF") {
    $ubuntuProfile.font.face = "MesloLGS NF"
    $changed = $true
}

if ($settings.defaultProfile -ne $ubuntuProfile.guid) {
    $settings.defaultProfile = $ubuntuProfile.guid
    $changed = $true
}

if (-not $changed) {
    Write-Host "  [ok]      Windows Terminal (font + default profile)"
    exit 0
}

$backupPath = "$settingsPath.bak.$(Get-Date -Format yyyyMMdd-HHmmss)"
Copy-Item $settingsPath $backupPath
Write-Host "  [changed] backed up $settingsPath -> $backupPath"

$settings | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsPath -Encoding utf8
Write-Host "  [changed] Windows Terminal: Ubuntu profile font -> MesloLGS NF, default profile -> Ubuntu"

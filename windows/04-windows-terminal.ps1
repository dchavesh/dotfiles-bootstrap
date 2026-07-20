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

try {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
} catch {
    Write-Warning "settings.json isn't parseable as strict JSON (e.g. it has `"//`" comments, which Windows Terminal allows but ConvertFrom-Json doesn't) -- skipping the font/default-profile patch rather than aborting the rest of the bootstrap. Set the Ubuntu profile's font to 'MesloLGS NF' by hand in Windows Terminal's settings UI."
    exit 0
}

$ubuntuProfile = $settings.profiles.list | Where-Object { $_.name -match "Ubuntu" } | Select-Object -First 1
if (-not $ubuntuProfile) {
    # Windows Terminal only detects newly-installed WSL distros at ITS OWN
    # startup (dynamic profile generation) -- if it was already open before
    # 02-install-wsl.ps1 ran, or this is the same bootstrap.ps1 invocation
    # that just installed WSL moments ago, the Ubuntu profile genuinely
    # doesn't exist in settings.json yet. Not a bug -- just re-run after WT
    # has had a chance to see the new distro.
    Write-Warning "No Ubuntu profile found in Windows Terminal settings. If WSL/Ubuntu was just installed, Windows Terminal hasn't picked it up yet -- close every Windows Terminal window, reopen it, then re-run this script (or the full bootstrap). Skipping for now."
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

# Writes %UserProfile%\.wslconfig sized to this machine's actual hardware
# (memory = ~75% of host RAM, all logical cores), plus networkingMode=mirrored
# (more reliable than WSL2's default NAT mode under VPNs and for localhost
# port-forwarding -- relevant given this repo's whole Windows-Chrome-via-WSL
# Playwright setup) and gradual memory reclaim.
#
# IMPORTANT: this file only takes effect after `wsl --shutdown`, which kills
# EVERY running WSL process -- including any Claude Code / terminal session
# currently running inside WSL. This script writes the file (safe, no live
# effect) but deliberately does NOT run `wsl --shutdown` itself. Do that
# yourself when you're not mid-work.
$ErrorActionPreference = "Stop"

$totalRamGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$memoryGB = [math]::Max(4, [math]::Floor($totalRamGB * 0.75))
$processors = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors

$content = @"
[wsl2]
memory=${memoryGB}GB
processors=$processors
networkingMode=mirrored

[experimental]
autoMemoryReclaim=gradual
"@

$path = "$env:UserProfile\.wslconfig"

if ((Test-Path $path) -and ((Get-Content $path -Raw).Trim() -eq $content.Trim())) {
    Write-Host "  [ok]      .wslconfig"
    exit 0
}

if (Test-Path $path) {
    $backup = "$path.bak.$(Get-Date -Format yyyyMMdd-HHmmss)"
    Copy-Item $path $backup
    Write-Host "  [changed] backed up $path -> $backup"
}

Set-Content -Path $path -Value $content -Encoding utf8
Write-Host "  [changed] .wslconfig written (memory=${memoryGB}GB, processors=$processors, networkingMode=mirrored)"
Write-Host "  [action]  run 'wsl --shutdown' yourself when convenient, then reopen WSL, for this to take effect -- it WILL kill any running WSL processes" -ForegroundColor Yellow

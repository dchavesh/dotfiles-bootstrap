# Installs MesloLGS NF (powerlevel10k's recommended Nerd Font) system-wide.
#
# History: a per-user install (%LOCALAPPDATA%\Microsoft\Windows\Fonts, no
# admin needed) was tried first, but proved invisible to Windows Terminal --
# a packaged/UWP app -- without a sign-out/sign-in to refresh its font
# cache. Verified live: installing system-wide (C:\Windows\Fonts + HKLM)
# instead fixed it immediately, no sign-out required. That's what this does.
#
# The elevated step downloads the fonts itself rather than trusting files
# staged earlier by this unprivileged process, and verifies each download
# is a real file (not a truncated/corrupt one) before installing it --
# avoids ever having an elevated process blindly copy something an
# unprivileged process could have tampered with or left partially written.
$ErrorActionPreference = "Stop"

$fonts = @(
    "MesloLGS NF Regular.ttf",
    "MesloLGS NF Bold.ttf",
    "MesloLGS NF Italic.ttf",
    "MesloLGS NF Bold Italic.ttf"
)
$minValidSize = 10000  # bytes -- real MesloLGS NF files are several hundred KB; this just catches truncation

$allPresent = $true
foreach ($font in $fonts) {
    $path = "C:\Windows\Fonts\$font"
    if (-not (Test-Path $path) -or (Get-Item $path).Length -lt $minValidSize) {
        $allPresent = $false
    }
}

if ($allPresent) {
    Write-Host "  [ok]      MesloLGS NF (system-wide)"
    exit 0
}

Write-Host "  [install] MesloLGS NF (system-wide install requires elevation -- approve the UAC prompt)"

$elevatedScript = @'
$ErrorActionPreference = "Stop"
$fonts = @(
    "MesloLGS NF Regular.ttf",
    "MesloLGS NF Bold.ttf",
    "MesloLGS NF Italic.ttf",
    "MesloLGS NF Bold Italic.ttf"
)
$minValidSize = 10000
$tempDir = Join-Path $env:TEMP "meslo-nf-install"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

foreach ($font in $fonts) {
    $dst = "C:\Windows\Fonts\$font"
    if ((Test-Path $dst) -and (Get-Item $dst).Length -ge $minValidSize) {
        continue
    }
    $encoded = [uri]::EscapeDataString($font)
    $url = "https://github.com/romkatv/powerlevel10k-media/raw/master/$encoded"
    $tempPath = Join-Path $tempDir $font
    Invoke-WebRequest -Uri $url -OutFile $tempPath
    if ((Get-Item $tempPath).Length -lt $minValidSize) {
        throw "Downloaded $font looks truncated ($((Get-Item $tempPath).Length) bytes) -- aborting rather than installing a corrupt font"
    }
    Copy-Item -Path $tempPath -Destination $dst -Force
    $regName = "$($font -replace '\.ttf$','') (TrueType)"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
        -Name $regName -Value $font -PropertyType String -Force | Out-Null
}
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
'@

$scriptPath = Join-Path $env:TEMP "install-meslo-system.ps1"
Set-Content -Path $scriptPath -Value $elevatedScript -Encoding UTF8

Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath -Verb RunAs -Wait

$stillMissing = $fonts | Where-Object {
    -not (Test-Path "C:\Windows\Fonts\$_") -or (Get-Item "C:\Windows\Fonts\$_").Length -lt $minValidSize
}
if ($stillMissing) {
    Write-Warning "  [failed]  Some fonts still missing after elevation (was UAC declined?): $($stillMissing -join ', ')"
} else {
    Write-Host "  [changed] MesloLGS NF installed system-wide"
}

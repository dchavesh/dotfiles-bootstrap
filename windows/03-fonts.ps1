# Installs MesloLGS NF (powerlevel10k's recommended Nerd Font) for the
# current user only -- no admin rights required. The source machine never
# had a Nerd Font installed, which is why p10k's prompt glyphs render as
# boxes/garbage; this fixes that once set as Windows Terminal's font
# (04-windows-terminal.ps1 does that automatically).
$ErrorActionPreference = "Stop"

$fonts = @(
    "MesloLGS NF Regular.ttf",
    "MesloLGS NF Bold.ttf",
    "MesloLGS NF Italic.ttf",
    "MesloLGS NF Bold Italic.ttf"
)

$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
New-Item -ItemType Directory -Force -Path $fontDir | Out-Null

foreach ($font in $fonts) {
    $destPath = Join-Path $fontDir $font
    if (Test-Path $destPath) {
        Write-Host "  [ok]      $font"
        continue
    }

    Write-Host "  [install] $font"
    $encoded = [uri]::EscapeDataString($font)
    $url = "https://github.com/romkatv/powerlevel10k-media/raw/master/$encoded"
    Invoke-WebRequest -Uri $url -OutFile $destPath

    $regName = "$($font -replace '\.ttf$','') (TrueType)"
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" `
        -Name $regName -Value $font -PropertyType String -Force | Out-Null
}

Write-Host "  [info]    MesloLGS NF installed for the current user."
Write-Host "  [info]    If it doesn't show up in Windows Terminal's font list immediately, sign out/in once."

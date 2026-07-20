# Installs the Ubuntu-24.04 WSL2 distro if it's not already present.
# The very first `wsl --install` on a machine commonly requires a reboot --
# detect that case and tell the user to re-run afterwards (everything here
# is idempotent, so a re-run just no-ops the parts already done).
#
# NOTE: `wsl --install -d Ubuntu-24.04` registers the distro under the name
# "Ubuntu", not "Ubuntu-24.04" -- confirmed live. Matching against a small
# alias list instead of one exact string, so this check actually no-ops
# once installed instead of re-triggering install on every run.
$ErrorActionPreference = "Stop"

$distro = "Ubuntu-24.04"
$installedAliases = @("Ubuntu-24.04", "Ubuntu")
$existing = (wsl -l -q 2>$null) | ForEach-Object { $_ -replace "`0", "" } | Where-Object { $installedAliases -contains $_.Trim() }

if ($existing) {
    Write-Host "  [ok]      WSL distro '$($existing.Trim())'"
} else {
    Write-Host "  [install] WSL distro '$distro' (this can require a reboot on a brand-new machine)"
    wsl --install -d $distro
    Write-Host ""
    Write-Host "If this is the first WSL install on this machine, REBOOT now, then re-run" -ForegroundColor Yellow
    Write-Host "windows\bootstrap.ps1 -- already-completed steps will no-op." -ForegroundColor Yellow
}

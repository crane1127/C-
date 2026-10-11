if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ErrorActionPreference = "Stop"
$installDir = "$env:ProgramFiles\YiyeCleaner"

Write-Host ""
Write-Host "  ================================" -ForegroundColor Yellow
Write-Host "   Uninstalling Yiye Cleaner..." -ForegroundColor Yellow
Write-Host "  ================================" -ForegroundColor Yellow
Write-Host ""

try {
    Stop-Process -Name YIyicleaner -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Stopped running process" -ForegroundColor Green
} catch {}

try {
    Remove-Item "$env:PUBLIC\Desktop\YiyeCleaner.lnk" -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Removed desktop shortcut" -ForegroundColor Green
} catch {}

try {
    Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\YiyeCleaner" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Removed Start Menu entries" -ForegroundColor Green
} catch {}

try {
    Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Removed: $installDir" -ForegroundColor Green
} catch {
    Write-Host "  [!] Could not remove install directory: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\YiyeCleaner" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Removed registry entry" -ForegroundColor Green
} catch {}

Write-Host ""
Write-Host "  Yiye Cleaner has been uninstalled." -ForegroundColor Green
Write-Host ""

Write-Host "  Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

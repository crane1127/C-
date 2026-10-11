$version = "1.2"
$appName = "Yiye Cleaner"

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ErrorActionPreference = "Stop"
$installDir = "$env:ProgramFiles\YiyeCleaner"
$exePath = "$installDir\YIyicleaner.exe"
$srcDir = Split-Path $PSCommandPath -Parent

Write-Host ""
Write-Host "  ================================" -ForegroundColor Green
Write-Host "   $appName v$version - Setup" -ForegroundColor Green
Write-Host "  ================================" -ForegroundColor Green
Write-Host ""

try {
    # Create install directory
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    if (Test-Path $exePath) {
        Write-Host "  [*] Upgrading existing install: $installDir" -ForegroundColor Yellow
    } else {
        Write-Host "  [+] Created: $installDir" -ForegroundColor Green
    }

    # Copy exe
    Copy-Item "$srcDir\YIyicleaner.exe" -Destination $exePath -Force
    Write-Host "  [+] Copied: YIyicleaner.exe ($([math]::Round((Get-Item $exePath).Length / 1MB, 0)) MB)" -ForegroundColor Green

    # Copy icon
    if (Test-Path "$srcDir\favicon.ico") {
        Copy-Item "$srcDir\favicon.ico" -Destination "$installDir\favicon.ico" -Force
        Write-Host "  [+] Copied: favicon.ico" -ForegroundColor Green
    }

    # Copy uninstaller
    Copy-Item "$srcDir\uninstall.ps1" -Destination "$installDir\uninstall.ps1" -Force
    Write-Host "  [+] Copied: uninstall.ps1" -ForegroundColor Green

    # Create shortcuts via WScript.Shell
    $wsh = New-Object -ComObject WScript.Shell

    # Desktop shortcut
    $desktopShortcut = $wsh.CreateShortcut("$env:PUBLIC\Desktop\YiyeCleaner.lnk")
    $desktopShortcut.TargetPath = $exePath
    $desktopShortcut.WorkingDirectory = $installDir
    $desktopShortcut.IconLocation = "$exePath,0"
    $desktopShortcut.Description = "$appName v$version"
    $desktopShortcut.Save()
    Write-Host "  [+] Desktop shortcut created" -ForegroundColor Green

    # Start Menu
    $startMenuDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\YiyeCleaner"
    if (!(Test-Path $startMenuDir)) { New-Item -ItemType Directory -Path $startMenuDir -Force | Out-Null }
    $smShortcut = $wsh.CreateShortcut("$startMenuDir\YiyeCleaner.lnk")
    $smShortcut.TargetPath = $exePath
    $smShortcut.WorkingDirectory = $installDir
    $smShortcut.IconLocation = "$exePath,0"
    $smShortcut.Save()
    Write-Host "  [+] Start Menu shortcut created" -ForegroundColor Green

    # Register uninstall
    $uninstallReg = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\YiyeCleaner"
    New-Item -Path $uninstallReg -Force | Out-Null
    Set-ItemProperty -Path $uninstallReg -Name DisplayName -Value "$appName"
    Set-ItemProperty -Path $uninstallReg -Name DisplayIcon -Value $exePath
    Set-ItemProperty -Path $uninstallReg -Name UninstallString -Value "powershell -ExecutionPolicy Bypass -File `"$installDir\uninstall.ps1`""
    Set-ItemProperty -Path $uninstallReg -Name Publisher -Value "Yiye"
    Set-ItemProperty -Path $uninstallReg -Name DisplayVersion -Value $version
    Set-ItemProperty -Path $uninstallReg -Name NoModify -Value 1 -Type DWord
    Set-ItemProperty -Path $uninstallReg -Name NoRepair -Value 1 -Type DWord
    Write-Host "  [+] Registered in Add/Remove Programs" -ForegroundColor Green

    Write-Host ""
    Write-Host "  ================================" -ForegroundColor Green
    Write-Host "   Install complete!" -ForegroundColor Green
    Write-Host "   $installDir" -ForegroundColor Cyan
    Write-Host "  ================================" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "  [!] Install failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "  Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

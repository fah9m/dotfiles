# Module
Import-Module -Name Terminal-Icons

# Prompt
oh-my-posh init pwsh --config 'C:\Users\Fahim\AppData\Local\Programs\oh-my-posh\themes\robbyrussell.omp.json' | Invoke-Expression

# Alias
Set-Alias rm Remove-ItemSafely -Option AllScope

# PowerShell
Set-PSReadLineOption -Colors @{
    Command   = 'Yellow'
    Parameter = 'Green'
    String    = 'DarkCyan'
}

# Terminal
function reloadterminal { exit & wt }

# Winget
function ws { winget search @args }

function wi {
    winget install @args --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 1.5
    Remove-ItemSafely $HOME\Desktop\*.lnk, C:\Users\Public\Desktop\*.lnk 
}

function update { 
    Write-Host "Checking updates for WinGet packages..." -ForegroundColor "Cyan"
    winget upgrade --include-pinned

    Write-Host "`nChecking updates for Scoop packages..." -ForegroundColor "Cyan"
	scoop status

    Write-Host "`nChecking updates for Windows system..." -ForegroundColor "Cyan"
    gsudo Get-WindowsUpdate -Verbose
}

function upgrade {
    Write-Host "Upgrading WinGet packages..." -ForegroundColor "Cyan"
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpgrading Scoop packages..." -ForegroundColor "Cyan"
    scoop update
	scoop update --all
    scoop status

    Write-Host "`nUpgrading Pip binary..." -ForegroundColor "Cyan"
    python.exe -m pip install --upgrade pip

    Write-Host "`nUpgrading Pipx packages..." -ForegroundColor "Cyan"
    pipx upgrade-all --verbose
    
    Write-Host "`nUpgrading Windows system..." -ForegroundColor "Cyan"
    gsudo Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Verbose

    Remove-ItemSafely "$HOME\Desktop\*.lnk", "C:\Users\Public\Desktop\*.lnk"

    Write-Host "System and packages are up to date." -ForegroundColor "Green"
}

# Repair
function Check-WindowsHealth {
    gsudo DISM /Online /Cleanup-Image /CheckHealth
    gsudo DISM /Online /Cleanup-Image /ScanHealth
}

function Repair-WindowsHealth {
    gsudo sfc /scannow
    gsudo DISM /Online /Cleanup-Image /RestoreHealth
}

# Network
function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}

function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# File
function touch { param($name) New-Item -ItemType "file" -Path . -Name $name }
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

# HasteBin
function hb {
    if ($args.Length -eq 0) {
        Write-Error "No file path specified."
        return
    }
    
    $FilePath = $args[0]
    
    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
    }
    else {
        Write-Error "File path does not exist."
        return
    }
    
    $uri = "http://bin.christitus.com/documents"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
        $hasteKey = $response.key
        $url = "http://bin.christitus.com/$hasteKey"
        Set-Clipboard $url
        Write-Output $url
    }
    catch {
        Write-Error "Failed to upload the document. Error: $_"
    }
}

# Node
fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression

# Scoop
Invoke-Expression (&scoop-search --hook)

# Chocolatey
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

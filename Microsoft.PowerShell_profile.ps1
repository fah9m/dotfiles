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
    Write-Host "Checking winget updates..." -ForegroundColor "Cyan"
    winget upgrade --include-pinned

    Write-Host "`nChecking scoop updates..." -ForegroundColor "Cyan"
	scoop status

    Write-Host "`nChecking windows updates..." -ForegroundColor "Cyan"
    sudo Get-WindowsUpdate -Verbose
}

function upgrade {
    Write-Host "Updating winget packages..." -ForegroundColor "Cyan"
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpdating scoop packages..." -ForegroundColor "Cyan"
    scoop update
	scoop update --all
    scoop status

    Write-Host "`nUpdating pip..." -ForegroundColor "Cyan"
    python.exe -m pip install --upgrade pip

    Write-Host "`nUpdating pipx packages..." -ForegroundColor "Cyan"
    pipx upgrade-all --verbose
    
    Write-Host "`nUpdating windows..." -ForegroundColor "Cyan"
    sudo Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Verbose

    Remove-ItemSafely $HOME\Desktop\*.lnk, C:\Users\Public\Desktop\*.lnk
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
        Write-Output $url
    }
    catch {
        Write-Error "Failed to upload the document. Error: $_"
    }
}

# Node
fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression

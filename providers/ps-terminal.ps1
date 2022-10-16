function Ensure-Module {
    param (
        $Name,
        $Scope = "AllUsers"
    )
    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $Name}) {
        Write-Host "Module $Name is already imported."
        try {
            $a = Update-Module -Name $Name -Scope $Scope
        }
        catch {
            
        }
        
    }
    else{
        Install-Module $Name -Scope $Scope
    }
}


Write-Header "Setting up terminal"

Write-Stage "Installing Terminal modules"
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

#Ensure-Module PSReadLine
Ensure-Module Terminal-Icons

Ensure-Module WTToolBox
Ensure-Module npm-completion
Ensure-Module posh-git

Write-Stage "Installing Nerd Font"
if(!(Test-FontExists CascadiaCode)){
    oh-my-posh.exe font install CascadiaCode
}


Write-Stage "Installing oh-my-posh"
# Get-Content -Path "${HOME}/.configs/PS_Profile.ps1" | Set-Content -Path $PROFILE
if((Test-Path -Path $PROFILE -PathType leaf)){
    Remove-Item -Path $PROFILE
}
New-Item -Path $PROFILE -ItemType SymbolicLink -Value "${HOME}/.configs/PS_Profile.ps1" > $null


Write-Host "Configuring Windows Terminal"

$TerminalConfigFile = "$($env:LOCALAPPDATA)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$PrevTerminalConfigFile = "$($env:LOCALAPPDATA)\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"

$new = Get-Content "${HOME}/.configs/windows-terminal.json" | ConvertFrom-Json;
$a = Get-Content $PrevTerminalConfigFile -raw | ConvertFrom-Json;

merge $a $new 
$a | ConvertTo-Json -Depth 32 | set-content $PrevTerminalConfigFile


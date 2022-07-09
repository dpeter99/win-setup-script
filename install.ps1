. ./utils.ps1
. ./providers/winget.ps1

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
{
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   #$Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
}
else
{
   # We are not running "as Administrator" - so relaunch as administrator

   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
}

# Run your code that needs to be elevated here
#$appCount = 100
#for ($i = 1; $i -le 100; $i++ )
#{
#    $progress = (($i / $appCount) * 100);
    #Write-Host $progress
    #Write-Progress -Activity "Search in Progress" -Status "$i% Complete:" -PercentComplete $progress -Id 10
    #Start-Sleep -Milliseconds 250
#}
#Write-Progress -Activity "Search in Progress" -Status "$i% Complete:" -PercentComplete $progress -Id 10 -Completed $true

#Install New apps
$apps = @(
    @{mgr="winget"; name = "Google.Chrome" },

    @{mgr="winget"; name = "ShareX.ShareX" }, 
    @{mgr="winget"; name = "Microsoft.PowerShell" }, 
    @{mgr="winget"; name = "Microsoft.VisualStudioCode" }, 
    @{mgr="winget"; name = "Microsoft.WindowsTerminal"; source = "msstore" },
    @{mgr="winget"; name = "Microsoft.WindowsTerminal.Preview"; source = "msstore" },
    @{mgr="winget"; name = "JanDeDobbeleer.OhMyPosh"; source="winget"},
    @{mgr="winget"; name = "Microsoft.PowerToys" },

    @{mgr="winget"; name = "Notepad++.Notepad++" },
    @{mgr="winget"; name = "VideoLAN.VLC" },
    @{mgr="winget"; name = "7zip.7zip" },
    

    @{mgr="winget"; name = "JetBrains.Toolbox" },
    @{mgr="winget"; name = "CoreyButler.NVMforWindows"},
    
    @{mgr="winget"; name = "Git.Git" },
    @{mgr="winget"; name = "GitHub.GitLFS" },
    @{mgr="winget"; name = "Axosoft.GitKraken" },

    @{mgr="winget"; name = "GitHub.cli" }
    @{mgr="winget"; name = "Atlassian.Sourcetree" }

    @{mgr="winget"; name = "SlackTechnologies.Slack" }
    
    @{mgr="choco"; name = "lazygit" }
    @{mgr="choco"; name = "bazelisk" }

    
    @{mgr="winget"; name = "EclipseAdoptium.Temurin.11" }
    @{mgr="winget"; name = "Docker.DockerDesktop" }
    
);

$executionPolicy = Get-ExecutionPolicy;
if($executionPolicy -eq "Restricted"){
    Write-Host "Changing execution policy"
    Set-ExecutionPolicy Bypass -Scope Process
}

Write-Host "###############################################################"
Write-Host "Ensuring chocolaty is installed"
Ensure-Choco

$needsInstall = @();
ForEach -Parallel ($app in $apps) {



}

$appCount = $apps.Count;
Foreach ($app in $apps) {
    
    $i = ([array]::IndexOf($apps, $app));

    $PercentComplete = [int](($i / $appCount) * 100)
    Write-Progress -Activity "Installing" -Status "$PercentComplete%" -PercentComplete ($i/$appCount*100) -Id 0

    $i = ($i+1).ToString().PadLeft(2);
    $prefix = "[ " + $i + "/" + $appCount + " ]";

    

    switch ($app.mgr) {
        "winget" { 
            #check if the app is already installed
            $listApp = winget list --exact -q $app.name
            if (![String]::Join("", $listApp).Contains($app.name)) {
                Write-host $prefix " Installing:" $app.name
                if ($null -ne $app.source) {
                    winget install --exact --silent $app.name --source $app.source
                }
                else {
                    winget install --exact --silent $app.name 
                }
            }
            else {
                Write-host $prefix " Skipping Install of " $app.name
            }
        }
        "choco" { 
            #check if the app is already installed
            $listApp = choco list -r $app.name
            if (![String]::Join("", $listApp).Contains($app.name)) {
                Write-host $prefix " Installing:" $app.name
                if ($app.source -ne $null) {
                    choco install $app.name --source $app.source
                }
                else {
                    choco install $app.name 
                }
            }
            else {
                Write-host $prefix " Skipping Install of " $app.name
            }
        }
        Default {}
    }
    
}
Write-Progress -Activity "Installing" -Status "$PercentComplete%" -Completed -Id 0

Write-Host "##########################################################"
Write-Host "Installing WSL2"

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl --set-default-version 2


Write-Host "##########################################################"
Write-Host "Creating config folder"

if(!(Test-Path -Path "${HOME}/.configs" -PathType Container)){
    New-Item -Path "${HOME}" -Name ".configs" -ItemType "directory"
}
Write-Host "[   ] Copy configs"
robocopy "./.configs" "${HOME}/.configs" > $null

Write-Host "[   ] Set env varaiable ConfigLocation"
[System.Environment]::SetEnvironmentVariable('ConfigLocation',"${HOME}/.configs", 'User')

Write-Host "##########################################################"

Write-Host "Installing Node.js 18"
nvm install 18
nvm install 14.18.1
nvm use 14.18.1


Write-Host "##########################################################"
Write-Host "Setting up terminal"

Write-Host "Installing Terminal modules"
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Install-Module PSReadLine
Install-Module -Name Terminal-Icons -Repository PSGallery
Install-Module WTToolBox

Install-Module npm-completion -Scope CurrentUser
Install-Module posh-git -Scope CurrentUser -Force

Write-Host "Installing Nerd Font"
if(!(Test-FontExists CascadiaCode)){
    oh-my-posh.exe font install CascadiaCode
}


Write-Host "Installing oh-my-posh"
Get-Content -Path "${HOME}/.configs/PS_Profile.ps1" | Set-Content -Path $PROFILE
Add-Content -Path $PROFILE -Value 'oh-my-posh init pwsh --config "${env:ConfigLocation}/posh-terminal.json" | Invoke-Expression'


Write-Host "Configuring Windows Terminal"

$TerminalConfigFile = "$($env:LOCALAPPDATA)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$PrevTerminalConfigFile = "$($env:LOCALAPPDATA)\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"

$new = Get-Content "${HOME}/.configs/windows-terminal.json" | ConvertFrom-Json;
$a = Get-Content $PrevTerminalConfigFile -raw | ConvertFrom-Json;

merge $a $new 
$a | ConvertTo-Json -Depth 32 | set-content $PrevTerminalConfigFile


Write-Host "##########################################################"
Write-Host "Setting up work folders"

$workFolderName = "programing"
$workFolder = "${HOME}/" + $workFolderName

if(!(Test-Path -Path $workFolder -PathType Container)){
    New-Item -Path "${HOME}" -Name $workFolderName -ItemType "directory"
}
Write-Host "[   ] Copy configs"


Write-Host "[   ] Set env varaiable ConfigLocation"
[System.Environment]::SetEnvironmentVariable('Projects',$workFolderName, 'User')




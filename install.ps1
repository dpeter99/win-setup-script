Import-Module -Name "$PSScriptRoot/utils.psm1"
. ./providers/winget.ps1

$executionPolicy = Get-ExecutionPolicy;
if($executionPolicy -eq "Restricted"){
    Write-Host "Changing execution policy"
    Set-ExecutionPolicy Bypass -Scope CurrentUser
}

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

#Install New apps
$apps = @(
    @{mgr="winget"; name = "Google.Chrome" },
    # @{mgr="winget"; name = "9NCBCSZSJRSB"; source="msstore"}, # Spotify
    @{mgr="winget"; name = "Discord.Discord"},

    @{mgr="winget"; name = "ShareX.ShareX" },

    @{mgr="winget"; name = "Microsoft.PowerShell" }, 
    @{mgr="winget"; name = "Microsoft.VisualStudioCode" }, 
    @{mgr="winget"; name = "Microsoft.WindowsTerminal"; source = "msstore" },
    @{mgr="winget"; name = "Microsoft.WindowsTerminal.Preview"; source = "msstore" },
    @{mgr="winget"; name = "JanDeDobbeleer.OhMyPosh"; source="winget"},
    @{mgr="winget"; name = "Microsoft.PowerToys" },
    @{mgr="winget"; name = "9P7KNL5RWT25"; source="msstore"}, # Sysinternals
    

    @{mgr="winget"; name = "Notepad++.Notepad++" },
    @{mgr="winget"; name = "VideoLAN.VLC" },
    @{mgr="winget"; name = "7zip.7zip" },
    
    @{mgr="winget"; name = "PuTTY.PuTTY"},
    @{mgr="winget"; name = "WinSCP.WinSCP"},

    @{mgr="winget"; name = "JetBrains.Toolbox" },
    @{mgr="winget"; name = "CoreyButler.NVMforWindows"},
        
    @{mgr="winget"; name = "GnuPG.Gpg4win" },
    @{mgr="winget"; name = "Git.Git" },
    @{mgr="winget"; name = "GitHub.GitLFS" },
    @{mgr="winget"; name = "Axosoft.GitKraken" },
    @{mgr="winget"; name = "GitHub.cli" },
    @{mgr="winget"; name = "Atlassian.Sourcetree" },

    @{mgr="winget"; name = "SlackTechnologies.Slack" },

    @{mgr="winget"; name = "SparkLabs.Viscosity"},
    
    @{mgr="choco"; name = "lazygit" },
    @{mgr="choco"; name = "bazelisk" },
    @{mgr="choco"; name = "buildifier" },
    @{mgr="choco"; name = "buildozer" },
    
    @{mgr="winget"; name = "Python.Python.3"},

    @{mgr="winget"; name="Postman.Postman" },
    @{mgr="winget"; name="HeidiSQL.HeidiSQL"},

    #@{mgr="winget"; name = "EclipseAdoptium.Temurin.11" }
    @{mgr="winget"; name = "Docker.DockerDesktop" }
    @{mgr="winget"; name = "Mirantis.Lens" }
    @{mgr="winget"; name = "DominikReichl.KeePass" }
    @{mgr="winget"; name = "ChristianSchenk.MiKTeX" }
    @{mgr="winget"; name = "StrawberryPerl.StrawberryPerl" }
    
    @{mgr="winget"; name = "Obsidian.Obsidian"}

    @{mgr="choco"; name = "paint.net" }
);



Write-Host "###############################################################"
Write-Host "Ensuring chocolaty is installed"
Ensure-Choco

Write-Host "###############################################################"
Write-Host "Installing"

Foreach ($app in $apps) {
    
    $i = ([array]::IndexOf($apps, $app));

    $PercentComplete = [int](($i / $apps.Count) * 100)
    Write-Progress -Activity "Installing" -Status "$PercentComplete%" -PercentComplete ($i/$apps.Count*100) -Id 1

    $i = ($i+1).ToString().PadLeft(2);
    $prefix = "[ " + $i + "/" + $apps.Count + " ]";

    switch ($app.mgr) {
        "winget" { 
            #check if the app is already installed
            $listApp = winget list --exact -q $app.name
            if (![String]::Join("", $listApp).Contains($app.name)) {
                Write-host $prefix " Installing:" $app.name
                if ($null -ne $app.source) {
                    winget install --exact --silent $app.name --source $app.source | Write-Host
                }
                else {
                    winget install --exact --silent $app.name  | Write-Host
                }

                if($LASTEXITCODE -eq 0){
                    Write-host "$prefix Installing: ${app.name}" -ForegroundColor Green
                }
                else{
                    Write-host "$prefix Installing: ${app.name}" -ForegroundColor Red
                }
            }
            else {
                Write-host "$prefix Skipping Install of $($app.name)" -ForegroundColor DarkGreen
            }
        }
        "choco" { 
            #check if the app is already installed
            $listApp = choco list --local-only -r -e $app.name
            if ([string]::IsNullOrEmpty($listApp)) {
                Write-host $prefix " Installing:" $app.name
                if ($app.source -ne $null) {
                    choco install $app.name --source $app.source -y  | Write-Host
                }
                else {
                    choco install $app.name -y  | Write-Host
                }
            }
            else {
                Write-host "$prefix Skipping Install of $($app.name)" -ForegroundColor DarkGreen
            }
        }
        Default {}
    }
    
}
Write-Progress -Activity "Installing" -Status "$PercentComplete%" -Completed -Id 1

Write-Host "[   ] All Programs installed"

. ./providers/wsl2.ps1

Write-Host "##########################################################"
Write-Host "Creating config folder"

Ensure-Dir -Dir "${HOME}/.configs"

Write-Host "[   ] Copy configs"
robocopy "./.configs" "${HOME}/.configs" > $null

Write-Host "[   ] Create scripts folder"
Ensure-Dir -Dir "${HOME}/.configs/.scripts"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";${HOME}/.configs/.scripts", "User")

Write-Host "[   ] Set env varaiable ConfigLocation"
[System.Environment]::SetEnvironmentVariable('ConfigLocation',"${HOME}/.configs", 'User')

. ./providers/node.ps1

. ./providers/ps-terminal.ps1


Write-Host "##########################################################"
Write-Host "Setting up work folders"

$workFolderName = "programing"
$workFolder = "${HOME}/Documents/" + $workFolderName

if($Null -ne $env:Projects){
    $workFolder = $env:Projects;

    Write-Host "Found existing Project env config going with $env:Projects"
}
else{
    $decision = $Host.UI.PromptForChoice('Main folder', "What folder do you want to use for projects and SDks? /n $workFolder", @('&Custom'; '&Default'; '&None'), 1)

    if($decision -eq 0){
        $workFolder = Read-Host -Prompt "Enter your directory: "
    }
    elseif ($decision -eq 2) {
        return;
    }
}

if(!(Test-Path -Path $workFolder -PathType Container)){
    New-Item -Path "${HOME}" -Name $workFolderName -ItemType "directory"
}

Write-Host "[   ] Set env varaiable Projects"
[System.Environment]::SetEnvironmentVariable('Projects',$workFolder, 'User')


. ./providers/notes.ps1

Write-Host "Optional Features"

. ./providers/vulkan.ps1
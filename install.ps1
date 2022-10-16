Import-Module -Name "$PSScriptRoot/utils.psm1" -Force
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

. .\load_apps.ps1;

$apps = Load-AppsToInstall


Write-Header "Ensuring chocolaty is installed"
Ensure-Choco

Write-Header "Installing"

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

. ./providers/configs.ps1

. ./providers/node.ps1

. ./providers/ps-terminal.ps1


Write-Header "Setting up work folders"

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

Write-Header "Optional Features" -Color DarkYellow

. ./providers/vulkan.ps1
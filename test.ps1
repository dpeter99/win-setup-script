
Import-Module -Name "$PSScriptRoot/utils.psm1" -DisableNameChecking -Force

. .\load_apps.ps1;

$apps = Load-AppsToInstall


$apps | ForEach-Object {
    '{0}: {1}' -f $_.mgr, $_.name
};

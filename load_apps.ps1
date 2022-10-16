
function Load-AppsToInstall {
    param (
        
    )
    
    $apps_to_install = @();

    clear

    $decision = $Host.UI.PromptForChoice("Install apps", "Do you want to install apps?", @('&Yes'; '&No'), 1)
    if ($decision -eq 1) {
        return $apps_to_install
    }

    Get-ChildItem .\providers\app_sets | ForEach-Object {
        Import-Module -Name $_.FullName -Force -DisableNameChecking;

        $name = Get-Module -Name $_.FullName -ListAvailable 
        $func = Get-Command -Module $name;

        $newapps = . $func;
        $apps_to_install = $apps_to_install + $newapps;

        Remove-Module -Name $name;
    }


    Write-Header "The following apps will be installed: " -Color DarkYellow

    $apps_to_install | ForEach-Object {
        '{0}: {1}' -f $_.mgr, $_.name | Write-Host 
    };

    $decision = $Host.UI.PromptForChoice("Install apps", "Is this correct?", @('&Yes'; '&No'), 1)
    if ($decision -eq 1) {
        exit;
    }
    else {
        return $apps_to_install
    }

}


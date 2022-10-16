
$apps = @(
    @{mgr="winget"; name = "Valve.Steam"}
);

# EpicGames.EpicGamesLauncher

$Name = "Gaming apps"

function Basic-Apps {    
    $apps_list = @();

    Write-Header $Name
    $apps | ForEach-Object{
        Write-Host $_.Name;
    }

    $decision = $Host.UI.PromptForChoice($Name, "Do you want to install these programs?", @('&Yes'; '&No'), 1)
    if($decision -eq 1){
        return;
    } else {
        $apps_list += $apps
    }

    #Write-Host $apps_list;
    return $apps_list;
}
Export-ModuleMember -Function Basic-Apps
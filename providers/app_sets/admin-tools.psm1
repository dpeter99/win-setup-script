
$apps = @(
    @{mgr="winget"; name = "Microsoft.PowerToys" }
    @{mgr="winget"; name = "File-New-Project.EarTrumpet" }
    @{mgr="winget"; name = "9P7KNL5RWT25"; source="msstore"} # Sysinternals
);

$Name = "Power toys and sysinternals";

function Basic-Apps {    
    $apps_list = @();

    Write-Header $Name
    $apps | ForEach-Object{
        Write-Host $_.Name;
    }

    $decision = $Host.UI.PromptForChoice($Name, "Do you want to install these programs?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += $apps
    }

    #Write-Host $apps_list;
    return $apps_list;
}
Export-ModuleMember -Function Basic-Apps
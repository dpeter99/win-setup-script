
$apps = @(
    @{mgr="winget"; name = "PuTTY.PuTTY"}
    @{mgr="winget"; name = "WinSCP.WinSCP"}
);

$Name = "Remoting apps"

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
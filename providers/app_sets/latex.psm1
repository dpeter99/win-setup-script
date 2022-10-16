
function Basic-Apps {    
    $apps_list = @();

    Write-Header "Latex etc.."

    $decision = $Host.UI.PromptForChoice('Latex', "Do you want to install Latex?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += @(
            @{mgr="winget"; name = "ChristianSchenk.MiKTeX" }
            @{mgr="winget"; name = "StrawberryPerl.StrawberryPerl" }
        );
    }

    #Write-Host $apps_list;
    return $apps_list;
}
Export-ModuleMember -Function Basic-Apps
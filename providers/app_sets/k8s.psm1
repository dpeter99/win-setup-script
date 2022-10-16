
$Name = "Jetbrains-Toolbox";

function Basic-Apps {    
    $apps_list = @();

    Write-Header $Name

    $decision = $Host.UI.PromptForChoice('Docker', "Do you want to install Docker?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += @(
            @{mgr="winget"; name = "Docker.DockerDesktop" }
        );
    }

    $decision = $Host.UI.PromptForChoice('K8s', "Do you want to install Lens?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += @(
            @{mgr="winget"; name = "Mirantis.Lens" }
        );
    }

    #Write-Host $apps_list;
    return $apps_list;
}
Export-ModuleMember -Function Basic-Apps
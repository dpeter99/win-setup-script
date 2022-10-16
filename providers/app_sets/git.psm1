
$base = @(
    @{mgr="winget"; name = "Git.Git" }
    @{mgr="winget"; name = "GitHub.GitLFS" }
    @{mgr="winget"; name = "GnuPG.Gpg4win" }
    @{mgr="winget"; name = "GitHub.cli" }
);

$kraken = @(
    @{mgr="winget"; name = "Axosoft.GitKraken" }
);


$sourcetree = @(
    @{mgr="winget"; name = "Atlassian.Sourcetree" }
);

$Name = "Git Apps";

function Basic-Apps {    
    $apps_list = @();

    Write-Header $Name
    $base | ForEach-Object{
        Write-Host $_.Name;
    }

    $decision = $Host.UI.PromptForChoice("Basic Git", "Do you want to install these programs?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += $base
    }

    $decision = $Host.UI.PromptForChoice("Git Kraken", "Do you want to install these programs?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += $kraken
    }

    $decision = $Host.UI.PromptForChoice("source tree", "Do you want to install these programs?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += $sourcetree
    }

    $decision = $Host.UI.PromptForChoice("lazygit", "Do you want to install lazygit program?", @('&Yes'; '&No'), 1)
    if($decision -ne 1){
        $apps_list += @(@{mgr="choco"; name = "lazygit" })
    }

    #Write-Host $apps_list;
    return $apps_list;
}
Export-ModuleMember -Function Basic-Apps
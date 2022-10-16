
function Terminal-Apps {    
    $apps_list = @();

    Write-Header "Terminal applications.."

    $decision = $Host.UI.PromptForChoice('Terminal', "Do you want to install windows terminal programs?", @('&Yes'; '&No'), 1)
    if($decision -eq 1){
        return;
    } else {
        $apps_list += @{mgr="winget"; name = "Microsoft.PowerShell"};
        $apps_list += @{mgr="winget"; name = "Microsoft.WindowsTerminal"; source = "msstore" };
        $apps_list += @{mgr="winget"; name = "Microsoft.WindowsTerminal.Preview"; source = "msstore" };
        $apps_list += @{mgr="winget"; name = "JanDeDobbeleer.OhMyPosh"; source="winget"};
    }

    #Write-Host $apps_list;
    return $apps_list;
}
Export-ModuleMember -Function Terminal-Apps
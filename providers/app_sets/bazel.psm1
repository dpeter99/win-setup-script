
$Name = "Bazel";

function Bazel-Apps {    
    $apps_list = @();

    Write-Header $Name
    $apps | ForEach-Object{
        Write-Host $_.Name;
    }

    $decision = $Host.UI.PromptForChoice('Bazel', "Do you want to install bazel and related programs?", @('&Yes'; '&No'), 1)
    if($decision -eq 1){
        return;
    } else {
        $apps_list += @{mgr="choco"; name = "bazelisk" };
        $apps_list += @{mgr="choco"; name = "buildifier" };
        $apps_list += @{mgr="choco"; name = "buildozer" };
    }

    #Write-Host $apps_list;
    return $apps_list;
}
Export-ModuleMember -Function Bazel-Apps
function Notes {
    




    Write-Host "##########################################################"
    Write-Host "Setting up notes folders"

    $decision = $Host.UI.PromptForChoice('Notes Setup', "Do you want to clone a folder for git based not taking? /n $notesFolder", @('&Yes'; '&No'), 1)
    if($decision -eq 1){
        return;
    }

    $notesURL = Read-Host -Prompt "Enter the repo URL: "

    $notesFolderName = "_Notes"
    $notesFolder = $workFolder + "/" + $notesFolderName

    if($Null -ne $env:Notes){
        $notesFolder = $env:Notes;

        Write-Host "Found existing Project env config going with $env:Notes"
    }
    else{
        $decision = $Host.UI.PromptForChoice('Main folder', "What folder do you want to use for projects and SDks? /n $notesFolder", @('&Custom'; '&Default'; '&None'), 1)

        if($decision -eq 0){
            $notesFolder = Read-Host -Prompt "Enter your directory: "
        }
        elseif ($decision -eq 2) {
            return;
        }
    }

    if(!(Test-Path -Path $notesFolder -PathType Container)){
        New-Item $workFolder -ItemType "directory"
    }

    Write-Host "[   ] Set env varaiable Projects"
    [System.Environment]::SetEnvironmentVariable('Notes',$notesFolder, 'User')

    git clone $notesURL $notesFolder

    
    
}
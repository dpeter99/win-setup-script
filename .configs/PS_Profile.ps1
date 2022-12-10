Import-Module PSReadLine

Import-Module npm-completion

Import-Module posh-git

# Shows navigable menu of all options when hitting Tab
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Autocompleteion for Arrow keys
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -PredictionSource History

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

function Get-GHRepos {
    param ()
    
    $repos = gh repo list --json nameWithOwner,name,sshUrl | ConvertFrom-Json | ForEach-Object {
        return @{DisplayName= $_.nameWithOwner; Name= $_.name; ssh = $_.sshUrl}
    }

    return $repos;
}

Register-ArgumentCompleter -CommandName Project -ParameterName Name -ScriptBlock {
    param($commandName,
    $parameterName,
    $wordToComplete,
    $commandAst,
    $fakeBoundParameters)

    if ($fakeBoundParameters.ContainsKey('Type')) {
        $path = Get-PathForProjectType $fakeBoundParameters.Type
    } else {
        $path = Get-PathForProjectType ""
    }

    $res = Get-ChildItem -Path ($path) -Directory | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }

    $res += Get-GHRepos | ForEach-Object {
        if(!(($res.CompletionText) -contains $_.Name)){
            [System.Management.Automation.CompletionResult]::new($_.Name, "GH: " + $_.DisplayName, 'ParameterValue', $_.Name)
        }
    }

    return $res;
}


$types = @(
    "Own",
    "Test",
    "Work",
    "Others"
)

Register-ArgumentCompleter -CommandName Project -ParameterName Type -ScriptBlock {
    param($commandName,
    $parameterName,
    $wordToComplete,
    $commandAst,
    $fakeBoundParameters)

    if ($fakeBoundParameters.ContainsKey('Type')) {
        $path = Get-PathForProjectType $fakeBoundParameters.Type
    } else {
        $path = Get-PathForProjectType ""
    }

    $types | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}


function Get-PathForProjectType {
    param (
        $Type
    )
    $path = $env:Projects + "/_Projects/"
    
    switch ($Type) {
        "Test" { 
            $path = $env:Projects + "/_Tests/"
        }
        "Work" {
            $path = $env:Projects + "/_Work/"
        }
        "Others" {
            $path = $env:Projects + "/_Others/"
        }
        Default {
            if($Type){
                Write-Error "Could not find $Type"
            }
        }
    }
    
    return $path
}

function Project {
    param(
        $Name,
        $Type
    )
    $path = Get-PathForProjectType $Type

    $path = $path + $Name + "/" + $Name
    if(Test-Path -Path $path)
    {
        cd $path;
    }
    else{
        New-Item $Path -ItemType Directory | Out-Null
        cd $path;
    }

    $gh = Get-GHRepos | Where-Object Name -eq $Name

    if($null -ne $gh){
        
        if(!(Test-Path .git )){

            Write-Host "${gh.ssh}";

            $decision = $Host.UI.PromptForChoice('Clone from GH', 'Do you want to clone' + $gh.DisplayName, @('&Yes'; '&No'), 1)
            if($decision -eq 0){
                git clone $gh.ssh .
            }
        }
    }

    # Write-Host $path;
}

oh-my-posh init pwsh --config "$env:ConfigLocation/posh-terminal.json" | Invoke-Expression
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

    Get-ChildItem -Path ($path) -Directory | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
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
            $path = $env:HOMEPATH + "/Documents/_Work/"
        }
        Default {}
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
    # Write-Host $path;
}
oh-my-posh init pwsh --config "$env:ConfigLocation/posh-terminal.json" | Invoke-Expression
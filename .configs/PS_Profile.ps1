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
    param($commandName, $wordToComplete, $cursorPosition)
        Get-ChildItem -Path ($env:Projects + "/_Projects/") -Directory | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
        }
}

function Project {
    param(
        $Name
    )
    $path = $env:Projects + "/_Projects/" + $Name + "/" + $Name
    if(Test-Path -Path $path)
    {
        cd $path;
    }
    else{
        New-Item $Path -ItemType Directory | Out-Null
        cd $path;
    }
}
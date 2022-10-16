function Ensure-Choco {
    param ()

    if(Test-CommandExists choco){
        choco upgrade -r chocolatey
    }
    else{
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}
Export-ModuleMember -Function Ensure-Choco

Function Test-CommandExists
{
 Param ($command)
 $oldPreference = $ErrorActionPreference
 $ErrorActionPreference = 'stop'
 try {if(Get-Command $command){RETURN $true}}
 Catch {Write-Host “$command does not exist”; RETURN $false}
 Finally {$ErrorActionPreference=$oldPreference}
} #end function test-CommandExists

function Merge ($target, $source) {
    $source.psobject.Properties | % {
        if ($_.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject' -and $target."$($_.Name)" ) {
            merge $target."$($_.Name)" $_.Value
        }
        else {
            $target | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
        }
    }
}

Export-ModuleMember -Function Merge

function Test-FontExists 
{
    param (
        $name
    )
    $username = $env:UserName

    $check = $true
    $installedFonts = @(Get-ChildItem C:\Users\$username\AppData\Local\Microsoft\Windows\Fonts | Where-Object {$_.PSIsContainer -eq $false} | Select-Object basename)

    foreach($font in $installedFonts)
    {
        $font = $font -replace "_", ""
        $name = $name -replace "_", ""
        if ($font -match $name)
        {
            $check = $false
        }
    }
    return $check
}

Export-ModuleMember -Function Test-FontExists

function Ensure-Dir {
    param (
        $Dir
    )
    if(!(Test-Path -Path $Dir -PathType Container)){
        New-Item -ItemType Directory -Force -Path $Dir
    }
}

Export-ModuleMember -Function Ensure-Dir


function Write-Header {
    param (
        $Name,
        $Color = "DarkGreen"
    )
    Write-Host "################################################################"
    Write-Host -BackgroundColor $Color $Name -NoNewline
    Write-Host "";
}
Export-ModuleMember -Function Write-Header

function Write-Stage {
    param (
        $Name,
        $Color = "DarkGreen"
    )
    Write-Host "[   ] " -NoNewline
    Write-Host -BackgroundColor $Color $Name -NoNewline
    Write-Host "";
}
Export-ModuleMember -Function Write-Stage
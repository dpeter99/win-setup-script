Import-Module -Name "$PSScriptRoot/../utils.psm1"

Write-Host "##########################################################"
Write-Host "Creating config folder"

Ensure-Dir -Dir "${HOME}/.configs"

Write-Host "[   ] Copy configs"
robocopy "./.configs" "${HOME}/.configs" > $null

Write-Host "[   ] Create scripts folder"
Ensure-Dir -Dir "${HOME}/.configs/.scripts"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";${HOME}/.configs/.scripts", "User")

Write-Host "[   ] Set env varaiable ConfigLocation"
[System.Environment]::SetEnvironmentVariable('ConfigLocation',"${HOME}/.configs", 'User')
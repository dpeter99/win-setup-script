Write-Header "Creating config folder"

Ensure-Dir -Dir "${HOME}/.configs"

Write-Stage "Copy configs"
robocopy "./.configs" "${HOME}/.configs" > $null

Write-Stage "Create scripts folder"
Ensure-Dir -Dir "${HOME}/.configs/.scripts"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";${HOME}/.configs/.scripts", "User")

Write-Stage "Set env varaiable ConfigLocation"
[System.Environment]::SetEnvironmentVariable('ConfigLocation',"${HOME}/.configs", 'User')
function IsInstalled-Winget {
    param($Name)
    #check if the app is already installed
    $listApp = winget list --exact -q $Name
    if ([String]::Join("", $listApp).Contains($Name)) {
        return $true;
    }
    return $false;
}
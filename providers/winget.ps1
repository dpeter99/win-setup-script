function IsInstalled-Winget {
    param (
        Name
    )
    #check if the app is already installed
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name)) {
        return False;
    }
    return True;
}
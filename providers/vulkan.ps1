
Write-Host "Vulkan SDK"

if (!(Test-Path 'env:ImportStatus ')) {

    $decision = $Host.UI.PromptForChoice('VulkanSDK', 'Do you want to install VulkanSDK', @('&Yes'; '&No'), 1)
    if($decision -eq 0){
        $TargetDir = "${env:Projects}/_SDKs/Vulkan"
        Ensure-Dir $TargetDir

        $SDK_VERSION = "latest"
        $source = "https://sdk.lunarg.com/sdk/download/${SDK_VERSION}/windows/vulkan_sdk.exe"

        $destination = "${env:Projects}/_Tmp/Downloads"
        Ensure-Dir $destination
        $destFile = "$destination/vulkan_sdk.exe"
        
        if(!(Test-Path -Path $destFile)){
            Invoke-WebRequest -Uri $source -OutFile $destFile
        }

        & $destFile --root $TargetDir --accept-licenses --default-answer --confirm-command install


    }
}
else {
    Write-Host "Vulkan is already installed"
}
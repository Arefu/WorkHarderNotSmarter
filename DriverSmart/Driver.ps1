$ErrorCodes = @(
    "This device is working properly.",
    "This device is not configured correctly.",
    "Windows cannot load the driver for this device.",
    "The driver for this device might be corrupted, or your system may be running low on memory or other resources.",
    "This device is not working properly.One of its drivers or your registry might be corrupted.",
    "The driver for this device needs a resource that Windows cannot manage.",
    "The boot configuration for this device conflicts with other devices.",
    "Cannot filter.",
    "The driver loader for the device is missing.",
    "This device is not working properly because the controlling firmware is reporting the resources for the device incorrectly.",
    "This device cannot start.",
    "This device failed.",
    "This device cannot find enough free resources that it can use.",
    "Windows cannot verify this device's resources.",
    "This device cannot work properly until you restart your computer.",
    "This device is not working properly because there is probably a re-enumeration problem.",
    "Windows cannot identify all the resources this device uses.",
    "This device is asking for an unknown resource type.",
    "Reinstall the drivers for this device.",
    "Failure using the VxD loader.",
    "Your registry might be corrupted."
)

Get-WmiObject Win32_PNPEntity | ForEach-Object {
    Write-Host "Device Name: "$_.Name
    Write-Host "Device ID: "$_.DeviceID
    if($_.ConfigManagerErrorCode -gt 20) {
        Write-Host "Device Status: Unkown" -NoNewline
        Write-Host " ("$_.ConfigManagerErrorCode")" -ForegroundColor Yellow
        continue;
    }
    if($_.ConfigManagerErrorCode -ne 0)  {
        Write-Host "Device Status: "$ErrorCodes[$_.ConfigManagerErrorCode] -NoNewline
        Write-Host " ("$_.ConfigManagerErrorCode")" -ForegroundColor Red
    }
    else {
        Write-Host "Device Status: "$ErrorCodes[$_.ConfigManagerErrorCode] -NoNewline
        Write-Host " ("$_.ConfigManagerErrorCode")" -ForegroundColor Green
    }
}
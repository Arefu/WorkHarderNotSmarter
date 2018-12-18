param(
    [BOOL]$Debug = $True #Print Debug Messages
)

if($Debug -eq $True)
{
    Write-Host "Debug Mode Active..."
}

#11.0 = CC2017 12.0 = CC2018
$MediaCacheLocations = @(
    "HKCU:\Software\Adobe\Common 11.0\Media Cache"
    "HKCU:\Software\Adobe\Common 12.0\Media Cache"
)

$BridgeCacheLocation = "HKCU:\Software\Adobe\Bridge CC 2018\Preferences"

#What's Installed
$FoundAdobe = $False #Is An Adobe Product Installed?
$FoundAdobePath = "" #What Is It?

##
# This ForEach Goes Through The List Of Supported Adobe Products And Uses A Flag System To Determine What Is Installed.
##
$Path = "H:\\"
foreach($Version in $MediaCacheLocations)
{
    if(Test-Path $Version) #If Registry Path Exists We're Good To Edit.
    {
        if($Debug -eq $True)
        {
            Write-Host "Found: " $Version
        }
        if(Test-Path $Path)
        {
            Set-ItemProperty -Path $FoundAdobePath -Name "FolderPath" -Value $Path
            Set-ItemProperty -Path $FoundAdobePath -Name "DatabasePath" -Value $Path
        }
    }
}

if(Test-Path $BridgeCacheLocation)
{
    Set-ItemProperty -Path $BridgeCacheLocation -Name "CacheDirectory" -Value $Path
    Set-ItemProperty -Path $BridgeCacheLocation -Name "CompactCacheOnExit" -Value ([byte[]](0x01))
}

#Nothing Was Found, Close.
if($FoundAdobe -eq $False)
{  
    if($Debug -eq $True)
    {
        Write-Host "No Adobe Products Were Found, Closing."
    }
    Exit
}
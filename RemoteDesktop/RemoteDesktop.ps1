#$SupportedPackageNames = @("Microsoft.RemoteDesktop","Microsoft.MicrosoftRemoteDesktopPreview")
function New-RemoteDesktopGroup
{
}

function New-RemoteDesktopConnection
{
    param(
        [Parameter(Mandatory=$True)]
        [STRING]$HostName,
        [STRING]$FriendlyName = $HostName
        #Implement Thumbnail Generation
    )
    $ConnectionBody = '<SerializableModel i:type="a:DesktopModel" xmlns="http://schemas.datacontract.org/2004/07/RdClient.Shared.Data" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/RdClient.Shared.Models"><a:DisplaySettings i:type="a:DisplaySettingsModel"><a:PreferResolutionSync>true</a:PreferResolutionSync><a:Scale>100</a:Scale><a:SelectedResolution i:type="a:DefaultResolutionModel"/></a:DisplaySettings><a:FriendlyName>'+$FriendlyName+'</a:FriendlyName><a:HostName>'+$HostName+'</a:HostName><a:LocalResourcesSettings i:type="b:LocalResourcesSettingsModel" xmlns:b="http://schemas.datacontract.org/2004/07/RdClient.Shared.Models.Settings"><b:RedirectClipboard>true</b:RedirectClipboard></a:LocalResourcesSettings></SerializableModel>'
    $FileName = [GUID]::NewGuid()
    $ConnectionBody | Out-File "$($env:LOCALAPPDATA)\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\LocalWorkspace\connections\$($FileName).model" -Encoding utf8 -NoNewline
}

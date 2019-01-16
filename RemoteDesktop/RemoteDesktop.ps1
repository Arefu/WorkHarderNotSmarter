#$SupportedPackageNames = @("Microsoft.RemoteDesktop","Microsoft.MicrosoftRemoteDesktopPreview")
function New-RemoteDesktopGroup
{
    param(
        [Parameter(Mandatory=$True)]
        [STRING]$GroupName,
        [SWITCH]$IsExpanded
    )
    $TestGroup = "<SerializableModel i:type=`"a:GroupModel`" xmlns=`"http://schemas.datacontract.org/2004/07/RdClient.Shared.Data`" xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`" xmlns:a=`"http://schemas.datacontract.org/2004/07/RdClient.Shared.Models`"><a:IsExpanded>$($IsExpanded.IsPresent.ToString().ToLower())</a:IsExpanded><a:Name>$($GroupName)</a:Name></SerializableModel>"
    $TestGroup | Out-File "$($env:LOCALAPPDATA)\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\groups\$(New-Guid).model" -NoNewline -Encoding utf8
}

function New-RemoteDesktopConnection
{
    param(
        [Parameter(Mandatory=$True)]
        [STRING]$HostName,
        [STRING]$FriendlyName = $HostName
    )
    $ConnectionBody = '<SerializableModel i:type="a:DesktopModel" xmlns="http://schemas.datacontract.org/2004/07/RdClient.Shared.Data" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/RdClient.Shared.Models"><a:DisplaySettings i:type="a:DisplaySettingsModel"><a:PreferResolutionSync>true</a:PreferResolutionSync><a:Scale>100</a:Scale><a:SelectedResolution i:type="a:DefaultResolutionModel"/></a:DisplaySettings><a:FriendlyName>'+$FriendlyName+'</a:FriendlyName><a:HostName>'+$HostName+'</a:HostName><a:LocalResourcesSettings i:type="b:LocalResourcesSettingsModel" xmlns:b="http://schemas.datacontract.org/2004/07/RdClient.Shared.Models.Settings"><b:RedirectClipboard>true</b:RedirectClipboard></a:LocalResourcesSettings></SerializableModel>'
    $FileName = [GUID]::NewGuid()
    $ConnectionBody | Out-File "$($env:LOCALAPPDATA)\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\LocalWorkspace\connections\$($FileName).model" -Encoding utf8 -NoNewline
}

function New-RemoteDesktopThumbnail
{
    param(
        [Parameter(Mandatory=$True)]
        [STRING]$HostName,
        [Parameter(Mandatory=$True)]
        [STRING]$ImagePath
    )

    $FoundHost = $False
    $ConnectionFile = ""
    ForEach($Connection in Get-ChildItem "$($env:LOCALAPPDATA)\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\LocalWorkspace\connections\")
    {
        [XML]$ParsedConnection = Get-Content "$($env:LOCALAPPDATA)\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\LocalWorkspace\connections\$($Connection)"
        if($ParsedConnection.GetElementsByTagName("*")[0].'HostName'.ToLower() -eq $HostName.ToLower())
        {
            $FoundHost = $True
            $ConnectionFile = $Connection
        }
    }
    if($FoundHost -eq $False)
    {
        Write-Error "Couldn't Find Connection File For $($HostName)" -ErrorAction Stop
    }

    New-Item -Path "$($env:LOCALAPPDATA)\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\RemoteResourceThumbnails\$($ConnectionFile)" -Force
    $BaseImage = [CONVERT]::ToBase64String((get-content $ImagePath -encoding byte))
    $ThumbnailBody = "<SerializableModel i:type=`"a:RemoteResourceThumbnail`" xmlns=`"http://schemas.datacontract.org/2004/07/RdClient.Shared.Data`" xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`" xmlns:a=`"http://schemas.datacontract.org/2004/07/RdClient.Shared.Models`"><a:EncodedThumbnail>$($BaseImage)</a:EncodedThumbnail><a:ResourceId/></SerializableModel>"
    $ThumbnailBody | Out-File "$($env:LOCALAPPDATA)\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalState\RemoteDesktopData\RemoteResourceThumbnails\$($ConnectionFile)"-Encoding utf8 -NoNewline 
}

function Add-RemoteConnectionToGroup
{
    param(
        [Parameter(Mandatory=$True)]
        [STRING]$ConnectionHostName,
        [Parameter(Mandatory=$True)]
        [STRING]$GroupName
    )
}
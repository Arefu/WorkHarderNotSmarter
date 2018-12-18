#Default Is Admin
$RuckusUsername = ""
#Ruckus Password
$RuckusPassword = ""
#Ruckus URL
$RuckusLoginPage = ""
#Ruckus Session
$RuckusSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession


function Get-ActiveClients
{
    [CmdletBinding()]
    #Get 15 Active Clients By Default
    param(
        [INT]$Count = 15
    )
    
    #Login, Must Call New-RuckusSession First!
    LoginToRuckus
    
    #Grab Active Clients
    $Clients = Invoke-RestMethod ($Global:RuckusLoginPage + 'admin/_cmdstat.jsp') -WebSession $RuckusSession -Method POST -Body "<ajax-request action=`"getstat`" comp=`"stamgr`"><client LEVEL=`"1`"/><pieceStat start=`"1`" pid=`"1`" number=`"$($Count)`" requestId=`"clientsummary.1542690192161`"/></ajax-request>​"
    $Clients.'ajax-response'.response.'apstamgr-stat'.client | Format-Table
}

function Kick-Client
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [STRING]$MacAddress
    )

    #Make Sure It's A Valid Mac Address
    isValidMac $MacAddress

    #Login, Must Call New-RuckusSession First!
    LoginToRuckus

    #Kick Client
    Write-Host "Kicking: $($MacAddress)"
    $Request = Invoke-RestMethod ($Global:RuckusLoginPage+'/admin/_cmdstat.jsp') -WebSession $RuckusSession -Method POST -Body "<ajax-request action=`"docmd`" comp=`"stamgr`" updater=`"rid.0.4572582756167287`" xcmd=`"delete`" checkAbility=`"10`"><xcmd cmd=`"delete`" tag=`"client`" client=`"$($MacAddress)`"/></ajax-request>"
}

function Ban-Client
{
    [CmdletBinding()]
    param(
        [STRING]$MacAddress
    )

    #Make Sure It's A Valid Mac Address
    isValidMac $MacAddress

    #Login, Must Call New-RuckusSession First!
    LoginToRuckus

    #Ban Client
    Write-Host "Banning: $($MacAddress)"
    Invoke-RestMethod ($Global:RuckusLoginPage+'/admin/_cmdstat.jsp') -WebSession $RuckusSession -Method POST -Body "<ajax-request action=`"docmd`" comp=`"stamgr`" updater=`"rid.0.19497076422937598`" xcmd=`"block`" checkAbility=`"10`"><xcmd cmd=`"block`" tag=`"client`" client=`"$($MacAddress)`" acl-id=`"1`"/></ajax-request>" | Out-Null
}

function Unban-Client
{
    [CmdletBinding()]
    param(
        [STRING]$MacAddress
    )   

    isValidMac $MacAddress

    #Login, Must Call New-RuckusSession First!
    LoginToRuckus

    $Request = Invoke-RestMethod ($Global:RuckusLoginPage+'/admin/_conf.jsp') -WebSession $RuckusSession -Method Post -Body '<ajax-request action="getconf" comp="acl-list" updater="page.1542748775367.964"/>'
    $FoundMacAddress = $false
    foreach($Node in $Request.'ajax-response'.response.'acl-list'.acl.deny)
    {
        if($Node.'mac' -eq "$($MacAddress)") {
            $FoundMacAddress = $true
            $Node.ParentNode.RemoveChild($Node) | Out-Null
            $Request.Save("$($env:TEMP)\UnBanClients.xml")
        }
    }
    if($FoundMacAddress -eq $false) {
        Write-Error "Mac address not found in block list."
        return
    }
    [XML]$UpdatedList = Get-Content "$($env:TEMP)\UnBanClients.xml"
    Invoke-RestMethod ($Global:RuckusLoginPage+'/admin/_conf.jsp') -WebSession $RuckusSession -Method Post -Body "<ajax-request action=`"updobj`" comp=`"acl-list`" updater=`"blocked-clients`"><acl id=`"1`" name=`"System`" description=`"System`" default-mode=`"allow`" EDITABLE=`"false`">$($UpdatedList.'ajax-response'.response.'acl-list'.acl.InnerXml | Out-String)</acl></ajax-request>"
    Remove-Item "$($env:TEMP)\UnBanClients.xml" -Force
}

function Get-APEvent
{
    [CmdletBinding()]
    param(
        $Ap = "*",
        $StartFrom = 0,
        $Count = 15
    )

    #Login, Must Call New-RuckusSession First!
    LoginToRuckus
    
    #Grab Active Clients
    $Clients = Invoke-RestMethod ($Global:RuckusLoginPage + 'admin/_cmdstat.jsp') -WebSession $RuckusSession -Method POST -Body "<ajax-request action=`"getstat`" comp=`"eventd`" updater=`"apevent.1543284555289.3005`"><xevent ap=`"$($Ap)`" sortBy=`"time`" sortDirection=`"-1`"/><pieceStat start=`"$($StartFrom)`" pid=`"1`" number=`"$($Count)`" requestId=`"apevent.1543284555289.3005`"/></ajax-request>"
    $Clients.'ajax-response'.response.response.xevent.lmsg

}

function Get-ManagedAPs
{
    [CmdletBinding()]
    param(
        [INT]$APGroup = 0
    )

    #Login, Must Call New-RuckusSession First!
    LoginToRuckus
    
    #Grab Active Clients
    $Clients = Invoke-RestMethod ($Global:RuckusLoginPage + 'admin/_cmdstat.jsp') -WebSession $RuckusSession -Method POST -Body "<ajax-request action=`"getstat`" comp=`"stamgr`" updater=`"apg-getter.1543284555327.347`"><apgroupview/></ajax-request>"
    $Clients.'ajax-response'.response.'apgroupview'.group[$APGroup].'ap' | Select-Object id,mac,devname,description,model
}

function New-RuckusSession
{
    param(
        [CmdletBinding()]
        [Parameter(Mandatory=$True)]
        [STRING]$Uri,
        [Parameter(Mandatory=$True)]
        [STRING]$Password,

        [STRING]$Username = "admin",
        [SWITCH]$IgnoreCertificate
    )
    
    #Used If There Is No SSL Certificate
    if($IgnoreCertificate) {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }
    $Global:RuckusUsername = $Username
    $Global:RuckusPassword = $Password
    $Global:RuckusLoginPage = $Uri
}

function isValidMac
{
    if(-not [REGEX]::IsMatch($MacAddress,"^([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])$")) {
            Write-Error "$($MacAddress) is not a valid MAC Address, please check it and try again" -ErrorAction Stop
    }
}

function LoginToRuckus
{
    if([STRING]::IsNullOrWhiteSpace($Global:RuckusLoginPage)) {
        Write-Error "Call New-RuckusSession Before Calling This" -ErrorAction Stop
    }

    $Request = Invoke-WebRequest ($Global:RuckusLoginPage+'/admin/login.jsp') -WebSession $RuckusSession -Method POST -Body "username=$($Global:RuckusUsername)&password=$($Global:RuckusPassword)&ok=Log+In"
    if(($Request).ParsedHtml.title -eq "Log In") {
        Write-Error "Failed to login to $($Global:RuckusLoginPage), check Username/Password" -ErrorAction Stop
    }
}
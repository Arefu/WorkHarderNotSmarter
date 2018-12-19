[String]$PhoneIP = ""
[String]$User= ""
[String]$Pass= ""
$PhoneSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

#This Is Important, It's The Auth Token For The Session!!!
[String]$Token = ""

#Setup Connection To Phone
function New-YealinkSession
{
    param(
        [Parameter(Mandatory=$true)]
        [String]$PhoneIP,
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter()]
        [String]$Username = "admin"
    )

    testConnection

    #Post Login With Information
    $PostBody = "username=$($Username)&pwd=$($Password)&jumpto=status&acc="
    (Invoke-WebRequest -Uri "http://$($PhoneIP)/servlet?p=login&q=login" -Body $PostBody -Method Post -WebSession $PhoneSession -Headers @{"Expect"="200-ok"}) -match "(\d{9})" | Out-Null
    $Script:Token = $Matches[0] #This Token shows we're auth'd, it needs to be included in most (if not all?) post requests.
    $Token
}

function Restart-Phone
{
    param(
        [Parameter(Mandatory=$true)]
        [String]$PhoneIP
    )

    testConnection

    Invoke-WebRequest -Uri "http://$($PhoneIP)/servlet?p=settings-upgrade&q=reboot" -Body "token=$($Script:Token)" -Method Post -WebSession $PhoneSession | Out-Null
    Write-Warning "Phone reboot request sent, You will NEED to call New-YeaLinkSession after it reboots."
    #Has To Be A Fresh(Prince of Bel-Air) Session and Token since the session state is invalidated after a reboot.
}

function Set-PhoneAccount
{
    param(
        [Parameter(Mandatory=$True)]
        [String]$PhoneIP,
        [Parameter(Mandatory=$True)]
        [String]$LoginAddress,
        #Just Default To Using Login Address As Well...
        [String]$RegisterName = $LoginAddress,
        [Parameter(Mandatory=$True)]
        [String]$Password
    )
    $PostBody = ("var_accountID=0&server1=$([URI]::EscapeDataString($LoginAddress))&AccountRegisterName=$([URI]::EscapeDataString($RegisterName))&AccountPassword=$($Password)&token=$($Script:Token)")
    Invoke-WebRequest -Uri "http://$($PhoneIP)/servlet?p=account-register-lync&q=write&acc=0" -Body $PostBody -Method Post -WebSession $PhoneSession -Headers @{"Host"=$PhoneIP}| Out-Null
}

function testConnection
{
    Write-Progress "Testing Connection To Phone"
    Test-Connection $PhoneIP -Count 2 -Quiet | Out-Null
    if( -not $?)
    {
        Write-Error "Phone is offline or otherwise unreachable..." -ErrorAction Stop
    }
}
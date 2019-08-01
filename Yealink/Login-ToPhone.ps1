#$ErrorActionPreference="SilentlyContinue"

$Scopes = @(
    
)
$Phones = New-Object System.Collections.ArrayList

function Login-ToPhone
{
    param(
        $Phone
    )

    $PhoneSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

    #$Phone.IPAddress = "10.57.178.30"
    Write-Host $Phone.IPAddress
    
    $Body = Invoke-WebRequest -Uri "http://$($Phone.IPAddress)/servlet?p=login&q=login" -Body "username=admin&pwd=***&jumpto=account-register-lync" -WebSession $PhoneSession -Method Post -Headers @{"Expect"="200-ok"} #-ErrorAction Suspend
    $Body -Match "(\d{11}|\d{10}|\d{9})" | Out-Null
    $LoginToken = $Matches[0]
    $Body.RawContent -Match "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | Out-Null #Don't You Just LOVE Regex?
    $User = $Matches[0]

    Write-Host "Success! (Didn't See That Coming...) Token: $LoginToken User:$User"
    $User = $User.Substring(0, $User.LastIndexOf('.'))
    $User = $User+".nz" #Just making sure it ENDS in .nz not some random letters
    $User = [URI]::EscapeDataString($User)
        
    Invoke-WebRequest -Uri "http://$($Phone.IPAddress)/servlet?p=account-register-lync&q=write&acc=0" -Body "var_accountID=0&server1=$($User)&AccountRegisterName=$($User)&AccountPassword=********&token=$($LoginToken)" -WebSession $PhoneSession -Method Post -Headers @{"Expect"="200-ok"} | Out-Null
    Write-Host "Sweet Victory!"    
}

foreach($Scope in $Scopes)
{
    Write-Host "Checking $Scope"
    $Clients = $(Get-DhcpServerv4Lease $Scope | Select-Object IPAddress,ClientId,HostName)
    foreach($Client in $Clients)
    {
        if($Client.HostName -ne $null -and $Client.ClientId -ne $null)
        {
            if($Client.HostName.StartsWith("YEALINK") -or $Client.ClientId.StartsWith("00-15-65-92"))
            {
                Test-Connection $Client.IPAddress -Count 2 -Quiet | Out-Null
                if(-not $?)
                {
                    Write-Warning "Phone $($Client.HostName) is offline or otherwise unreachable..."
                    continue   
                }

                Write-Host "Logging In: $($Client.HostName)"
                Login-ToPhone $Client
            }
        }
    }
    Write-Host "----------"
}
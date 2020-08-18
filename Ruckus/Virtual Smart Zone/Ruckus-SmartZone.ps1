function New-RuckusSession
{
    param(
        [Parameter(Mandatory=$true)]
        [Uri]$Uri,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential
    )
    
    $Execution = ((Invoke-WebRequest -Uri $Uri -SessionVariable Session).InputFields | Where-Object 'name' -Like 'execution').Value
    $Body = $("username="+$($Credential.UserName)+"&password="+$($Credential.GetNetworkCredential().Password+"&execution="+$Execution+"&_eventId=submit&geolocation="))
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36"
    $Time = [LONG](New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalMilliseconds

    $Headers = @{'Content-Type' = "text/plain;charset=UTF-8"}

    Invoke-WebRequest -Method Post -Uri $Uri -Body $Body -UserAgent $UserAgent -WebSession $Session

    #Invoke-WebRequest -Headers $Headers -Method Post -Uri ("https://SNIP/wsg/api/public/v8_0/query/client?_dc="+$Time) -WebSession $Session -Body '{"filters":[{"type":"DOMAIN","value":"SNIP"}],"fullTextSearch":{"type":"AND","value":""},"attributes":["*"],"sortInfo":{"sortColumn":"clientMac","dir":"ASC"},"page":1,"limit":8}'

     
}

function Get-ActiveClient
{
}
New-RuckusSession "https://SNIP/cas/login?service=/wsg/login/cas" 
$Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36"

function New-RuckusSession
{
    param(
        [Parameter(Mandatory=$true)]
        [Uri]$Uri,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential
    )
    
    $Execution = ((Invoke-WebRequest -Uri $Uri -WebSession $Session).InputFields | Where-Object 'name' -Like 'execution').Value
    $Body = $("username="+$($Credential.UserName)+"&password="+$($Credential.GetNetworkCredential().Password+"&execution="+$Execution+"&_eventId=submit&geolocation="))
    $Time = [LONG](New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalMilliseconds
    $Headers = @{'Content-Type' = "text/plain;charset=UTF-8"}

    Invoke-WebRequest -Method Post -Uri $Uri -Body $Body -UserAgent $UserAgent -WebSession $Session | Out-Null

    #Invoke-WebRequest -Headers $Headers -Method Post -Uri ("https://SNIP/wsg/api/public/v8_0/query/client?_dc="+$Time) -WebSession $Session -Body '{"filters":[{"type":"DOMAIN","value":"SNIP"}],"fullTextSearch":{"type":"AND","value":""},"attributes":["*"],"sortInfo":{"sortColumn":"clientMac","dir":"ASC"},"page":1,"limit":8}'

     
}

function Get-ActiveClient
{
}

function Get-GetAPClientConnectedTo
{
param(
        [Parameter(Mandatory=$true)]
        [String]$Client,
        [Parameter(Mandatory=$true)]
        [String]$Uri
    )
    $Time = [LONG](New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalMilliseconds
    #DOMAIN = Unique, Find Out Where It Is, Then Use IT?
    $Body = "{`"filters`":[{`"type`":`"DOMAIN`",`"value`":`"08725585-ea83-431e-9173-516b4db1b360`"}],`"fullTextSearch`":{`"type`":`"AND`",`"value`":`""+$Client+"`"},`"attributes`":[`"*`"],`"sortInfo`":{`"sortColumn`":`"clientMac`",`"dir`":`"ASC`"},`"page`":1,`"limit`":8}"
    $Headers = @{'Content-Type' = "text/plain;charset=UTF-8"; 'X-Requested-With' = "XMLHttpRequest"}
    $Reply = Invoke-WebRequest -UserAgent $UserAgent -Method Post -WebSession $Session -Uri ("https://"+$Uri+":8443/wsg/api/public/v8_0/query/client?_dc="+$Time) -Body $Body -Headers $Headers
    $Content = $Reply.Content | ConvertFrom-Json
   
    $Reply = Invoke-WebRequest -UserAgent $UserAgent -Method Get -WebSession $Session -Uri ("https://"+$Uri+":8443/wsg/api/scg/aps/"+$Content.'list'[0].'apMac'+"/config?_dc="+$Time)
    $Content = $Reply.Content | ConvertFrom-Json
    $Content.'data'.'description'
}

New-RuckusSession "https://ruckuswifi.n4l.co.nz:8443/cas/login?service=/wsg/login/cas" 
Get-GetAPClientConnectedTo -Uri "ruckuswifi.n4l.co.nz" -Client "F8:1F:32:15:32:26"

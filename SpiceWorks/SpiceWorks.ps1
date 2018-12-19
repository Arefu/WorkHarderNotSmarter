[CmdletBinding()]
Param(
[string] $url = "",
[string] $username = "",
[string] $password = ''
)

$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:63.0) Gecko/20100101 Firefox/63.0"
$headers = @{"Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"; "Accept-Encoding"="gzip, deflate"; "Accept-Language"="en-US,en;q=0.5";}
$LogonPage = Invoke-WebRequest ($url) -SpiceSessionVariable SpiceSession -UserAgent $userAgent -Headers $headers
$CookieContainer = New-Object System.Net.CookieContainer
$SpiceSession.Headers.Add("Cookie", $CookieContainer.GetCookieHeader($url))

$formFieldsText = "authenticity_token="+[System.Net.WebUtility]::UrlEncode($LogonPage.Forms[0].Fields["authenticity_token"])+"&_pickaxe=%E2%B8%95&pro_user%5Bemail%5D="+[System.Net.WebUtility]::UrlEncode($username)+"&pro_user%5Bpassword%5D="+[System.Net.WebUtility]::UrlEncode($password)+"&pro_user%5Bremember_me%5D=0"

$Reply = Invoke-WebRequest ($url) -WebSpiceSession $SpiceSession -Method POST -Body $formFieldsText -UserAgent $userAgent -Headers $headers -ErrorAction SilentlyContinue | Out-Null
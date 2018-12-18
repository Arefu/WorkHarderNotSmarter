# Ruckus

This PowerShell script will let you interact with ZoneDirector on a very basic level, I've only taken the time to figure out what areas that I use, it should be easy for you to expand on what I've already learnt through my time poking about using [Fiddler](HTTPS://www.telerik.com/fiddler). This was tested on Ruckus ZoneDirector version: *9.13.3.0 build 41.* I take no responsibility for any network outage that these scripts cause.

## Functions

**Name**: `New-RuckusSession`

**Description**: This will create a connection to Ruckus and **NEEDS** to be called before any other functions as it sets up global varibles used throughout the script.

**Parameters**: 
* [*Mandatory*] Uri `String`
This should be the URL that is used to get to the ZoneDirector Interface.
E.G. `ruckus.Contoso.com/`
Be sure to include the trailing slash.
* Username `String`
This should be the username of a user who has access to the ZoneDirector, it defaults to a value of `Admin`.
* [*Mandatory*] Password `String`
This is the password of the user that will be used to access the ZoneDirector Interface.
* IgnoreCertificate `Switch`
This switch should be used if you're ZoneDirector isn't using an SSL Certificate.

___

**Name**: `Get-ManagedAPs`

**Description**: This will return a list of all APs registered inside Ruckus' ZoneDirector.

**Parameters**:

* ApGroup `Int`
This parameter is for showing APs that aren't in the default (`0`) group.

___

**Name**: `Get-APEvent`

**Description**: This will show a list of all AP Events similar to Ruckus' event log on the admin interface.

**Parameters**: 
* Ap `Unkown`
<Unkown> I couldn't work this out, but made it a param incase someone does
* StartFrom `Int`
This is used for setting the start index so you can start pulling logs from that location onwards.
* Count `Int`
This is used to determine how many log messages you're wanting to pull down, it has a default value of `15`

___

**Name**: `Ban-Client`

**Description**: This bans the specified Mac Address; use caution as this command will block access for the specified Mac Address until you unban them.

**Parameters**:
* MacAddress `String`
This needs to be a valid Mac Address.

___

**Name**: Unban-Client

**Description**: This will unban the specified Mac Address, it does the reverse of `Ban-Client`

**Parameters**:
* MacAddress `String`
This needs to be a valid Mac Address

___

**Name**: Kick-Client

**Description**: This will temporarily kick a client from the network, take note the client is welcome to rejoin whenever it wants, it is only useful for debugging.

**Parameters**:
* MacAddress `String`
This needs to be a valid Mac Address

___

**Name**: Get-ActiveClients

**Description**: This will show you all connected clients to all your APs with some helpful information about them such as the Mac of the connected AP and the client's Mac Address.

**Parameters**:
* Count `Int`
This defaults to 15 but can be changed to any number, it will return this many clients.

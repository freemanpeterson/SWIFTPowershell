
# Program:            SWIFTPowershell
### Written by:         Freeman Peterson fjpeterson@nd.gov
#### Functionality depends on you setting FQDN(Example: Computer.Domain.Com) for each node. 
You may use Set-SWDNS to make your environment complaint. 

This module is not part of SWIFT or SolarWinds TradeMark.
This requires SWISPowershell to be installed.

This module is designed to make system administration easier. I plan to add in functionality as time goes on(Stay Tuned!)


```
Install instructions:
Install git
cd "c:\Program Files\WindowsPowershell\Modules\"
git clone https://github.com/freemanpeterson/SWIFTPowershell.git
copy config.json.sample config.json
ise config.json - Edit as needed
````
```
Cmdlets Included:
Get-SWVar
Set-SWPassword
Get-SWNode
Get-SWApp
Get-SWNodeDuplicate
Get-SWGroup
Add-SWPoller
Test-SWNode
Get-SWProblemNode
Get-SWNodeCustomProperties
Set-SWNodeCustomProperty
Get-SWNodeDNSNotFQDN
Send-MailPSObject
Set-SWDNS
Update-SWDNS
Set-SWDNSList
Set-SWGroupMute
Get-SWGroupMute
Set-SWGroupMuteSchedule
Get-SWNodeMuteSchedule
```
```
Get examples by preforming help on each cmdlet:
Get-help Set-SWDNS -examples
```

```
Terms of use: 
It is free if you send me an email freemanpeterson@gmail.com. 
If you are downloading mail with subject "SWIFTPowershell Install".

Support:
If you have a questions mail with subject "SWIFTPowershell Question"
If you have a request mail with subject "SWIFTPowershell Request"
````
Have fun!

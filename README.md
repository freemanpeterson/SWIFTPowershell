
# Program:            SWIFTPowershell.psm1
## Installation Path:  C:\Program Files\WindowsPowerShell\Modules\SWIFTPowershell
### Written by:         Freeman Peterson fjpeterson@nd.gov
#### Notes:              Most of the script functionaly depends on FQDN as ComputerName.
####                     Example: Computer.Domain.Com

This module is not part of SWIFT or SolarWinds TradeMark.
This requires SWISPowershell to be installed.

This module is designed to make system administration easier. I plan to add in functionality as time goes on(Stay Tuned!)


```
Install instructions:
1) copy config.json.sample to config.json
2) edit config.json as needed
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

Terms of use: 
You are free if you send me a email freemanpeterson@gmail.com

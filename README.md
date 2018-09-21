
# Program:            SWIFTPowershell
### Written by:         Freeman Peterson fjpeterson@nd.gov
### Installation Path:  C:\Program Files\WindowsPowerShell\Modules\SWIFTPowershell
#### Notes:              Most of the script functionaly depends on FQDN as ComputerName.
####                     Example: Computer.Domain.Com

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
Terms of use: 
It is free if you send me an email freemanpeterson@gmail.com. Subject must be "SWIFTPowershell Install".
If you have questions email me with the subject "SWIFTPowershell Question"
If you have some advice or request send me a email with the subject "SWIFTPowershell Advice"
````
Have fun!

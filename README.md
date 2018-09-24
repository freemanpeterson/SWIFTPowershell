
# SWIFTPowershell
### Written by:         Freeman Peterson fjpeterson@nd.gov
#### 

SWISPowershell is a good module and resource frendly. However, sometimes it just not as easy as running a simple cmdlet. This module is designed to make system administration easier. 
I plan to add in functionality as time goes on. (Stay Tuned!)

Prerequisites:
+ Install git (https://git-scm.com/download/win)
+ Install SWISPowerShell (https://www.powershellgallery.com/packages/SwisPowerShell/2.3.0.108)
+ This module depends on you setting FQDN (Example: Computer.Domain.Com) for each node. 
  - You may use Set-SWDNS to make your environment complaint. 

Install SWIFTPowershell:
```
cd "c:\Program Files\WindowsPowershell\Modules\"
git clone https://github.com/freemanpeterson/SWIFTPowershell.git
cd SWIFTPowershell
copy config.json.sample config.json
# Edit as needed
ise config.json 
````
Cmdlets Included:
```
Add-SWWinNode
Add-SWGroup
Add-SWPoller
Get-SWApp
Get-SWGroup
Get-SWGroupMute
Get-SWNode
Get-SWNodeCustomProperties
Get-SWNodeDNSNotFQDN
Get-SWNodeDuplicate
Get-SWNodeMuteSchedule
Get-SWProblemNode
Get-SWVar
Send-MailPSObject
Set-SWDNS
Set-SWDNSList
Set-SWGroupMute
Set-SWGroupMuteSchedule
Set-SWNodeCustomProperty
Set-SWPassword
Test-SWNode
Update-SWDNS
```
How to get examples and description of each cmdlet:
```
Get-Help Set-SWDNS -Examples
```

Terms of use: 
```
It is free if you send me an email freemanpeterson@gmail.com. 
If you are downloading mail with subject "SWIFTPowershell Install".
```
Support:
```
If you have a question mail with subject "SWIFTPowershell Question"
If you have a request mail with subject "SWIFTPowershell Request"
```
Legal:
+ This module is not part of SWIFT or SolarWinds TradeMark


# SWIFTPowershell
#### Written by:         Freeman Peterson freemanpeterson@gmail.com

The common module *SWISPowershell* is a good module and resource frendly. However, it is not as easy as running a simple cmdlet. This module is designed to make system administration easier. 
I plan to add functionality as time goes on. (Stay Tuned!)

Prerequisites
+ Install git (https://git-scm.com/download/win)
+ Install SWISPowerShell (https://www.powershellgallery.com/packages/SwisPowerShell/2.3.0.108)
+ This module depends on you setting FQDN (Example: Computer.Domain.Com) for each node. 
  - You may use Set-SWDNS to make your environment complaint. 

### Install
```
cd "c:\Program Files\WindowsPowershell\Modules\"
git clone https://github.com/freemanpeterson/SWIFTPowershell.git
cd SWIFTPowershell
```
Copy Configuration Sample
```
copy config.json.sample config.json
```
Edit Configuration
```
ise config.json 
````
Available Cmdlets
```
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
How to get examples and description of each cmdlet
```
Get-Help Set-SWDNS -Examples
```

Terms of use
```
It is free if you send me an email freemanpeterson@gmail.com. 
If you are downloading mail with subject "SWIFTPowershell Install".
```
Support
```
If you have a question mail with subject "SWIFTPowershell Support"
```
Legal
+ This module is not part of *SWIFT* ™ or *SolarWinds*™ 

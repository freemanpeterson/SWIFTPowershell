
# SWIFTPowershell
#### Written by:         Freeman Peterson freemanpeterson@gmail.com
#### 

SWISPowershell is a good module and resource frendly. However, sometimes it just not as easy as running a simple cmdlet. This module is designed to make system administration easier. 
Prerequisites:
+ Install git (https://git-scm.com/download/win)
+ Install SWISPowerShell (https://www.powershellgallery.com/packages/SwisPowerShell/2.3.0.108)
+ This module depends on you setting FQDN (Example: Computer.Domain.Com) for each node. 
  - You may use Set-SWDNSList -File /tmp/dns.txt  to make your environment complaint. 
+ This module requires network credentials and they must match computer and solarwinds.

Install SWIFTPowershell:
```
cd "c:\Program Files\WindowsPowershell\Modules\"
git clone https://github.com/freemanpeterson/SWIFTPowershell.git
cd SWIFTPowershell
copy config.json.sample config.json
# Edit as needed
ise config.json 
````
Update SWIFTPowershell:
```
cd "c:\Program Files\WindowsPowershell\Modules\SWIFTPowershell"
git pull
````
Cmdlets Included:
```
Add-SWNodeWin               - Add a Windows WMI SolarWinds node.
Add-SWGroup                 - Add a SolarWinds group.
Add-SWPoller                - Add a SolarWinds poller.
Get-SWApp                   - Get a list of SolarWinds application templates.
Get-SWGroup                 - Get SolarWinds groups.
Remove-SWGroup              - Remove a Solarwinds group.
Get-SWGroupMute             - Mute a SolarWinds group.
Get-SWNode                  - Get a list of SolarWinds nodes.
Get-SWNodeCustomProperties  - Get SolarWinds node custom properties.
Get-SWNodeDNSNotFQDN        - Get SolarWinds node that have a full qualified DNS name.
Get-SWNodeDuplicate         - Get SolarWinds node caption names that are not unique.
Get-SWNodeMuteSchedule      - Get SolarWinds node mute schedule.
Get-SWNodeProblem           - Get SolarWinds nodes that have problems.
Get-SWVar                   - Get SWIFTPowershell script variables.
Send-SWMailPSObject         - Send a Powershell object via email in csv or html format.
Set-SWDNS                   - Set SolarWinds node DNS name.
Set-SWDNSList               - Sets a list of SolarWind nodes to DNS name.
Set-SWGroupMute             - Set SolarWinds group to mute.
Set-SWGroupMuteSchedule     - Set SolarWinds group to mute on schedule.
Set-SWNodeCustomProperty    - Set SolarWinds node custom property.
Set-SWPassword              - Set SWIFTPowershell password.
Test-SWNode                 - Test SolarWinds node.
Update-SWDNS                - Update SolarWinds node DNS by caption name.
Remove-SWNode               - Remove SolarWinds node DNS.
Set-SWAppMute               - Set Solarwinds application template to mute
```
Check out WIKI for examples:
https://github.com/freemanpeterson/SWIFTPowershell/wiki

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
```
Legal:
+ This module is not part of SWIFT™ or SolarWinds™


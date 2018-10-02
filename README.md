
# SWIFTPowershell
### Written by:         Freeman Peterson fjpeterson@nd.gov
#### 

SWISPowershell is a good module and resource frendly. However, sometimes it just not as easy as running a simple cmdlet. This module is designed to make system administration easier. 
I plan to add in functionality as time goes on.

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
Add-SWNodeWin                - Add a windows WMI solarwinds node
Add-SWGroup                  - Add a SolarWinds Group
Add-SWPoller                 - Add a SolarWinds Poller
Get-SWApp -                  - Get a List of SolarWinds Application Templates
Get-SWGroup                  - Get SolarWinds Groups
Remove-SWGroup               - Remove a Solarwinds Group
Get-SWGroupMute              - Mute a SolarWinds Group
Get-SWNode                   - Get a list of SW Nodes
Get-SWNodeCustomProperties  - Get SolarWinds Node Custom Properties
Get-SWNodeDNSNotFQDN        - Get SolarWinds Node that have a full qualified DNS Name
Get-SWNodeDuplicate         - Get SolarWinds node caption names that are not unique
Get-SWNodeMuteSchedule      - Get SolarWinds Node Mute Schedule
Get-SWNodeProblem           - Get SolarWind Nodes that have Problems
Get-SWVar                   - Get SWIFTPowershell Script Variables
Send-SWMailPSObject         - Send a Powershell Object via Email in csv or html format
Set-SWDNS                   - Set SW Node DNS NAME
Set-SWDNSList               - Sets a list of SolarWind Nodes to dns name
Set-SWGroupMute             - Set SolarWinds Group to Mute
Set-SWGroupMuteSchedule     - Set SolarWinds Group to Mute on Schedule
Set-SWNodeCustomProperty    - Set SolarWinds Node Custom Property
Set-SWPassword              - Set SWIFTPowershell Password
Test-SWNode                 - Test SolarWinds Node
Update-SWDNS                - Update SolarWinds node DNS
Remove-SWNode               - Remove SolarWinds node DNS
Set-SWAppMute               - Set Solarwinds Application Template to Mute
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


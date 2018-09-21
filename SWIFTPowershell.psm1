#Requires -Modules SWISPowershell

# Using configuration file for most of the settings
$ConfigFile=“${PSScriptRoot}/config.json” 
$AppConfig=(Get-Content –Path $ConfigFile|ConvertFrom-Json).AppConfig

# Test Mode Configuration
$VerboseLevel          = $AppConfig.VerboseLevel.Value          # 1=Recommended, 2=Informational, 3=Debug - Increase value if troubleshooting                  
$TestMode              = $AppConfig.TestMode.Value              # Changes email group 
$TestModeAdmin         = $AppConfig.TestModeAdmin.Value         # Test emails will go to this person only if test mode is turned on.

# Credential Management 
$UserName              = $env:UserDomain + "\" + $env:UserName  # Certain functions of SWISPowerShell require this format. 
$DefaultCredentialName = $AppConfig.DefaultCredentialName.Value # Enter here the name under which the WMI credentials are stored.
$HostName              = $AppConfig.HostName.Value              # Used for SWISPowershell 
$PWFileDirectory       = $AppConfig.PWFileDirectory.Value       # Password Directory
$DefaultCredentialName = $AppConfig.DefaultCredentialName.Value # Enter here the name under which the WMI credentials are stored.

# Misc
$AllowDuplicates       = $AppConfig.AllowDuplicates.Value       # Allows non-unique hostnames
$TimeZone = (get-timezone).id;                                  # Get time zone from system

# Mail Configuration
$SNMPTo                = $AppConfig.SNMPTo.Value                # Mail To:
$SNMPFrom              = $AppConfig.SNMPFrom.Value              # Mail From:
$SNMPServer            = $AppConfig.SNMPServer.Value            # Mail Server
$DefaultFileType       = $AppConfig.DefaultFileType.Value       # Options: csv,html, and text

$CachePassword=(Get-Content –Path $ConfigFile|ConvertFrom-Json).CachePassword

# initial declaration 
$PasswordCache=$False

foreach ($user in $CachePassword) {
   if ($env:UserName -eq $user) {
      $PasswordCached=$True
   }
}
 
$PWFile=$PWFileDirectory + $env:UserName + "-encrypted.txt"

if ( $VerboseLevel -ge 1) {
    $VerbosePreference     = "Continue"
}
if ($VerboseLevel -ge 2) {
    $InformationPreference ="Continue"
}
if ($VerboseLevel -ge 3) {
    $DebugPreference      = "Continue"
}

# Overrides email SNMPTO
if ($TestMode -eq $True) {
    Write-Information "Test Mode - On" 
    $SNMPTo = $TestModeAdmin 
}
#
#.SYNOPSIS
# Get Script Variables
#
#.EXAMPLE
# Get-SWVar
#
Function Get-SWVar {

"
VerboseLevel:  $VerboseLevel
TestMode: $TestMode
TestModeAdmin: $TestModeAdmin
AllowDuplicates $AllowDuplicates 
HostName: $HostName
UserName: $UserName
PWFile: $PWFile
SNMPTo: $SNMPTo
SNMPFrom: $SNMPFrom
SNMPServer: $SNMPServer 
DefaultFileType: $DefaultFileType  
DefaultCredentialName: $DefaultCredentialName 
UserName: $UserName
PasswordCached: $PasswordCached
"
}

#
#.SYNOPSIS
# Sets Script Password
#
#.EXAMPLE
# Set-SWPassword
#
$credential="null"
function Set-SWPassword {
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
	$credential = Get-Credential
    Write-Information "Setting Password to $pwfile"
 	$credential.Password | ConvertFrom-SecureString | Set-Content $pwfile
     
}

$swis = ""
if ($PasswordCached -and (-Not (Test-Path $pwfile))) {
    Write-Information "Run Set-SWPassword"
	Set-SWPassword
}



if ($PasswordCached) {
    Write-Information "Retreaving Encrypted Password" 
    $encrypted = Get-Content $pwfile | ConvertTo-SecureString
    Write-Information "Logging in as $username"
    $credential = New-Object System.Management.Automation.PsCredential($username, $encrypted)
    Write-Information  ("Attempt to connect to SWIS") 
    $swis = Connect-Swis -host $hostname -Credential $credential
}
else {
    $swis = Connect-Swis -host $hostname
}

#
#.SYNOPSIS
# Get nodes that are in SolarWinds 
#
#.EXAMPLE
# Get-SWNode
#
function Get-SWNode {
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 

    Write-Information ("Running Get-SwisData query") 
    Get-SwisData -SwisConnection $swis -Query 'SELECT NodeID, Caption, DNS, IP,URI, Vendor FROM Orion.Nodes'
}

function Get-SWApp{
    Get-SwisData $swis "SELECT ID, Name,ApplicationTemplateID,NODEID,Uri FROM Orion.APM.Application"
}



#
#.SYNOPSIS
# Gets SolarWinds nodes caption that that exist more then once.
#
#.EXAMPLE
# Set-NodeCustomPropertytoSP -ComputerName Computer.Domain.Com
#
function Get-SWNodeDuplicate {
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
    $a=(Get-SwisData -SwisConnection $swis -Query 'SELECT NodeID, Caption,Vendor FROM Orion.Nodes').Caption
    $b=$a | select –unique
    $duplicates=(Compare-object –referenceobject $b –differenceobject $a).InputObject 
    $tabName = "SWNodeDuplicate"

    #Create Table object
    $table = New-Object system.Data.DataTable “$tabName”

    #Define Columns
    $col1 = New-Object system.Data.DataColumn Title,([string])

    #Add the Columns
    $table.columns.add($col1)

    foreach ($ComputerName in $duplicates) {
            Write-Debug ("Processing: " + $ComputerName)
            #Create a row
            $row = $table.NewRow()
            $row.Title = $ComputerName
            $table.Rows.Add($row)
    }
    $table    
}

#
#.SYNOPSIS
# Gets SolarWinds groups.
#
#.EXAMPLE
# Get-SWGroup
#
function Get-SWGroup {
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
    Get-SwisData -SwisConnection $swis -Query 'SELECT ContainerID,Name,URI FROM Orion.Container' 
} 

#
#.SYNOPSIS
# Addes a puller for a node to SolarWinds
#
#.EXAMPLE
#None
#
function Add-SWPoller{
    Params(
        $PollerType
        ) 
    $poller["PollerType"] = $PollerType
    $pollerUri = New-SwisObject $swis -EntityType "Orion.Pollers" -Properties $poller
}

#
#.SYNOPSIS
# Addes a node to SolarWinds, change custom properties, waits for pulling to complete and Then tests the node for errors.
#
#.EXAMPLE
# Test-SWNode -ComputerName computer.domain.com
#
Function Test-SWNode {
    Param (
        [Parameter(Mandatory=$True)]
        $ComputerName
     )
     Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 

    $NodeId=(Get-SWNode|Where-Object {$_.DNS -eq $ComputerName}).NodeID
    $Problem=Get-SWProblemNode|Where-Object {$_.NodeID -eq $NodeId}|Where-Object {$_.StatusDescription -like "down" -or "unknown"  }

    if($Problem){
        $Body=$Problem
     }
     if (!$NodeID) {
        $Body="No Node Exists"
     }


    if ($Body) {
        #Send-MailMessage -From $SNMPFrom -To $SNMPTo -SmtpServer $SNMPServer -Subject "Test-Node Failed: Manual action needed" -Body "ComputerName: $ComputerName $Body "
        $ComputerName >> D:/log/SWNodeNeedAction.txt
        #There is alert setup on this  file to take action D:/log/SWNodeNeedAction.txt
    }
}      
#
#
#.SYNOPSIS
# Gets current SolarWinds nodes that have a problem.
#
#.EXAMPLE
# Get-SWProblemNode
#
function Get-SWProblemNode {
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
    Get-SwisData $swis 'SELECT NodeID, Caption, StatusDescription, ResponseTime, PercentLoss FROM Orion.Nodes WHERE statusdescription not like @s' @{ s = 'Node status is Up.'}
}

#
# .SYNOPSIS
# Gets the custom properties for a SolarWinds node.
#
#.EXAMPLE
# Get-SWNodeCustomProperties -ComputerName "mytestserver.domain.com" -Environment "Production" -City "New York"
#
function Get-SWNodeCustomProperties {
    Param (
        [Parameter(Mandatory=$true)]
        $ComputerName
    )
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
    #$ShortName=$ComputerName.Split('.')[0]
    $NodeIds=(Get-SWNode|Where-Object {$_.DNS -eq $ComputerName}).NodeID


    foreach ($NodeID in $NodeIDS) { 
        $HashTable=Get-SwisObject $swis -Uri "swis://localhost/Orion/Orion.Nodes/NodeID=$NodeID/CustomProperties"
        #Convert to Powershell Object
        new-object psobject -Property $HashTable
    }
}

#
#.SYNOPSIS
# Sets the custom property for a SolarWinds node.
#
#.EXAMPLE
# Set-SWNodeCustomProperty -ComputerName "Computer.Domain.com" -Property "City"  -Value "New York"
#
function Set-SWNodeCustomProperty {
    Param (
       [Parameter(Mandatory=$True)]
        $ComputerName,
        [Parameter(Mandatory=$True)]
        $Property,
        [Parameter(Mandatory=$True)]
        $Value
    )
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 

    $CustomProperties = @{$Property=$Value}
   
    $NodeIds=(Get-SWNode|Where-Object {$_.DNS -eq $ComputerName}).NodeID
    foreach ($NodeID in $NodeIDS) {
        $NodeUri="swis://localhost/Orion/Orion.Nodes/NodeID=$NodeID"

        # set the custom property
        Set-SwisObject $swis -Uri  ($NodeUri + '/CustomProperties') -Properties $CustomProperties
    }
    if ($Property -eq "App") {
        Add-SWApp -APP $Value
    }
}

#
#.SYNOPSIS
# Get nodes that do not have a fully qualified name for DNS.
#
#.EXAMPLE
# Get-SWNodeDNSNotFQDN 
#
function Get-SWNodeDNSNotFQDN {
    Get-SWNode|Where {$_.DNS -notlike "*.*"}
}

#
#.SYNOPSIS
# Sets the custom property for a SolarWinds node.
#
#.EXAMPLE
# Send-MailPSObject -PSObject (Get-Process) -FileType csv -Subject "Powershell Object in a Email" -Body "See attachment"
#
function Send-MailPSObject {
    Param (
        [Parameter(Mandatory=$True)]
        [PSObject]$PSObject,
        [PSObject]$FileType=$DefaultFileType,
        [Parameter(Mandatory=$True)]
        [String]$Subject,
        [String]$Body="See Attachment"

    )
   Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
        if ($FileType-eq "html") {
            $TempFile=[System.IO.Path]::GetTempFileName()
            $newExtension="htm"
            $TempFile=[io.path]::ChangeExtension($TempFile,$newExtension)
            $PSobject|ConvertTo-HTML > $TempFile
        }
        if ($FileType-eq "text") {
            $TempFile=[System.IO.Path]::GetTempFileName()
            $newExtension="txt"
            $TempFile=[io.path]::ChangeExtension($TempFile,$newExtension)
            $PSobject|ConvertTo-CSV -delimiter "`t" > $TempFile
        }
        ElseIf ($FileType -eq "csv") {
            $TempFile=[System.IO.Path]::GetTempFileName()
            $newExtension="csv"
            $TempFile=[io.path]::ChangeExtension($TempFile,$newExtension)
            $PSobject|ConvertTo-CSV -delimiter "`t" > $TempFile
        }
        else {
            Throw "No Valid FileType"
        }
        
        #"Temp File: " +  $TempFile
        Send-MailMessage -From $SNMPFrom -To $SNMPTo -SmtpServer $SNMPServer -Subject $Subject -Body $Body -Attachments $TempFile
        Remove-Item $TempFile
}

#
#.SYNOPSIS
# Sets the DNS name.
#
#.EXAMPLE
# Set-SWDNS -ComputerName Computer.Domain.Com
#
function Set-SWDNS {
    Param (
        [Parameter(Mandatory=$True)]
        $ComputerName
    )
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
        $ShortName=$ComputerName.Split('.')[0]
        $newNodeProps = @{
            DynamicIP=$True 
            DNS=$ComputerName
        }

    $NodeIds=(Get-SWNode|Where-Object {$_.Caption -eq $ShortName}).NodeID
        foreach ($NodeID in $NodeIDS) {
            $NodeUri="swis://localhost/Orion/Orion.Nodes/NodeID=$NodeID"
            # set the custom property
            Set-SwisObject $swis -Uri ($NodeUri) -Properties $newNodeProps
        }
}

function Update-SWDNS {
    Param (
        [Parameter(Mandatory=$True)]
        $ComputerName,
        [Parameter(Mandatory=$True)]
        $DNS
    )
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
    $ShortName=$ComputerName.Split('.')[0]

    $newNodeProps = @{
        DynamicIP=$True 
        DNS=$DNS
     }

    $NodeIds=(Get-SWNode|Where-Object {$_.DNS -eq $ComputerName}).NodeID
    "NodeIds: " + $NodeIds
     foreach ($NodeID in $NodeIDS) {
        $NodeUri="swis://localhost/Orion/Orion.Nodes/NodeID=$NodeID"
        # set the custom property
        Set-SwisObject $swis -Uri ($NodeUri) -Properties $newNodeProps
     }
}

function Set-SWDNSList {
    Param(
        [Parameter(Mandatory=$True)]
        $File
    )
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
    $ServerList=(Get-Content $File)
    foreach ($Server in $ServerList) {
       Write-Debug ("Processing: " + $server)
       Set-SWDNS -ComputerName $Server   
    }
}

#
#.SYNOPSIS
# Set Group Mute status #
#.EXAMPLE
# Set-SWGroupMute -Group MyTestGroup
#.EXAMPLE
# Set-SWGroupMute -Group MyTestGroup -Unmute
#
function Set-SWGroupMute {
    Param(
        [Parameter(Mandatory=$True)]
        $Group,
        [switch]$Unmute
    )
    #source: https://thwack.solarwinds.com/thread/115868
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 

    Write-Information   ("Group: " + $Group)
    Write-Information  ("Unmute: " + $Unmute)
 
    $URI = (GET-SWGroup|where-object {$_.Name  -eq $Group}).URI
    Write-Information  ("URI: " + $URI)

    # This is the line that Mutes the group for Alerts

    $NULL=Invoke-SwisVerb $swis -verb "SuppressAlerts" -EntityName Orion.AlertSuppression @(,@([string]$URI))

    if ($Unmute -eq $True) {
        $NULL=Invoke-SwisVerb $swis -verb "ResumeAlerts" -EntityName Orion.AlertSuppression @(,@([string]$URI))
    }

}


#
#.SYNOPSIS
# Get Group Mute status #
#.EXAMPLE
# Get-SWGroupMute -Group MyTestGroup
#
function Get-SWGroupMute {
    Param(
        [Parameter(Mandatory=$True)]
        $Group
    )
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
   
    Write-Information  ("Group: " + $Group)
    
    
    $URI = (GET-SWGroup|where-object {$_.Name  -eq $Group}).URI


    # Checking if the group is muted or not.

    $MutedOrNot = Invoke-SwisVerb $swis -verb "getAlertSuppressionState" -EntityName Orion.AlertSuppression @(,@([string]$URI))

    $MutedOrNot = $MutedOrNot.InnerText.Replace($URI,"")

    if($MutedOrNot -match "\."){$MutedOrNot = ($MutedOrNot -replace '(\d)').Split(".")[1]}

    $MutedOrNot

}
#
#.SYNOPSIS
# Job Scheduler For SolarWinds GroupMute
#
#.EXAMPLE
# Set-SWGroupMuteSchedule  -MuteDate (Get-Date).AddMinutes(2) -UnmuteDate (Get-Date).AddMinutes(3) -Group TestMute -RequestNumber 111 
#
# Set-SWGroupMuteSchedule -TaskCleanup
#
function Set-SWGroupMuteSchedule {
	Param (
		$MuteDate,
		$UnmuteDate,
		$Group="test",
		$RequestNumber,
        [switch]$TaskCleanup
	)
    Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 



$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $Encrypted
$Password = $Credentials.GetNetworkCredential().Password 

    if ($TaskCleanup) {
	    #
	    # Cleanup Job
	    #
	    $Requests=Get-ScheduledTask|Where-Object {$_.TaskName -like "Request*"}

         foreach ($Request in $Requests) {
           [datetime]$StartTime =  $Request.Triggers.StartBoundary
           [datetime]$Now=(Get-Date)
           if ($StartTime -lt $Now) {
               $Request.TaskName + "-expired"
               $Request|Unregister-ScheduledTask -Confirm:$false
           }
         }
        return
    }

    
    #Create SID
    $TempFile="C:\temp\swmute.txt"
    if ((Test-Path $TempFile) -eq $false) { 
        "1"> $TempFile
    }
    $sid=[int](cat $TempFile) + 1
    $sid > $TempFile
    $JobName="Request-" + $RequestNumber  + "-" + $sid + "-Mute"
    
    
    $Command="Set-SWGroupMute " +  $Group
    $Argument="-NoProfile -WindowStyle Hidden -command " + '"' + $Command + '"'

    
	#
	# Mute
	
	$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $Argument
    $principal = New-ScheduledTaskPrincipal -UserId $UserName

	$Trigger =  New-ScheduledTaskTrigger -Once -At $muteDate
	Register-ScheduledTask -TaskName $JobName -Action $Action -Trigger $Trigger -User $env:UserName -Password $password   -Description "Mute Event"  

	#
	# Unmute
	#
        $JobName2="Request-" + $RequestNumber  + "-" + $sid + "-UnMute"
    
    
        $Command2="Set-SWGroupMute -Unmute -Group " +  $Group
        $Argument2="-NoProfile -WindowStyle Hidden -command " + '"' + $Command2 + '"'

	
	$Action2 = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $Argument2
        $principal2 = New-ScheduledTaskPrincipal -UserId $env:UserName

	$Trigger2 =  New-ScheduledTaskTrigger -Once -At $unmuteDate
	Register-ScheduledTask -TaskName $JobName2 -Action $Action2 -Trigger $Trigger2 -User $env:UserName -Password $password   -Description "Mute Event"  

}




#
#.SYNOPSIS
# GetNode Mute Schedule
#
#.EXAMPLE
# Get-SWNodeMuteSchedule -ComputerName computer.example.com
 Function Get-SWNodeMuteSchedule {
    Param (
            [Parameter(Mandatory=$True)]
            $ComputerName
     )
     Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
    $Nodes = Get-SwisData -SwisConnection $Swis -Query "SELECT Caption, IP_Address, Uri AS [EntityUri] FROM Orion.Nodes WHERE DNS = @v ORDER BY Caption" -Parameters @{ v = $ComputerName}  

    ForEach ( $Node in $Nodes ) {
        $Muted = Get-SwisData -SwisConnection $Swis -Query "SELECT EntityUri, SuppressFrom, SuppressUntil FROM Orion.AlertSuppression WHERE EntityUri = @v" -Parameters @{ v = $Node.EntityUri}  

        if ( $Muted ) {
            Write-Host "$( $Node.DNS ) ($( $Node.IP_Address )) muted" -ForegroundColor Yellow
        }
        else {
            Write-Host "$( $Node.DNS ) ($( $Node.IP_Address ))  unmuted" -ForegroundColor Yellow
        }
         $myzone = [System.TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)    
         $StartTime=[System.TimeZoneInfo]::ConvertTimeFromUtc($Muted.SuppressFrom, $myZone )
         $EndTime=[System.TimeZoneInfo]::ConvertTimeFromUtc($Muted.SuppressUntil, $myZone )
         "Schedule: " + $StartTime + "-" + $EndTime
    
    }


#
#.SYNOPSIS
# Adds SolarWinds Group 
#
#.EXAMPLE
# Add-SWGroup -Group mygroup 
# Add-SWGroup -Group mygroup2 -RootGroup mygroup
#
Function Add-SWGroup {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Group,
        [string]$RootGroup
    )

    if ($RootGroup) {
        Write-Information ("The name of this function is: {0} " -f $MyInvocation.MyCommand) 
        $rootgroupId=(Get-SWgroup|Where-Object {$_.Name -eq $RootGroup}).ContainerID

        #
        # ADDING A GROUP
        #
        # Adding up devices in the group.
        #  

        $groupmembers = @()

            $groupId = (Invoke-SwisVerb $swis "Orion.Container" "CreateContainer" @(
            # Group name 
            "$Group",

            # owner, must be 'Core'
            "Core",

            # refresh frequency
            60,

            # Status rollup mode:
            # 0 = Mixed status shows warning
            # 1 = Show worst status
            # 2 = Show best status
            0,

            # group description
            "Sub Group created by the PowerShell script.",

            # polling enabled/disabled = true/false (in lowercase)
            "true",

            # group members
            ([xml]@(
                "<ArrayOfMemberDefinitionInfo xmlns='http://schemas.solarwinds.com/2008/Orion'>",
                [string]($groupmembers |% {
                "<MemberDefinitionInfo><Name>$($_.Name)</Name><Definition>$($_.Definition)</Definition></MemberDefinitionInfo>"
                }
            ),
            "</ArrayOfMemberDefinitionInfo>"
            )).DocumentElement
        )).InnerText 

     # Add the SubGroup to a group

        $groupUri = Get-SwisData $swis "SELECT Uri FROM Orion.Container WHERE ContainerID=@id" @{ id = $groupId }

        Invoke-SwisVerb $swis "Orion.Container" "AddDefinition" @(
	        # group ID
	        $rootgroupId,

	        # group member to add
	        ([xml]"
		        <MemberDefinitionInfo xmlns='http://schemas.solarwinds.com/2008/Orion'>
		            <Name></Name>
		            <Definition>$groupUri</Definition>
	            </MemberDefinitionInfo>"
 	        ).DocumentElement
        ) | Out-Null
     }
     else {
     $members = @()
        $groupId = (Invoke-SwisVerb $swis "Orion.Container" "CreateContainer" @(    
        # group name    
        "$Group",    
        # owner, must be 'Core'    
        "Core",    
        # refresh frequency    
        60,    
        # Status rollup mode:    
        # 0 = Mixed status shows warning    
        # 1 = Show worst status    
        # 2 = Show best status    
        0,    
        # group description    
        "Group created by the PowerShell sample script.",    
        # polling enabled/disabled = true/false (in lowercase)    
        "true",    
        # group members    
        ([xml]@(    
            "<ArrayOfMemberDefinitionInfo xmlns='http://schemas.solarwinds.com/2008/Orion'>",    
            [string]($members |% {    
            "<MemberDefinitionInfo><Name>$($_.Name)</Name><Definition>$($_.Definition)</Definition></MemberDefinitionInfo>"    
            }    
        ),    
        "</ArrayOfMemberDefinitionInfo>"    
            )).DocumentElement    
        )).InnerText    
     } 
}

}

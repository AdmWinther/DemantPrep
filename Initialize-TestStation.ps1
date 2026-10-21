#Requires -RunAsAdministrator
param (
    [Parameter(HelpMessage="The name of the computer")]
    [ValidateLength(1, 15)]
    [ValidatePattern('^[a-zA-Z0-9-]+$')]
    [string] $desiredComputerName = 'NightLabSt01',
    
    # Password]
    [Parameter(Mandatory)]
    [SecureString]$Password
)
[CmdletBinding()]
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

. $PSScriptRoot\Set-StationFolders.ps1
. $PSScriptRoot\Enable-ICMPv4Ping.ps1
. $PSScriptRoot\Install-SSH.ps1
. $PSScriptRoot\New-NightLabUser.ps1
. $PSScriptRoot\New-Subsystem.ps1
. $PSScriptRoot\Set-Hostname.ps1
. $PSScriptRoot\Set-ServiceRunning.ps1

[PSCustomObject[]]$results = $null

$results +=Set-Hostname -desiredComputerName $desiredComputerName
$results += Set-StationFolders
$results += New-NightLabUser -Password $Password
$results += Install-SSH
$results += Set-ServiceRunning -ServiceName "sshd"
$results += New-Subsystem
$results += Enable-ICMPv4Ping

$results | Format-Table Step, Changed, RestartNeeded, Message

foreach($entry in $results){
    if($entry.RestartNeeded) {Write-Warning "The changes made in $($entry.Step) are pending on restart."}
}
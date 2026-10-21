#Requires -RunAsAdministrator
function Set-StationFolders2
{

    [CmdletBinding()]

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version Latest

    [string]$root = "C:\NightLab\"
    [string[]]$folders = 'log', 'packages', 'data'

    $Changed = $false
    $Message = ""
    foreach($subfolder in $folders)
    {
        $path = $root + $subfolder
        Write-Verbose "Path to make: $path"
        if(!(Test-Path $path))
        {
            Write-Verbose "Folder $path does not exist, trying to make it"
            try
            {
                write-Host "Trying to make folder $path"
                mkdir $path -ErrorAction Stop
                $Changed = $true
                $Message = "$($Message)New $($path) folder is made. "
            }
            catch
            {
                Write-Verbose "Making folder $path failed, $."
            }
        }
        else
        {
            Write-Verbose "Folder $path already exists"
        }
    }
    if($Message.Length -eq 0){
        $Message = "No new folder."
    }
    return [PSCustomObject]@{
        RestartNeeded = $true
        Step = 'SetStationFolders alaki'
        Changed = $Changed
        Message = $Message
    }
}
#Requires -RunAsAdministrator
function Set-StationFolders
{

    [CmdletBinding()]

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version Latest

    [string]$root = "C:\NightLab\"
    [string[]]$folders = 'log', 'packages', 'data'

    foreach($subfolder in $folders)
    {
        $path = $root + $subfolder
        write-Host "Path to make: $path"
        if(!(Test-Path $path))
        {
            write-Host "Folder $path does not exist, trying to make it"
            try
            {
                write-Host "Trying to make folder $path"
                mkdir $path -ErrorAction Stop
            }
            catch
            {
                write-Host "Making folder $path failed, $."
            }
        }
        else
        {
            write-Host "Folder $path already exists"
        }
    }
}
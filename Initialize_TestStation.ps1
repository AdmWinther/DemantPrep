#Requires -RunAsAdministrator
function Initialize_TestStation {

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version Latest

    [CmdletBinding()]
    param(
        [Parameter()]
        [PSDefaultValue(Help='TestStation01')]
        [string]$ComputerName = "TestStation01"

        [Parameter(Mandatory)]
        [SecureString]$ServicePassword
    )

    [string[]]$root = "C:\NightLab\"
    [string[]]$folders = ['log', 'packages', 'data']
}
    foreach($subfolder in $folders)
    {
        $path = $root + $subfolder
        write-verbose "Path to make: $path"
        if(Test-Path path)
        {
            try
            {
                write-verbose "Trying to make folder $path"
                mkdir $path ErrorActionPreference stop
            }
            catch
            {
                write-verbose "Making folder $path failded, $.
            }
        }
    }

#Requires -RunAsAdministrator
set-StrictMode -Version 3.0
function Start-AService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName
    )

    $changed = $false
    try {
        $theService = Get-Service -Name $ServiceName -ErrorAction stop
    } catch {
        throw "Service '$ServiceName' not found. Please ensure that the $ServiceName  is installed."
    }

    Write-Verbose "$ServiceName service found: $($theService.Name)"

    try {
        
        if ('Running' -ne $theService.Status) {
            # Start the service
            Write-Verbose "Starting the $ServiceName service..."
            Start-Service -Name $ServiceName -ErrorAction Stop

            $status = (Get-Service -Name $ServiceName).Status
            if ('Running' -ne $status) {
                throw "Failed to start the $ServiceName service. Current status: $status"
            }

            Write-Verbose "$ServiceName service started successfully."
            $changed = $true
        } else {
            Write-Verbose "$ServiceName service is already running."
        }
    } 
    catch 
    {
        throw "An error occurred while trying to start the $ServiceName service: $($_.Exception.Message)"
    }

    try {
        # Control if the service is set to start automatically
        $startupType = (Get-Service -Name $ServiceName).StartType
        if ('Automatic' -ne $startupType) {
            Write-Verbose "Setting the $ServiceName service startup type to Automatic..."
            Set-Service -Name $ServiceName -StartupType Automatic -ErrorAction Stop
            Write-Verbose "$ServiceName service startup type set to Automatic."
            $changed = $true
        } else {
            Write-Verbose "$ServiceName service is already set to start automatically."
        }
    } 
    catch 
    {
        throw "An error occurred while trying to set the $ServiceName service startup type to Automatic: $($_.Exception.Message)"
    }
    return [PSCustomObject]@{
        Changed = $changed
        Message = "$ServiceName service is running and set to start automatically."
    }
}

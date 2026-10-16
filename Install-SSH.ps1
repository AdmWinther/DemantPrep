#Requires -RunAsAdministrator
function Install-SSH {
    [CmdletBinding()]
    param ()
    Set-StrictMode -Version 3.0
    
    Write-Verbose "Checking if OpenSSH Server is installed"
        
    $sshCapability = Get-WindowsCapability -Online -Name '*SSH.Server*'
    
    if(@($sshCapability).Count -eq 0) {
        throw "OpenSSH Server capability not found. Please ensure that your system supports OpenSSH."
    }

    if(@($sshCapability).Count -gt 1) {
        throw "Multiple OpenSSH Server capabilities found. Please ensure that your system supports only one OpenSSH capability."
    }

    Write-Verbose "OpenSSH Server installation status: $($sshCapability.State)"

    if ('NotPresent' -eq $sshCapability.State) {

        write-Verbose "OpenSSH Server is not installed. Proceeding with installation."

        # Note the ReplyOfInstallation is just an object that contains the RestartNeeded property,
        # which indicates whether a restart is required after the installation.
        # To know the actual installation status, we need to execute Get-WindowsCapability again after the installation.
        $ReplyOfInstallation = Add-WindowsCapability -Online -Name $sshCapability.Name -ErrorAction Stop
        write-Verbose $ReplyOfInstallation
        
        # Check the installation status after attempting to install OpenSSH Server
        $CheckInstallation = Get-WindowsCapability -Online -Name $sshCapability.Name
        if ('Installed' -eq $CheckInstallation.State) 
        {
            Write-Verbose "OpenSSH Server installation completed successfully"
            return [PSCustomObject]@{
                Step = 'Install-SSH'
                RestartNeeded = $ReplyOfInstallation.RestartNeeded
                Changed = $true
                Message = "OpenSSH Server installed successfully"
            }
        } 
        else
        {
            # If the installation did not succeed, throw an error with the current state
            # For example, there could be a case where the installation failed due to internet connectivity interruption
            throw "OpenSSH Server installation failed: $($CheckInstallation.State)"
        }
        
    }
    elseif ('Installed' -eq $sshCapability.State) {
        Write-Verbose "OpenSSH Server is already installed. No action needed."
        return [PSCustomObject]@{
            Step = 'Install-SSH'
            RestartNeeded = $false
            Changed = $false
            Message = "OpenSSH Server is already installed."
        }
        
    }
    else 
    {
        # If the OpenSSH Server is in an unexpected state like PENDING, throw an error with the current state
        Write-Verbose "OpenSSH Server is in $($sshCapability.State) state."
        throw "OpenSSH Server is in an unexpected state: $($sshCapability.State). Please check the system configuration."
    }
}
#Requires -RunAsAdministrator
Set-StrictMode -Version 3.0
function New-Subsystem {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "The Name of the Subsystem")]
        [string]$SubsystemName = "NightLab-Subsystem",

        [Parameter(HelpMessage = "The Subsystem Command")]
        [string]$textToAdd = 'Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -nologo',

        [Parameter(HelpMessage = "The address of the config file")]
        [string]$ConfigFilePath = "C:\ProgramData\ssh\sshd_config",

        [Parameter(HelpMessage = "The line where new subsystem syntax must be added.")]
        [string]$lineToSearchFor = "Match Group administrators"
    )


    $lineCounter = 0
    $SubsystemLineIndex = 0

    
    try {
        $file = Get-Item $ConfigFilePath -ErrorAction stop
    } catch {
        throw "Error occurred while trying to access the sshd_config file: $($_.Exception.Message)"
    }
    

    # parse the file to array of lines.
    try
    {
        $lines = Get-Content $file -ErrorAction stop
    } catch {
        throw "Error occurred while trying to read the sshd_config file: $($_.Exception.Message)"
    }

    # Check if the subsystem already exists
    # Get the lines of the registry key for the subsystem
    foreach($line in $lines) {
        if ($line -match '^\s*Subsystem\s+powershell\s') {
            return [PSCustomObject]@{
                Step = "NewSubsystem"
                RestartNeeded = $false
                Changed = $false
                Message = "Subsystem is already added to the config file, no need to update the config file or reset the SSH service."
            }
        }
    }


    # Make a backup copy of the sshd_config file before making changes
    $BackupTimeStamp = Get-Date -Format FileDateTime
    $backupFilePath = "$($ConfigFilePath)_$($BackupTimeStamp)"
    Write-Verbose $backupFilePath
    $Changed = $false
    try {
        Copy-Item -Path $file.FullName -Destination $backupFilePath -Force -ErrorAction stop
        Write-Verbose "Backup of sshd_config created at: $backupFilePath"
    } catch {
        throw "Error occurred while trying to create a backup of the sshd_config file: $($_.Exception.Message)"
    }
    
    # Find the place of the file that should be modified
    foreach ($line in $lines){
        $lineCounter++
        if ($line -match $lineToSearchFor) {
            write-Verbose "lineindex: $lineCounter"
            $SubsystemLineIndex = $lineCounter - 1
            # Exit the loop once the line is found
            break
        }
    }

    # If the config file does not have a line that match $lineToSearchFor, $SubsystemLineIndex will be Zero.
    # In this case, the subsystem must be added at the end of the file.
    if(0 -eq $SubsystemLineIndex){
        $SubsystemLineIndex = $(@($lines).count)
    }

    Write-Verbose "Total lines in sshd_config: $(@($lines).count)"
    write-Verbose "Line index for subsystem insertion: $SubsystemLineIndex"

    
    
    # Update the file, add new line
    Write-Verbose "Subsystem line for PowerShell does not exist in sshd_config. Creating line."
    try {
        $Newfile = $Lines[0..($SubsystemLineIndex - 1)]
        $Newfile += $textToAdd
        if($SubsystemLineIndex -lt ($lines).count) {
            $Newfile += $Lines[$SubsystemLineIndex..($Lines.Length - 1)]
        }
        Set-Content -Path $file.FullName -Value $Newfile -ErrorAction stop
        Write-Verbose "Subsystem line for PowerShell added successfully to sshd_config."
        $Changed = $true
    } catch {
        throw "Failde to update the file. Error: $($_.Exception.Message)"
    }

    # Testing the updated config using sshd -t
    # Sshd -t will not throw an exception. It writes an exit code.
    $testOutput = sshd -t -f $ConfigFilePath 2>&1          # 2>&1 captures its error text too
    if ($LASTEXITCODE -ne 0) {
        Write-Verbose "New Config file did not pass the test."
        Write-Verbose "Trying to roll back the change."
        
        # Restarting failed, Roll back.
        try {
            # Restarting failed, try to roll back.
            
            # Keeping the updated file for debugging purpose
            # Make a time stamp for the bad config file.
            $corruptFileTimeStamp = Get-Date -Format FileDateTime
            $corruptFileName = "sshd_config_failed_$($corruptFileTimeStamp)"
            Rename-Item -Path $file.FullName -NewName $corruptFileName -ErrorAction stop
            
            # Restoring the backup, copying from backup. Better to keep backup rather than renaming.
            Copy-Item -Path $backupFilePath -Destination $ConfigFilePath -ErrorAction stop
            Write-Verbose "Restored the original sshd_config from backup due to an error."

            Write-Verbose "No need to restart the server. Config file failed just at **sshd -t** test"
            $Changed = $false            
        } catch {
            # Restarting failed, Even Roll back failed.
            throw "Restarting the service by the updated file is not possible. System tried to rollback the update but error."
        }
        throw "sshd config test failed, original restored. sshd said: $testOutput."
    }

    # Restart the sshd service with the new config file.
    try {
        Write-Verbose "Restarting the sshd service to apply changes..."
        Restart-Service -Name sshd -ErrorAction stop
        Write-Verbose "sshd service restarted successfully."
        $Changed = $true
    } catch {
        throw "Restarting the service with new config file is failed. Config file is updated but backup of the original version exists."
    }

    return [PSCustomObject]@{
        Step = "NewSubsystem"
        RestartNeeded = $false
        Changed = $Changed
        Message = "Subsystem line for PowerShell is added to sshd_config and the service is restarted."
    }
    
}
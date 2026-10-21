#Requires -RunAsAdministrator
function Set-Hostname{
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage="The name of the computer")]
        [ValidateLength(1, 15)]
        [ValidatePattern('^[a-zA-Z0-9-]+$')]
        [string]
        $desiredComputerName = 'NightLabSt01'
    )
    $Changed = $false
    $Message =""
    $RestartNeeded = $false

    $currentComputerName = $env:COMPUTERNAME
    Write-Verbose "Current ComputerName is $($currentComputerName)."

    $futureComputerNameObject = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName
    $futureComputerName = $futureComputerNameObject.ComputerName
    Write-Verbose "ComputerName after restart will be $($futureComputerName)."

    Write-Verbose "Desired computer name is $($desiredComputerName)."
    if($futureComputerName -ne $desiredComputerName) {
        if($currentComputerName -eq $futureComputerName) {
            Rename-Computer -NewName $desiredComputerName -ErrorAction Stop
            Write-Verbose "Computer name change is planned. After re-boot, it will change to $($desiredComputerName)."
            $Changed = $true
            $RestartNeeded = $true
            Write-Verbose "It is now planned to change the computer name to $($desiredComputerName). It is pending re-boot."
            $Message = "It is now planned to change the computer name from $($currentComputerName) to $($desiredComputerName)."
            $Message = "$($Message) Please note the new name will be applied after re-boot."
        } else {
            Write-Warning "Current computer name is $($currentComputerName)."
            Write-Warning "But it was planned to be changed to $($futureComputerName)."
            Write-Warning "It is recommended to restart the computer first to apply the name $($futureComputerName)."
            Write-Warning "After the computer loads, you can apply for the desired computer name."
            throw "Reverting computer name is not possible. Please consider restarting the computer."
        }
    } else {
        if($currentComputerName -eq $desiredComputerName) {
            Write-Verbose "No action is required."
            Write-Verbose "The current and future name are already $($currentComputerName)."
            $Message = "The current and future name are already $($currentComputerName)."
        } else {
            Write-Verbose "It was already planned to change the computer name to $($futureComputerName)."
            Write-Verbose "But it is most likely pending on re-boot."
            Write-Verbose "Please re-boot the machine."
            $Message = "It was already planned to change the computer name to $($futureComputerName)."
            $Message = "$($Message) Please prioritize re-boot the computer to apply the new name."
            $RestartNeeded = $true
        }
    }

    return [PSCustomObject]@{
        Step = 'Set-Hostname'
        Changed = $Changed
        Message = $Message
        RestartNeeded = $RestartNeeded
    }
}
#Requires -RunAsAdministrator
function Set-NigthLabTestStationNam{
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage="The name of the computer")]
        [string]$ComputerName = 'SETH'
    )
    $Changed = $false
    $Message =''
    $NeedsReboot = $false

    $currentComputerName = $env:COMPUTERNAME
    Write-Verbose $currentComputerName
    if($currentComputerName -ne $ComputerName) {
        Write-Verbose "Computer Name is wrong, we need to change it."
        #Rename-Computer -NewName $ComputerName -ErrorAction Stop
        $Changed = $true
        $NeedsReboot = $true
        $Message = "$($Message) Computer Name is updated."
    }



    if(0 -eq $Message.Length){
        $Message = 'No change. No restart is needed.'
    }

    return [PSCustomObject]@{
        Step = 'Set-NigthLabTestStationName'
        Changed = $Changed
        Message = $Message
        NeedsReboot = $NeedsReboot
    }
}
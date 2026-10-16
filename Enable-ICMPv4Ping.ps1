#Requires -RunAsAdministrator
set-StrictMode -Version 3.0
function Enable-ICMPv4Ping {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "The Name of the Rule")]
        [string]$RuleName = "NightLab-Enable-ICMPv4-Ping",
        [Parameter(HelpMessage = "The Display Name of the Rule")]
        [string]$DisplayName = "Allow Ping",
        [Parameter(HelpMessage = "The Description of the Rule")]
        [string]$Description = "Allows ICMP echo requests (ping) through the firewall"
    )

    $existingRule = $null
    $Changed = $false

    # Check if the firewall rule already exists
    $existingRule = Get-NetFirewallRule -Name $RuleName -ErrorAction Stop

    # Determine if the rule exists and create it if it does not
    if(@($existingRule).Count -gt 0) {
        Write-Verbose "Firewall rule with name '$RuleName' already exists. Skipping creation."
    } else {
        Write-Verbose "Firewall rule with name '$RuleName' does not exist. Creating rule."
        try {
            $NewRuleResult = New-NetFirewallRule -Name $RuleName -DisplayName $DisplayName -Description $Description -Protocol ICMPv4 -IcmpType 8 -Action Allow -Direction Inbound -RemoteAddress LocalSubnet -ErrorAction Stop 
            Write-Verbose "Firewall rule with name '$RuleName' created successfully."
            $Changed = $true
        } catch {
            throw "An error occurred while creating firewall rule: $($_.Exception.Message)"
        }
    }

    # Enable the firewall rule if it is not already enabled
    try {
        $isEnabled = (Get-NetFirewallRule -Name $RuleName).Enabled
        if ($isEnabled -eq 'False') {
            Write-Verbose "Firewall rule with Name '$RuleName' is currently disabled. Enabling rule."
            Write-Verbose "Enabling firewall rule with name '$RuleName'."
            Set-NetFirewallRule -Name $RuleName -Enabled True -ErrorAction Stop
            Write-Verbose "Firewall rule with name '$RuleName' enabled successfully."
            $Changed = $true
        } else {
            Write-Verbose "Firewall rule with name '$RuleName' is already enabled."
        }
    } catch {
        throw "An error occurred while checking if firewall rule is enabled: $($_.Exception.Message)"
    }
    return [PSCustomObject]@{
        Step = 'Enable-ICMPv4Ping'
        Changed = $Changed
        Message = "Firewall rule '$RuleName' is present and enabled."
    }
}
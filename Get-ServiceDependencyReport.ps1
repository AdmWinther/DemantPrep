 function Get-ServiceDependencyReport
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string[]]$Name
        )
        ForEach($service in $Name){
            try
            {
                Write-Verbose "Checking $service ..."
                $thisService = Get-Service $service  -ErrorAction Stop
                $thisService | Select-Object Name, Status, @{n="RequiredServicesCount";e={$_.RequiredServices.count}}, @{n="RequiredServices";e={$_.RequiredServices.Name -join ' , '}}, @{n="DependentServicesCount";e={$_.DependentServices.count}}, @{n="DependentServices";e={$_.DependentServices.Name -join ' , '}}
            }
            catch
            {
                Write-Warning "Failed for $service. $($_.Exception.Message)"
            }
        }
	}
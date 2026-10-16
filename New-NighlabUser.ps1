function New-NightLabUser {
    [CmdletBinding()]
    param (
        # UserName
        [Parameter(HelpMessage = "default NigtLabUser01")]
        [string]$UserName = "svc-nightlab",

        # Password]
        [Parameter(Mandatory)]
        [SecureString]$Password
    )
    $Changed = $false

    write-Verbose "Controlling if the NightLab user $UserName exists"
    $UserExists = $false

    $UserExists = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    If ($null -ne $UserExists) {
        $UserExists = $true
        write-Verbose "User $UserName already exists. Skipping creation."
        return [PSCustomObject]@{
            Step = 'New-NightLabUser'
            Changed = $false
            Message = 'User account exists, no new account.'
        }
    }
    else {
        write-Verbose "User $UserName does not exist. Creating user."
        New-LocalUser -Name $UserName -Password $Password
        write-Verbose "User $UserName created successfully."
        Enable-LocalUser -Name $UserName
        Write-Verbose "User $UserName enabled successfully."
        return [PSCustomObject]@{
            Step = 'New-NightLabUser'
            Changed = $true
            Message = 'New user accound is made.'
        }
    }
    
}
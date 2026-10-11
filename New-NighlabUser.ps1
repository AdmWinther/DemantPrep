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

    write-Verbose "Controlling if the NightLab user $UserName exists"
    $UserExists = $false

    $UserExists = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    If ($null -ne $UserExists) {
        $UserExists = $true
        write-Verbose "User $UserName already exists. Skipping creation."
        return
    }
    else {
        write-Verbose "User $UserName does not exist. Creating user."
        New-LocalUser -Name $UserName -Password $Password
        write-Verbose "Adding $UserName to Administrators group"
    }
    
}
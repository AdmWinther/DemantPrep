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

    New-LocalUser -Name $UserName -Password $Password
    
}
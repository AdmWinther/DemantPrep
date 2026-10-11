function New-NightLabUser {
    [CmdletBinding()]
    param (
        # UserName
        [Parameter(HelpMessage = "This is the username, default NigtLabUser01")]
        [string]$UserName = "NightLabUser01",

        # Password]
        [Parameter(HelpMessage = "This is the password", Mandatory)]
        [SecureString]$Password
    )

    New-LocalUser -Name $UserName -Password $Password -FullName "NightLab User" -Description "This is the NightLab user account" -ErrorAction Stop
    
}
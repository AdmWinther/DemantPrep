function New-NightLabUser {
    [CmdletBinding()]
    param (
        # UserName
        [Parameter(HelpMessage = "default username: svc-nightlab")]
        [string]$UserName = "svc-nightlab",

        # Password]
        [Parameter()]
        [SecureString]$Password
    )

    
    $Changed = $false
    $Message = 'User account exists, no new account.'

    write-Verbose "Controlling if a user with username $UserName exists"

    $User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    If ($null -ne $User) {
        write-Verbose "User $UserName already exists. Skipping creation."
        if(!$User[0].Enabled) {
            write-Verbose "The user is disabled. To avoid security risk, delete the existing disabled user first."
            throw "User exists but it is disabled. To avoid security risk, delete the existing disabled user first."
        }
        $expireDate= $User.PasswordExpires
        if($null -eq $expireDate) { 
            Write-Verbose "The user account is already PasswordNeverExpires."
        } else {
            try {
                Set-LocalUser -Name $UserName -PasswordNeverExpires $true -ErrorAction Stop
                $Changed = $true
                $Message = "User existed but its password expire date was limited, it is changed to never expire."
            }
            catch {
                throw "Failed while tried to set passwordNeverExpire to the user account. $($_.Exception.Message)"
            }
        }
        return [PSCustomObject]@{
            RestartNeeded = $false
            Step = 'New-NightLabUser'
            Changed = $Changed
            Message = $Message
        }
    }
    else {
        write-Verbose "User $UserName does not exist. Creating user."
        try {
            $result = New-LocalUser -Name $UserName -Password $Password -PasswordNeverExpires -ErrorAction Stop

            write-Verbose "User $UserName created successfully."
            if(!$result[0].Enabled) {
                Enable-LocalUser -Name $UserName -ErrorAction Stop
                Write-Verbose "User $UserName enabled successfully."
            } else {
                Write-Verbose "The user is active."
            }
            return [PSCustomObject]@{
                RestartNeeded = $false
                Step = 'New-NightLabUser'
                Changed = $true
                Message = 'New user account is made.'
            }
        } catch {
            throw "Making the new user is failed. $($_.Exception.Message)"
        }
    }
    
}
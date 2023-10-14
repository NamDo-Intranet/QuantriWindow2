# Add the Active Directory module if it's not already loaded
Import-Module ActiveDirectory

# Set the user's SamAccountName (UserPrincipalName in case of UPN)
$UserSamAccountName = "TuanAnh"

# Define the default password
$DefaultPassword = "abc123@"

# Create a function to reset the password and log the result
function Reset-ADUserPassword {
    param (
        [string]$UserSamAccountName,
        [string]$DefaultPassword
    )

    Try {
        # Reset the user's password to the default password
        Set-ADAccountPassword -Identity $UserSamAccountName -NewPassword (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force)

        # Enable the account if it's disabled
        $User = Get-ADUser -Identity $UserSamAccountName -Properties Enabled
        if ($User.Enabled -eq $false) {
            Enable-ADAccount -Identity $UserSamAccountName
        }

        # Log the result to a log file
        $LogEntry = @"
****************
Password Reset for $UserSamAccountName ($(Get-Date -Format U))
Password reset by: $($env:USERNAME)
Account enabled: $($User.Enabled)
Password: $DefaultPassword
"@
        Add-Content -Path "C:\Path\To\Log\Newpass.txt" -Value $LogEntry

        # Return the result
        return "Password for $UserSamAccountName has been reset."
    }
    Catch {
        # Log the error to a log file
        $LogEntry = @"
****************
Failed to reset the password for $UserSamAccountName ($(Get-Date -Format U))
Error: $($_.Exception.Message)
"@
        Add-Content -Path "C:\Path\To\Log\File.txt" -Value $LogEntry

        # Return the error message
        return "Failed to reset the password for $UserSamAccountName. Error: $($_.Exception.Message)"
    }
}

# Gui ham da thuc hien dat lai mat khau
Reset-ADUserPassword -UserSamAccountName $UserSamAccountName -DefaultPassword $DefaultPassword
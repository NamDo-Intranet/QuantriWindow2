# Import the Active Directory module
Import-Module ActiveDirectory

# Load the CSV file with the user and email addresses
$UsersCSV = Import-Csv "C:\Temp\Users.csv"

# Create an Outlook COM Object
$Outlook = New-Object -ComObject Outlook.Application

# Define the function to reset the password and log the result
function Reset-ADUserPasswordWithRandomPassword {
    param (
        [string]$UserSamAccountName,
        [string]$EmailAddress
    )

    # Generate a random 4-character suffix
    $RandomSuffix = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 4 | ForEach-Object { [char]$_ })

    # Generate a password with the email address and the random suffix
    $RandomPassword = $EmailAddress.Split("@")[0] + $RandomSuffix

    # Reset the user's password to the random password
    Set-ADAccountPassword -Identity $UserSamAccountName -NewPassword (ConvertTo-SecureString $RandomPassword -AsPlainText -Force)

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
Password: $RandomPassword
"@
    Add-Content -Path "C:\Path\To\Log\Newpass.txt" -Value $LogEntry

    # Send email notification
    $Mail = $Outlook.CreateItem(0)
    $Mail.Recipients.Add($EmailAddress)
    $Mail.Subject = "Password Reset Notification"
    $Mail.Body = "Your password has been reset to: $RandomPassword"
    $Mail.Send()

    # Return the result
    return "Password for $UserSamAccountName has been reset to $RandomPassword."
}

# Reset the password for each user in the CSV file and send email
foreach ($User in $UsersCSV) {
    $UserSamAccountName = $User.User
    $EmailAddress = $User.Email

    Reset-ADUserPasswordWithRandomPassword -UserSamAccountName $UserSamAccountName -EmailAddress $EmailAddress
}
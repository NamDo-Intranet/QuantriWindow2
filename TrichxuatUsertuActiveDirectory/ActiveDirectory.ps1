# Ðinh nghia cac thuoc tính cua nguoi dung ma ban muon trich xuat
$properties = @(
    'DisplayName'
    'GivenName'
    'Surname'
    'Title'
    'Department'
    'Office'
    'OfficePhone'
    'UserPrincipalName'	
)

# Ðinh nghia OU ban muon loai tru
$ouToExclude = 'OU=Disabled Accounts'

# Truy xuat nguoi dung tu Active Directory và loai tru OU da dinh nghia
$users = Get-ADUser -Filter * -Properties $properties |
    Where-Object { $_.DistinguishedName -notlike "*$ouToExclude*" }

# Loc ra cac nguoi dung co du lieu va sau do chon cac thuoc tinh User và xuat ra CSV
$users = $users | Where-Object { $_.DisplayName -ne $null -or $_.GivenName -ne $null -or $_.Surname -ne $null -or $_.Title -ne $null -or $_.Department -ne $null -or $_.Office -ne $null -or $_.OfficePhone -ne $null -or $_.UserPrincipalName -ne $null }
# Loc ra cac nguoi dung co DisplayName khác voi cac gia tri da chi dinh
$users = $users | Where-Object { $_.DisplayName -notin @("Microsoft Exchange Approval Assistant", "Microsoft Exchange", "Discovery Search Mailbox", "Microsoft Exchange Federation Mailbox") }

$users | Select-Object DisplayName, GivenName, Surname, Title, Department, Office, OfficePhone, UserPrincipalName |
    Export-Csv -Path "C:\ad-users.csv" -NoTypeInformation
Import-Module C:\Users\Administrator\Desktop\ADObjectAccessRight.psm1 -Force

# Get a list of distinguishedNames
$distinguishedNames = Get-ADGroup -Filter * | 
    Select-Object -ExpandProperty distinguishedName

# Get a list of distinguishedNames
$distinguishedNames = Get-ADUser -Filter * | 
    Select-Object -ExpandProperty distinguishedName

# Get a list of distinguishedNames
$distinguishedNames = Get-ADOrganizationalUnit -Filter * | 
    Select-Object -ExpandProperty distinguishedName

# Get a list of distinguishedNames
$distinguishedNames =  = @"
dc=contoso,dc=com
cn=builtin,dc=contoso,dc=com
cn=computers,dc=contoso,dc=com
cn=users,dc=contoso,dc=com
ou=domain controllers,dc=contoso,dc=com
"@.trim().split("`n")

# Get an array of Access Contorl Entries for each distinguishedName
$distinguishedNames | 
    Get-ADDirectoryEntry |
    Get-ADObjectAccessRight

# Get an array of Access Contorl Entries and export to .CSV
$distinguishedNames | 
    Get-ADDirectoryEntry |
    Get-ADObjectAccessRight |
    Export-Csv -NoTypeInformation .\ADObjectAccessRight_export_contoso.csv

<# Make a change to the .CSV export. 
 
    Use 'Remove-ADObjectAccessRightHelper' to help create the correct permission entries.

    Remove-ADObjectAccessRightHelper -DesiredPermissions "ReadProperty"
    Remove-ADObjectAccessRightHelper -DesiredPermissions "ReadProperty, ListChildren"

    Set '__AddRemoveIndicator' column in .CSV export to '1' to add the permission entry.
    Set '__AddRemoveIndicator' column in .CSV export to '0' to remove the permission entry.

    Set '__AddRemoveIndicator' column in .CSV export to '-1' to ignore the permission entry.
#>

# Import an array of Access Control Entries from .CSV and apply them
Import-Csv .\ADObjectAccessRight_export_contoso.csv | 
    Set-ADObjectAccessRight

<#
.Synopsis
    Returns the ActiveDirectoryRights that need to be removed to reduce a principals permission from 'GenericaAll' to that provided as input.
.DESCRIPTION
    Remove-ADObjectAccessRightHelper assists with the following transformation:

    To reduce a principals ActiveDirectoryRights from 'GenericAll' to only 'ReadProperty, ListChildren' first use '-bor' to combine 'ReadProperty' and 'ListChildren'. Then use -bxor to find the difference between the result and 'GenericAll'. This will leave the ActiveDirectoryRights which need to be provided to Remove-ADObjectAccessRight to reduce the granted permissions.   

    $GenericAll = [System.DirectoryServices.ActiveDirectoryRights]::GenericAll 
    $ReadProperty = [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty
    $ListChildren = [System.DirectoryServices.ActiveDirectoryRights]::ListChildren

    # UnwantedPermissions
    $GenericAll -bxor ($ReadProperty -bor $ListChildren) 
.EXAMPLE
    Remove-ADObjectAccessRightHelper -DesiredPermissions "ReadProperty" 
.EXAMPLE
   "ReadProperty" | Remove-ADObjectAccessRightHelper
.EXAMPLE
    Remove-ADObjectAccessRightHelper -DesiredPermissions "ReadProperty, ListChildren"
.EXAMPLE
   "ReadProperty, ListChildren" | Remove-ADObjectAccessRightHelper
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Remove-ADObjectAccessRightHelper {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectoryRights]
        $DesiredPermissions
    )

    begin {
    }
    process {
        [System.DirectoryServices.ActiveDirectoryRights]::GenericAll -bxor $DesiredPermissions
    }
    end {
    }
}
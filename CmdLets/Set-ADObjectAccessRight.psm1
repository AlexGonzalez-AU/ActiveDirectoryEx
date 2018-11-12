function Set-ADObjectAccessRight {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [string]
        $ForeignDomainFQDN = "",
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        [System.Management.Automation.PSCredential]
        $ForeignDomainCredential,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=3)]
        [switch]
        $Force = $false
    )

    begin {
    }
    process {
        if ([int]$InputObject.__AddRemoveIndicator -eq 0) {
            $InputObject.Parent_distinguishedName |
            Get-ADDirectoryEntry |
            Remove-ADObjectAccessRight `
                -IdentityReference $InputObject.IdentityReference `
                -ActiveDirectoryRights $InputObject.ActiveDirectoryRights `
                -AccessControlType $InputObject.AccessControlType `
                -ObjectType ($InputObject.ObjectTypeName | ConvertTo-ObjectTypeGuid) `
                -InheritanceType ($InputObject.InheritanceTypeName | ConvertTo-InheritedObjectTypeGuid) `
                -InheritedObjectType $InputObject.InheritedObjectType `
                -ForeignDomainFQDN $ForeignDomainFQDN `
                -ForeignDomainCredential $ForeignDomainCredential `
                -Confirm:(-not $Force)
        }
        elseif ([int]$InputObject.__AddRemoveIndicator -gt 0) {
            $InputObject.Parent_distinguishedName |
            Get-ADDirectoryEntry |
            Add-ADObjectAccessRight `
                -IdentityReference $InputObject.IdentityReference `
                -ActiveDirectoryRights $InputObject.ActiveDirectoryRights `
                -AccessControlType $InputObject.AccessControlType `
                -ObjectType ($InputObject | ConvertTo-ObjectTypeGuid) `
                -InheritanceType ($InputObject | ConvertTo-InheritedObjectTypeGuid) `
                -InheritedObjectType $InputObject.InheritedObjectType `
                -ForeignDomainFQDN $ForeignDomainFQDN `
                -ForeignDomainCredential $ForeignDomainCredential `
                -Confirm:(-not $Force)
        }
    }
    end {
    }
}
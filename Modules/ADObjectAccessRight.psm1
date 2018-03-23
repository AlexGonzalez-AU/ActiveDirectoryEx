function ConvertFrom-DistinguishedName {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InputObject
    )

    begin {
    }
    process {
        $objcetPath = $InputObject.replace($InputObject.Substring($InputObject.IndexOf('DC=')),'').replace('CN=','').replace('OU=','').trim(',').split(',')
        $objcetPath += $InputObject.Substring($InputObject.IndexOf('DC=')).replace('DC=','').replace(',','.')
        [array]::Reverse($objcetPath)
        return ($objcetPath -join '/').trim('/')
    }
    end {
    }
}

function ConvertFrom-ObjectTypeGuid {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectoryAccessRule]
        $InputObject
    )

    begin {
    }
    process {
        if ($InputObject.ActiveDirectoryRights -eq [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight) {
            return $_ADRightsObjectNames[$InputObject.ObjectType].name
        }
        elseif (([string]$InputObject.ObjectType).Replace("-","").trim("0").length -eq 0) {
            return "All"
        }
        else {
            if ($_ADRightsObjectNames[$InputObject.ObjectType].name -eq $null) {
                return $_ADSchemaObjectNames[$InputObject.ObjectType].name
            }
            else {
                return $_ADRightsObjectNames[$InputObject.ObjectType].name
            }
        }
    }
    end {
    }
}

function ConvertFrom-InheritedObjectTypeGuid {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectoryAccessRule]
        $InputObject
    )

    begin {
    }
    process {
        if (([string]$InputObject.InheritedObjectType).Replace("-","").trim("0").length -eq 0) {
            return "All"
        }
        else {
            return $_ADSchemaObjectNames[$InputObject.InheritedObjectType].name
        }
    }
    end {
    }
}

function Get-ADDirectoryEntry {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DistinguishedName
    )

    begin {
    }
    process {
        return [adsi]"LDAP://$DistinguishedName"
    }
    end {
    }
}

function Get-ADObject {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LDAPFilter,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [System.DirectoryServices.DirectoryEntry]
        $SearchRoot=(New-Object System.DirectoryServices.DirectoryEntry),
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        [string[]]
        $Properties = @(
            "name",
            "sAMAccountName",
            "distinguishedName",
            "userAccountControl"
        ),
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=3)]
        [string]
        $SearchScope='subtree',
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=4)]
        [int]
        $PageSize=116        
    )

    begin {
    }
    process {
        $search = New-Object System.DirectoryServices.DirectorySearcher
        $search.SearchRoot = $SearchRoot
        $search.PageSize = $PageSize    
        $search.SearchScope = $SearchScope
        
        $Properties | 
            ForEach-Object {
                $search.PropertiesToLoad.Add($_) | Out-Null
            }

        $search.filter = $LDAPFilter

        $rs = $search.FindAll()
        $rs | 
            ForEach-Object {
                New-Object -TypeName psobject -Property $_.Properties
            }
    }
    end  {
    }
}

function Get-ADRightsObjectGuids {
    [CmdletBinding()]
    
    param (
    )

    begin {
        $Global:_ADRightsObjectGuids = @{}
        $Global:_ADRightsObjectNames = @{}
    }
    process { 
        $searchRoot = Get-ADDirectoryEntry "rootDSE" | 
            Select-Object -ExpandProperty configurationNamingContext |
            Get-ADDirectoryEntry

        Get-ADObject -SearchRoot $searchRoot -LDAPFilter "(&(objectClass=controlAccessRight)(rightsGuid=*))" -Properties name, displayName, rightsGuid | 
            ForEach-Object {
                if ($_ADRightsObjectGuids.ContainsKey($_.name[0])) {
                    Write-Warning ("Duplicate RightsName found: '{0}' wants the index '{1}' which is already used by '{2}'." -f [System.Guid]($_.rightsGuid[0]), $_.name[0], $_ADRightsObjectGuids[$_.name[0]])
                }
                else {
                    $_ADRightsObjectGuids.Add(
                            $_.name[0],
                            [System.Guid]($_.rightsGuid[0])
                        )
                }
                if ($_ADRightsObjectNames.ContainsKey([System.Guid]($_.rightsGuid[0]))) {
                    Write-Warning ("Duplicate RightsGuid found: '{0}' wants the index '{1}' which is already used by '{2}'." -f $_.name[0], [System.Guid]($_.rightsGuid[0]), $_ADRightsObjectNames[[System.Guid]($_.rightsGuid[0])].name)
                }            
                else {
                    $_ADRightsObjectNames.Add(
                        [System.Guid]($_.rightsGuid[0]),
                        @{
                            'name'=$_.name[0]
                            'displayName'=$_.displayName[0]
                        }
                    )
                }
            }
    }
    end {
    }
}

function Get-ADSchemaObjectGuids {
    [CmdletBinding()]
    
    param (
    )

    begin {
        $Global:_ADSchemaObjectGuids = @{}
        $Global:_ADSchemaObjectNames = @{}
    }
    process {
        $searchRoot = Get-ADDirectoryEntry "rootDSE" | 
            Select-Object -ExpandProperty schemaNamingContext |
            Get-ADDirectoryEntry
            
        Get-ADObject -SearchRoot $searchRoot -LDAPFilter "(schemaIdGuid=*)" -Properties name, lDAPDisplayName, schemaIdGuid | 
            ForEach-Object {
                if ($_ADSchemaObjectGuids.ContainsKey($_.name[0])) {
                    Write-Warning ("Duplicate SchemaName found: '{0}' wants the index '{1}' which is already used by '{2}'." -f [System.Guid]($_.schemaIdGuid[0]), $_.name[0], $_ADSchemaObjectGuids[$_.name[0]])
                }
                else {
                    $_ADSchemaObjectGuids.Add(
                            $_.name[0],
                            [System.Guid]($_.schemaIdGuid[0])
                        )
                }
                if ($_ADSchemaObjectNames.ContainsKey([System.Guid]($_.schemaIdGuid[0]))) {
                    Write-Warning ("Duplicate SchemaGuid found: '{0}' wants the index '{1}' which is already used by '{2}'." -f $_.name[0], [System.Guid]($_.schemaIdGuid[0]), $_ADSchemaObjectNames[[System.Guid]($_.schemaIdGuid[0])].name)
                }            
                else {
                    $_ADSchemaObjectNames.Add(
                        [System.Guid]($_.schemaIdGuid[0]),
                        @{
                            'name'=$_.name[0]
                            'lDAPDisplayName'=$_.lDAPDisplayName[0]
                        }
                    )
                }
            }
    }
    end {
    }
}

function Add-ADObjectAccessRight {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.DirectoryEntry]
        $InputObject,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [string]
        $ForeignDomainFQDN = "",
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        [System.Management.Automation.PSCredential]
        $ForeignDomainCredential,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=3)]
        [ValidateNotNullOrEmpty()]
        [System.Security.Principal.NTAccount]
        $IdentityReference,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=4)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectoryRights]
        $ActiveDirectoryRights,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=5)]
        [ValidateNotNullOrEmpty()]
        [System.Security.AccessControl.AccessControlType]
        $AccessControlType,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=6)]
        [ValidateNotNullOrEmpty()]
        [System.Guid]
        $ObjectType,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=7)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]
        $InheritanceType,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=8)]
        [ValidateNotNullOrEmpty()]
        [System.Guid]
        $InheritedObjectType
    )

    begin {
    }
    process {
        if ($ForeignDomainFQDN.Length -gt 0) {
            $bSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ForeignDomainCredential.Password)
            $RemotePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bSTR)
            if ($ForeignDomainCredential.UserName.Contains("\")) {
                $RemoteUsername = "{0}\{1}" -f $ForeignDomainFQDN, $ForeignDomainCredential.UserName.split("\")[1]
            }
            else {
                $RemoteUsername = "{0}\{1}" -f $ForeignDomainFQDN, $ForeignDomainCredential.UserName
            }
            $obj = [adsi]::new(("LDAP://{0}/{1}" -f $ForeignDomainFQDN,[string]$InputObject.distinguishedname),$RemoteUsername,$RemotePassword)
        }
        else {
            $obj = $InputObject
        }        

        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                $IdentityReference, 
                $ActiveDirectoryRights, 
                $AccessControlType, 
                $ObjectType, 
                $InheritanceType,
                $InheritedObjectType
            )

$shouldProcessTarget = $obj.distinguishedname
$shouldProcessOperation = @"

    Add-ADObjectAccessRight
        -IdentityReference       $IdentityReference
        -ActiveDirectoryRights   $ActiveDirectoryRights 
        -AccessControlType       $AccessControlType 
        -ObjectType              $ObjectType ($($ace | ConvertFrom-ObjectTypeGuid))
        -InheritanceType         $InheritanceType 
        -InheritedObjectType     $InheritedObjectType ($($ace | ConvertFrom-InheritedObjectTypeGuid))

"@        

        if ($PSCmdlet.ShouldProcess($shouldProcessTarget, $shouldProcessOperation)) {            
            $obj.ObjectSecurity.AddAccessRule($ace) | Out-Null
            $obj.CommitChanges()           
        }        
    }
    end {
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Use '-bxor' and '-bor' to correctly remove permisions. 
   
   For example, to reduce a principals ActiveDirectoryRights from 'GenericAll' to only 'ReadProperty, ListChildren' first use '-bor' to combine 'ReadProperty' and 'ListChildren'. Then use -bxor to find the difference between the result and 'GenericAll'. This will leave the ActiveDirectoryRights which need to be provided to Remove-ADObjectAccessRight to reduce the granted permissions.   
   
   $GenericAll = [System.DirectoryServices.ActiveDirectoryRights]::GenericAll 
   $ReadProperty = [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty
   $ListChildren = [System.DirectoryServices.ActiveDirectoryRights]::ListChildren
   
   # UnwantedPermissions
   $GenericAll -bxor ($ReadProperty -bor $ListChildren) 
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES

.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Remove-ADObjectAccessRight {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.DirectoryEntry]
        $InputObject,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [string]
        $ForeignDomainFQDN = "",
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        [System.Management.Automation.PSCredential]
        $ForeignDomainCredential,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=3)]
        [ValidateNotNullOrEmpty()]
        [System.Security.Principal.NTAccount]
        $IdentityReference,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=4)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectoryRights]
        $ActiveDirectoryRights,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=5)]
        [ValidateNotNullOrEmpty()]
        [System.Security.AccessControl.AccessControlType]
        $AccessControlType,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=6)]
        [ValidateNotNullOrEmpty()]
        [System.Guid]
        $ObjectType,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=7)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]
        $InheritanceType,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=8)]
        [ValidateNotNullOrEmpty()]
        [System.Guid]
        $InheritedObjectType
    )

    begin {
    }
    process {
        if ($ForeignDomainFQDN.Length -gt 0) {
            $bSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ForeignDomainCredential.Password)
            $RemotePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bSTR)
            if ($ForeignDomainCredential.UserName.Contains("\")) {
                $RemoteUsername = "{0}\{1}" -f $ForeignDomainFQDN, $ForeignDomainCredential.UserName.split("\")[1]
            }
            else {
                $RemoteUsername = "{0}\{1}" -f $ForeignDomainFQDN, $ForeignDomainCredential.UserName
            }
            $obj = [adsi]::new(("LDAP://{0}/{1}" -f $ForeignDomainFQDN,[string]$InputObject.distinguishedname),$RemoteUsername,$RemotePassword)
        }
        else {
            $obj = $InputObject
        }        

        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                $IdentityReference, 
                $ActiveDirectoryRights, 
                $AccessControlType, 
                $ObjectType, 
                $InheritanceType,
                $InheritedObjectType
            )

$shouldProcessTarget = $obj.distinguishedname
$shouldProcessOperation = @"

    Remove-ADObjectAccessRight
        -IdentityReference       $IdentityReference
        -ActiveDirectoryRights   $ActiveDirectoryRights 
        -AccessControlType       $AccessControlType 
        -ObjectType              $ObjectType ($($ace | ConvertFrom-ObjectTypeGuid))
        -InheritanceType         $InheritanceType 
        -InheritedObjectType     $InheritedObjectType ($($ace | ConvertFrom-InheritedObjectTypeGuid))

"@        

        if ($PSCmdlet.ShouldProcess($shouldProcessTarget, $shouldProcessOperation)) {   
            $obj.ObjectSecurity.RemoveAccessRule($ace) | Out-Null         
            $obj.CommitChanges()           
        }        
    }
    end {
    }
}

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

function Get-ADObjectAccessRight {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.DirectoryEntry]
        $InputObject,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [string]
        $ForeignDomainFQDN = "",
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        [System.Management.Automation.PSCredential]
        $ForeignDomainCredential
    )

    begin {
    }
    process { 
        if ($ForeignDomainFQDN.Length -gt 0) {
            $bSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ForeignDomainCredential.Password)
            $RemotePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bSTR)
            if ($ForeignDomainCredential.UserName.Contains("\")) {
                $RemoteUsername = "{0}\{1}" -f $ForeignDomainFQDN, $ForeignDomainCredential.UserName.split("\")[1]
            }
            else {
                $RemoteUsername = "{0}\{1}" -f $ForeignDomainFQDN, $ForeignDomainCredential.UserName
            }
            $obj = [adsi]::new(("LDAP://{0}/{1}" -f $ForeignDomainFQDN,[string]$InputObject.distinguishedname),$RemoteUsername,$RemotePassword)
        }
        else {
            $obj = $InputObject
        }

        return $obj.ObjectSecurity.Access |
            ForEach-Object {
                $_ | Add-Member -MemberType NoteProperty -Name __AddRemoveIndicator -Value (-1)
                $_ | Add-Member -MemberType NoteProperty -Name Parent_canonicalName -Value ($obj | Select-Object -ExpandProperty distinguishedName | ConvertFrom-DistinguishedName)
                $_ | Add-Member -MemberType NoteProperty -Name Parent_distinguishedName -Value ($obj | Select-Object -ExpandProperty distinguishedName)
                $_ | Add-Member -MemberType NoteProperty -Name Parent_objectClass -Value ($obj | Select-Object -ExpandProperty objectClass | Select-Object -Last 1)
                $_ | Add-Member -MemberType NoteProperty -Name ObjectTypeName -Value ($_ | ConvertFrom-ObjectTypeGuid)
                $_ | Add-Member -MemberType NoteProperty -Name InheritedObjectTypeName -Value ($_ | ConvertFrom-InheritedObjectTypeGuid)
                $_
            }
    }
    end {
    }
}

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
                -ObjectType $InputObject.ObjectType `
                -InheritanceType $InputObject.InheritanceType `
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
                -ObjectType $InputObject.ObjectType `
                -InheritanceType $InputObject.InheritanceType `
                -InheritedObjectType $InputObject.InheritedObjectType `
                -ForeignDomainFQDN $ForeignDomainFQDN `
                -ForeignDomainCredential $ForeignDomainCredential `
                -Confirm:(-not $Force)
        }
    }
    end {
    }
}

Get-ADRightsObjectGuids
Get-ADSchemaObjectGuids

Export-ModuleMember `
    -Function @(
        'Get-ADDirectoryEntry',
        'Add-ADObjectAccessRight',
        'Remove-ADObjectAccessRight',
        'Remove-ADObjectAccessRightHelper',
        'Get-ADObjectAccessRight',
        'Set-ADObjectAccessRight'
    ) `
    -Variable @(
        '_ADRightsObjectGuids',
        '_ADRightsObjectNames',
        '_ADSchemaObjectGuids',
        '_ADSchemaObjectNames'   
    )
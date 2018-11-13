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
        if (Get-WmiObject -Query "select * from Win32_ComputerSystem where DomainRole < 4") {
            Write-Error -Message "The running system is not a Domain Controller and 'Remove-ADObjectAccessRight' must execute from a Domain Controller."
            break
        }
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
            
        # Attempt to translate the account (if the account does not exist this will produce an error)
        $IdentityReferenceSid = $null
        $IdentityReferenceSid = $IdentityReference.Translate([System.Security.Principal.SecurityIdentifier])
        if ($IdentityReferenceSid -eq $null) {
            $ace = $null
        }
        else {
            Write-Output ("{0}`t{1}" -f $IdentityReference.Value, $IdentityReferenceSid.Value)
        }

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
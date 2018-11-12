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
        if (Get-WmiObject -Query "select * from Win32_ComputerSystem where DomainRole < 4") {
            Write-Error -Message "The running system is not a Domain Controller and 'Add-ADObjectAccessRight' must execute from a Domain Controller."
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

        $eap = $ErrorActionPreference 
        $ErrorActionPreference = "Stop"
        try {
            $IdentityReference
            $IdentityReference = $accountName.Translate([System.Security.Principal.SecurityIdentifier])
            $IdentityReference
            $IdentityReference.Translate([System.Security.Principal.SecurityIdentifier])
        }
        catch {
            Write-Error -Message "Unable to resolve IdentityReference."
            continue
        }
        $ErrorActionPreference = $eap

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
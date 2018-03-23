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
function Get-ADObjectAccessRight {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ForeignDomainFQDN = "",
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $ForeignDomainCredential
    )

    begin {
    }
    process { 
        if ($ForeignDomainFQDN.Length -eq 0) {
            [adsi]$obj = "LDAP://{0}" -f [string]$InputObject.distinguishedname
        }
        else {
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

        return $obj.ObjectSecurity.Access |
            foreach {
                $_ | Convert-ADAceObjectTypeGuid
                $_
            }
    }
    end {
    }
}
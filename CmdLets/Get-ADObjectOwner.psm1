function Get-ADObjectOwner {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )

    begin {
    }
    process { 
        [adsi]$obj = "LDAP://{0}" -f [string]$InputObject.distinguishedname
        return $obj.ObjectSecurity.Owner
    }
    end {
    }
}
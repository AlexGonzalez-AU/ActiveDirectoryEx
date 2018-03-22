function Get-ADDirectoryEntry {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$DistinguishedName
    )

    begin {
    }
    process {
        return [adsi]"LDAP://$DistinguishedName"
    }
    end {
    }
}
function Get-ADChildUser {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [string]$DistinguishedName
    )    

    begin {
    }
    process {
        $DistinguishedName.Substring($DistinguishedName.ToLower().IndexOf("dc=")) |
            Get-ADDirectoryEntry | 
            Get-ADObject -LDAPFilter "(&(objectCategory=User)(memberOf=$DistinguishedName))"
    }
    end {
    }
}
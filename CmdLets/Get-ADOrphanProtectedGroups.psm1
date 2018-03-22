function Get-ADOrphanProtectedGroups {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=2)]
        [system.directoryservices.directoryentry]$Domain=(Get-ADDomain)
    )

    begin {
    }
    process {
        [string[]]$pGroups = $Domain | 
            Get-ADProtectedGroups -Recurse |
            Select-Object -ExpandProperty distinguishedname

        $Domain | 
            Get-ADObject -LDAPFilter "(&(objectCategory=Group)(adminCount=1))" |
            ForEach-Object {
                if ($_.distinguishedname -notin $pGroups) {
                    $_
                }
            }
    }
    end {
    }
}
function Get-ADOrphanProtectedUsers {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=2)]
        [system.directoryservices.directoryentry]$Domain=(Get-ADDomain)
    )

    begin {
    }
    process {
        [string[]]$pUsers = $Domain | 
            Get-ADProtectedUsers |
            Select-Object -ExpandProperty distinguishedname

        $Domain | 
            Get-ADObject -LDAPFilter "(&(objectCategory=User)(adminCount=1))" |
            ForEach-Object {
                if ($_.distinguishedname -notin $pUsers) {
                    $_
                }
            }
    }
    end {
    }
}
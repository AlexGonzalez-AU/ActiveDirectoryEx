function Get-ADDomain {
    [CmdletBinding()]

    param (
        [switch]$All
    )

    begin { 
    }
    process {
        if ($All) {
            Get-ADForest
            Get-ADForest | 
                Select-Object -ExpandProperty subRefs | 
                Where-Object {
                    $_.StartsWith("DC=") -and 
                    !$_.StartsWith("DC=ForestDnsZones,") -and 
                    !$_.StartsWith("DC=DomainDnsZones,")
                } |
                Get-ADDirectoryEntry
        } 
        else {
            Get-ADDirectoryEntry "rootDSE" | 
                Select-Object -ExpandProperty defaultNamingContext | 
                Get-ADDirectoryEntry
        }
    }
    end {
    }
}
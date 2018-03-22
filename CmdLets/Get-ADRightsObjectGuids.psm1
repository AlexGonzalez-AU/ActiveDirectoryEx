function Get-ADRightObjectGuids {
    [CmdletBinding()]
    
    param (
    )

    begin {
    }
    process { 
        "CN=Extended-Rights,CN=configuration,{0}" -f (Get-ADForest | Select-Object -ExpandProperty distinguishedName) |
            Get-ADDirectoryEntry | 
            Get-ADObject -LDAPFilter "rightsGuid=*" -Properties name, rightsGuid | 
            foreach {
                New-Object -TypeName psobject -Property @{
                    Name = $_.name[0]
                    Guid = $_.rightsGuid[0]
                }
            }
    }
    end {
    }

}
function Get-ADSchemaObjectGuids {
    [CmdletBinding()]
    
    param (
    )

    begin {
    }
    process {
        "CN=schema,CN=configuration,{0}" -f (Get-ADForest | Select-Object -ExpandProperty distinguishedName) |
            Get-ADDirectoryEntry | 
            Get-ADObject -LDAPFilter "schemaIdGuid=*" -Properties name, schemaIdGuid | 
            foreach {
                New-Object -TypeName psobject -Property @{
                    Name = $_.name[0]
                    Guid = [guid]($_.schemaIdGuid[0]) 
                }
            }
    }
    end {
    }

}
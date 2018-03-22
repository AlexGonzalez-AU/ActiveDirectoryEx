function Get-ADSchemaObjectGuids {
    [CmdletBinding()]
    
    param (
    )

    begin {
        $Global:_ADSchemaObjectGuids = @{}
        $Global:_ADSchemaObjectNames = @{}
    }
    process {
        $searchRoot = Get-ADDirectoryEntry "rootDSE" | 
            Select-Object -ExpandProperty schemaNamingContext |
            Get-ADDirectoryEntry
            
        Get-ADObject -SearchRoot $searchRoot -LDAPFilter "(schemaIdGuid=*)" -Properties name, lDAPDisplayName, schemaIdGuid | 
            ForEach-Object {
                if ($Global:_ADSchemaObjectGuids.ContainsKey($_.name[0])) {
                    Write-Warning ("Duplicate SchemaName found: '{0}' wants the index '{1}' which is already used by '{2}'." -f [System.Guid]($_.schemaIdGuid[0]), $_.name[0], $Global:_ADSchemaObjectGuids[$_.name[0]])
                }
                else {
                    $Global:_ADSchemaObjectGuids.Add(
                            $_.name[0],
                            [System.Guid]($_.schemaIdGuid[0])
                        )
                }
                if ($Global:_ADSchemaObjectNames.ContainsKey([System.Guid]($_.schemaIdGuid[0]))) {
                    Write-Warning ("Duplicate SchemaGuid found: '{0}' wants the index '{1}' which is already used by '{2}'." -f $_.name[0], [System.Guid]($_.schemaIdGuid[0]), $Global:_ADSchemaObjectNames[[System.Guid]($_.schemaIdGuid[0])].name)
                }            
                else {
                    $Global:_ADSchemaObjectNames.Add(
                        [System.Guid]($_.schemaIdGuid[0]),
                        @{
                            'name'=$_.name[0]
                            'lDAPDisplayName'=$_.lDAPDisplayName[0]
                        }
                    )
                }
            }
    }
    end {
    }
}
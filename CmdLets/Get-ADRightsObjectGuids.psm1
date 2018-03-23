function Get-ADRightsObjectGuids {
    [CmdletBinding()]
    
    param (
    )

    begin {
        $Global:_ADRightsObjectGuids = @{}
        $Global:_ADRightsObjectNames = @{}
    }
    process { 
        $searchRoot = Get-ADDirectoryEntry "rootDSE" | 
            Select-Object -ExpandProperty configurationNamingContext |
            Get-ADDirectoryEntry

        Get-ADObject -SearchRoot $searchRoot -LDAPFilter "(&(objectClass=controlAccessRight)(rightsGuid=*))" -Properties name, displayName, rightsGuid | 
            ForEach-Object {
                if ($_ADRightsObjectGuids.ContainsKey($_.name[0])) {
                    Write-Warning ("Duplicate RightsName found: '{0}' wants the index '{1}' which is already used by '{2}'." -f [System.Guid]($_.rightsGuid[0]), $_.name[0], $_ADRightsObjectGuids[$_.name[0]])
                }
                else {
                    $_ADRightsObjectGuids.Add(
                            $_.name[0],
                            [System.Guid]($_.rightsGuid[0])
                        )
                }
                if ($_ADRightsObjectNames.ContainsKey([System.Guid]($_.rightsGuid[0]))) {
                    Write-Warning ("Duplicate RightsGuid found: '{0}' wants the index '{1}' which is already used by '{2}'." -f $_.name[0], [System.Guid]($_.rightsGuid[0]), $_ADRightsObjectNames[[System.Guid]($_.rightsGuid[0])].name)
                }            
                else {
                    $_ADRightsObjectNames.Add(
                        [System.Guid]($_.rightsGuid[0]),
                        @{
                            'name'=$_.name[0]
                            'displayName'=$_.displayName[0]
                        }
                    )
                }
            }
    }
    end {
    }
}
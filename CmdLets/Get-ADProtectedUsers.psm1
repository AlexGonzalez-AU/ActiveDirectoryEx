function Get-ADProtectedUsers {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=0)]
        [switch]$Default,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=1)]
        [system.directoryservices.directoryentry]$Domain=(Get-ADDomain)
    )

    begin {
    }
    process {
        $domainSID = $Domain | 
            Select-Object -ExpandProperty objectSid
        $domainSID[1] = 5

        if ($Default) {
            $pObjects =  Get-ADObjectWellKnownRid -Protected 
        }
        else {
            $pObjects = Get-ADObjectWellKnownRid -Protected | 
                Where-Object {
                    $_.Name -notin (Get-ADdwAdminSDExMask)
                }
        }

        $pObjects | 
            ForEach-Object {
                if ($_.Name.Contains("_ALIAS_")) {
                    $searchSid = [byte[]]@(1,2,0,0,0,0,0,5,32,0,0,0) + ($_.Value | ConvertTo-ByteRid) | 
                            ConvertTo-StringSid
                }
                else {
                    $searchSid = $domainSID + ($_.Value | ConvertTo-ByteRid) |
                        ConvertTo-StringSid 
                } 

                $pObject = $Domain |
                    Get-ADObject -Properties objectCategory, distinguishedName -LDAPFilter (
                        "objectSid={0}" -f $searchSid
                    )

                if ($pObject.objectCategory.ToLower().Contains('person')) {
                    $pObject
                }
            } | 
            Select-Object -Unique distinguishedName
    
        if (!$Default) {
            $Domain | 
                Get-ADProtectedGroups -Recurse | 
                Select-Object -ExpandProperty distinguishedName |
                Get-ADChildUser | 
                select -Unique distinguishedname
        }
    }
    end {
    }
}
function ConvertFrom-ObjectTypeGuid {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectoryAccessRule]
        $InputObject
    )

    begin {
    }
    process {
        if ($InputObject.ActiveDirectoryRights -eq [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight) {
            return $_ADRightsObjectNames[$InputObject.ObjectType].name
        }
        elseif (([string]$InputObject.ObjectType).Replace("-","").trim("0").length -eq 0) {
            return "All"
        }
        else {
            if ($_ADRightsObjectNames[$InputObject.ObjectType].name -eq $null) {
                return $_ADSchemaObjectNames[$InputObject.ObjectType].name
            }
            else {
                return $_ADRightsObjectNames[$InputObject.ObjectType].name
            }
        }
    }
    end {
    }
}
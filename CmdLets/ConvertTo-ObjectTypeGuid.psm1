function ConvertTo-ObjectTypeGuid {
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
        if ($InputObject.ObjectTypeName -eq 'All') {
            return '00000000-0000-0000-0000-000000000000'
        }
        elseif ($null -eq $_ADRightsObjectGuids[$InputObject.ObjectTypeName]) {
            return $_ADSchemaObjectGuids[$InputObject.ObjectTypeName]
        }
        else {
            return $_ADRightsObjectGuids[$InputObject.ObjectTypeName]
        }
    }
    end {
    }
}
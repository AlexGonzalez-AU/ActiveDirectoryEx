function ConvertTo-InheritedObjectTypeGuid {
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
        if ($InputObject.InheritedObjectTypeName -eq 'All') {
            return '00000000-0000-0000-0000-000000000000'
        }
        else {
            return $_ADSchemaObjectGuids[$InputObject.InheritedObjectTypeName]
        }
    }
    end {
    }
}
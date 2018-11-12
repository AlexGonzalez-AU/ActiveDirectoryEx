function ConvertTo-ObjectTypeGuid {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InputObject
    )

    begin {
    }
    process {
        if ($InputObject -eq 'All') {
            return '00000000-0000-0000-0000-000000000000'
        }
        elseif ($null -eq $_ADRightsObjectGuids[$InputObject]) {
            return $_ADSchemaObjectGuids[$InputObject]
        }
        else {
            return $_ADRightsObjectGuids[$InputObject]
        }
    }
    end {
    }
}
function ConvertFrom-InheritedObjectTypeGuid {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        $InputObject
    )

    begin {
    }
    process {
        if (([string]$InputObject.InheritedObjectType).Replace("-","").trim("0").length -eq 0) {
            return "All"
        }
        else {
            return $_ADSchemaObjectNames[$InputObject.InheritedObjectType].name
        }
    }
    end {
    }
}
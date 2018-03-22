function Get-ADForest {
    [CmdletBinding()]

    param (
    )

    begin {  
    }
    process {
        (Get-ADDirectoryEntry "rootDSE" | Select-Object -ExpandProperty configurationNamingContext).replace("CN=Configuration,","") | 
            Get-ADDirectoryEntry
    }
    end {
    }
}
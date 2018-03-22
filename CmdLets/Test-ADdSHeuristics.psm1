function Test-ADdSHeuristics {
    [CmdletBinding()]

    param (
    )    

    begin {
    }  
    process {
        ("CN=Configuration,{0}" -f (Get-ADForest | Select-Object -ExpandProperty distinguishedName) | 
            Get-ADDirectoryEntry |
            Get-ADObject -LDAPFilter "(name=Directory Service)" -Properties dSHeuristics | 
            Get-Member |
            Select-Object -ExpandProperty Name) -contains 'dSHeuristics'
    }
    end {
    }    
}
function Get-ADObject {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LDAPFilter,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [System.DirectoryServices.DirectoryEntry]
        $SearchRoot=(New-Object System.DirectoryServices.DirectoryEntry),
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        [string[]]
        $Properties = @(
            "name",
            "sAMAccountName",
            "distinguishedName",
            "userAccountControl"
        ),
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=3)]
        [string]
        $SearchScope='subtree',
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=4)]
        [int]
        $PageSize=116        
    )

    begin {
    }
    process {
        $search = New-Object System.DirectoryServices.DirectorySearcher
        $search.SearchRoot = $SearchRoot
        $search.PageSize = $PageSize    
        $search.SearchScope = $SearchScope
        
        $Properties | 
            ForEach-Object {
                $search.PropertiesToLoad.Add($_) | Out-Null
            }

        $search.filter = $LDAPFilter

        $rs = $search.FindAll()
        $rs | 
            ForEach-Object {
                New-Object -TypeName psobject -Property $_.Properties
            }
    }
    end  {
    }
}
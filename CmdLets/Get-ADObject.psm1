function Get-ADObject {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=0)]
        [ValidateNotNullOrEmpty()]
        $LDAPFilter,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        $Properties = @(
            "name",
            "sAMAccountName",
            "distinguishedName",
            "userAccountControl"
        ),
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        $Scope='subtree',
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=3)]
        [system.directoryservices.directoryentry]$Domain=(Get-ADDomain)
    )

    begin {
    }
    process {
        $search = New-Object System.DirectoryServices.DirectorySearcher
        $search.SearchRoot = $Domain
        $search.PageSize = 116
        $search.SearchScope = $Scope
        
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
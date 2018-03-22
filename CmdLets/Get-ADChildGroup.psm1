function Get-ADChildGroup {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [string]$DistinguishedName,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [switch]$Recurse,       
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=2)]
        [string[]]$RecurseDistinguishedNames=@()
    )    

    begin {
    }
    process {
        $DistinguishedName.Substring($DistinguishedName.ToLower().IndexOf("dc=")) |
            Get-ADDirectoryEntry | 
            Get-ADObject -LDAPFilter "(&(objectCategory=Group)(memberOf=$DistinguishedName))" |
            foreach {
                $_
                if ($Recurse) {
                    if (!$RecurseDistinguishedNames.Contains($_.distinguishedName.ToLower())) {
                        $RecurseDistinguishedNames += $_.distinguishedName.ToLower()
                        $_ | 
                            Select-Object -ExpandProperty distinguishedName |
                            Get-ADChildGroup -Recurse -RecurseDistinguishedNames $RecurseDistinguishedNames
                    }
                }
            }
    }
    end {
    }
}
function Get-ADdwAdminSDExMask {
    [CmdletBinding()]

    param (
    )
    
    begin {
    }
    process {
        $dSHeuristics = Get-ADdSHeuristics
        if ($dSHeuristics) {
            $dSHeuristics.dwAdminSDExMask | 
                Convert-ADdwAdminSDExMask
        }
    }
    end {
    }
}
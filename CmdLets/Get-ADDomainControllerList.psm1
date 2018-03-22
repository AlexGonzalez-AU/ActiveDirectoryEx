function Get-ADDomainControllerList {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [system.directoryservices.directoryentry]$Domain=(Get-ADDomain)
    )

    begin {
    }
    process {
        $Domain | 
            Select-Object -ExpandProperty masteredby | 
            foreach { 
                $_.split(",")[1].split("=")[1] 
            }
    }
    end {
    }
}
function Clear-ADObjectAdminCount {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [System.DirectoryServices.DirectoryEntry]
        $InputObject,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [switch]
        $Force
    )    

    begin {
    }
    process {
        $InputObject.Put("adminCount",@())
        if ($Force) {
            $p = 'y'
        }
        else {
            $p = Read-Host "Confirm (y/n)"
        }
        if ($p.ToLower().Trim() -eq 'y') {
            $InputObject.SetInfo()
        }
        else {
            $InputObject = $null
            Write-Error "Operation 'SetInfo for adminCount' aborted by user."
        }
    }
    end {
    }
}
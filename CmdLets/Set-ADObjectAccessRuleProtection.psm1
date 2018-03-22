function Set-ADObjectAccessRuleProtection {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [System.DirectoryServices.DirectoryEntry]$InputObject,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=1)]
        [bool]$IsProtected,
        [Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=2)]
        [bool]$PreserveInheritance,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false,Position=3)]
        [switch]$Force
    )    

    begin {
    }
    process {
        #$InputObject.psbase.Options.SecurityMasks = [System.DirectoryServices.SecurityMasks]::Dacl
        $InputObject.psbase.ObjectSecurity.SetAccessRuleProtection($IsProtected, $PreserveInheritance)
        if ($Force) {
            $p = 'y'
        }
        else {
            $p = Read-Host "Confirm (y/n)"
        }
        if ($p.ToLower().Trim() -eq 'y') {
            $InputObject.psbase.CommitChanges()
        }
        else {
            $InputObject = $null
            Write-Error "Operation 'SetAccessRuleProtection' aborted by user."
        }
    }
    end {
    }
}
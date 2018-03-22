function Convert-ADdwAdminSDExMask {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )

    begin { 
        $Domain_Alias_RID_Account_Ops = [int]"0x1"
        $Domain_Alias_RID_System_Ops  = [int]"0x2"
        $Domain_Alias_RID_Print_Ops   = [int]"0x4"
        $Domain_Alias_RID_Backup_Ops  = [int]"0x8"
        [array]$return = @()
    }
    process {
        if ($InputObject -band $Domain_Alias_RID_Account_Ops) {
            $return += "DOMAIN_ALIAS_RID_ACCOUNT_OPS"
        }
        if ($InputObject -band $Domain_Alias_RID_System_Ops) {
            $return += "DOMAIN_ALIAS_RID_SYSTEM_OPS"
        }
        if ($InputObject -band $Domain_Alias_RID_Print_Ops) {
            $return += "DOMAIN_ALIAS_RID_PRINT_OPS"
        }
        if ($InputObject -band $Domain_Alias_RID_Backup_Ops) {
            $return += "DOMAIN_ALIAS_RID_BACKUP_OPS"
        }
        return $return
    }
    end {
    }
}
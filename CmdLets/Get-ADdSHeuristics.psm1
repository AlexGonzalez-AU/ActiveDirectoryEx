function Get-ADdSHeuristics {
    [CmdletBinding()]

    param (
    )    

    begin {
    }
    process {
        if (Test-ADdSHeuristics) {
            [string]$dSHeuristics = "CN=Configuration,{0}" -f (Get-ADForest | Select-Object -ExpandProperty distinguishedName) | 
                Get-ADDirectoryEntry |
                Get-ADObject -LDAPFilter "(name=Directory Service)" -Properties dSHeuristics | 
                Select-Object -ExpandProperty dSHeuristics

            while ($dSHeuristics.Length -lt 25) {
                $dSHeuristics += 0
            }

            return @{
                fSupFirstLastANR                                = [int]("0x{0}" -f $dSHeuristics.Substring(0,1))
                fSupLastFirstANR                                = [int]("0x{0}" -f $dSHeuristics.Substring(1,1))
                fDoListObject                                   = [int]("0x{0}" -f $dSHeuristics.Substring(2,1))
                fDoNickRes                                      = [int]("0x{0}" -f $dSHeuristics.Substring(3,1))
                fLDAPUsePermMod                                 = [int]("0x{0}" -f $dSHeuristics.Substring(4,1))
                ulHideDSID                                      = [int]("0x{0}" -f $dSHeuristics.Substring(5,1))
                fLDAPBlockAnonOps                               = [int]("0x{0}" -f $dSHeuristics.Substring(6,1))
                fAllowAnonNSPI                                  = [int]("0x{0}" -f $dSHeuristics.Substring(7,1))
                fUserPwdSupport                                 = [int]("0x{0}" -f $dSHeuristics.Substring(8,1))
                tenthChar                                       = [int]("0x{0}" -f $dSHeuristics.Substring(9,1))
                fSpecifyGUIDOnAdd                               = [int]("0x{0}" -f $dSHeuristics.Substring(10,1))
                fDontStandardizeSDs                             = [int]("0x{0}" -f $dSHeuristics.Substring(11,1))
                fAllowPasswordOperationsOverNonSecureConnection = [int]("0x{0}" -f $dSHeuristics.Substring(12,1))
                fDontPropagateOnNoChangeUpdate                  = [int]("0x{0}" -f $dSHeuristics.Substring(13,1))
                fComputeANRStats                                = [int]("0x{0}" -f $dSHeuristics.Substring(14,1))
                dwAdminSDExMask                                 = [int]("0x{0}" -f $dSHeuristics.Substring(15,1))
                fKVNOEmuW2K                                     = [int]("0x{0}" -f $dSHeuristics.Substring(16,1))
                fLDAPBypassUpperBoundsOnLimits                  = [int]("0x{0}" -f $dSHeuristics.Substring(17,1))
                fDisableAutoIndexingOnSchemaUpdate              = [int]("0x{0}" -f $dSHeuristics.Substring(18,1))
                twentiethChar                                   = [int]("0x{0}" -f $dSHeuristics.Substring(19,1))
                DoNotVerifyUPNAndOrSPNUniqueness                = [int]("0x{0}" -f $dSHeuristics.Substring(20,1))
                MinimumGetChangesRequestVersion                 = [int]("0x{0}" -f $dSHeuristics.Substring(21,2))
                MinimumGetChangesReplyVersion                   = [int]("0x{0}" -f $dSHeuristics.Substring(23,2))
            }
        }
        else {
            return $null
        }
    }
    end {
    }
}
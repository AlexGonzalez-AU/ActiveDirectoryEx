function ConvertTo-ByteRid {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [int]$Rid
    )

    begin {
    }
    process {
        [byte[]]$return = @()
        $return += "0x{0}" -f ("{0:x8}" -f $Rid).Substring(6,2)
        $return += "0x{0}" -f ("{0:x8}" -f $Rid).Substring(4,2)
        $return += "0x{0}" -f ("{0:x8}" -f $Rid).Substring(2,2)
        $return += "0x{0}" -f ("{0:x8}" -f $Rid).Substring(0,2)
        return $return
    }
    end {
    }
}
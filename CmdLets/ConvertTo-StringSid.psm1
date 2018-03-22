function ConvertTo-StringSid {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Byte]$ByteSid
    )

    begin {
        $return = ""
    }
    process {
        $ByteSid | 
            ForEach-Object {
                $return = "{0}\{1:x2}" -f $return, $_
            }
    }
    end {
        return $return
    }
}
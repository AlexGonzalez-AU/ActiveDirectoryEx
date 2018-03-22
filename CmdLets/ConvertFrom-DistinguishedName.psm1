function ConvertFrom-DistinguishedName {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [string]$InputObject
    )

    begin {
    }
    process {
        $path = $InputObject.replace($InputObject.Substring($InputObject.IndexOf('DC=')),'').replace('CN=','').replace('OU=','').trim(',').split(',')
        $path += $InputObject.Substring($InputObject.IndexOf('DC=')).replace('DC=','').replace(',','.')
        [array]::Reverse($path)
        return ($path -join '/').trim('/')
    }
    end {
    }
}
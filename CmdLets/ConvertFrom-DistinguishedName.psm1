function ConvertFrom-DistinguishedName {
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InputObject
    )

    begin {
    }
    process {
        $objcetPath = $InputObject.replace($InputObject.Substring($InputObject.IndexOf('DC=')),'').replace('CN=','').replace('OU=','').trim(',').split(',')
        $objcetPath += $InputObject.Substring($InputObject.IndexOf('DC=')).replace('DC=','').replace(',','.')
        [array]::Reverse($objcetPath)
        return ($objcetPath -join '/').trim('/')
    }
    end {
    }
}
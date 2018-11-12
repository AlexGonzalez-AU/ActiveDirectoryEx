[string[]]$module = @()

Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\Modules\ActiveDirectoryEx.psd1')  |
    Select-String  -SimpleMatch '..\CmdLets\' |
    Select-Object -ExpandProperty Line |
    ForEach-Object {
        $module += Get-Content -Path $_.Trim().Trim(",").Trim("'").ToLower().Replace('..\cmdlets\','..\ActiveDirectoryEx\CmdLets\')
        $module += ""
    }

if (-not (Test-Path (Join-Path -Path $PSScriptRoot -ChildPath '..\tmp'))) {
    New-Item -ItemType Directory -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\tmp') 
}

$module |
    Out-File -FilePath (Join-Path -Path $PSScriptRoot -ChildPath '..\tmp\ActiveDirectoryEx.psm1') 
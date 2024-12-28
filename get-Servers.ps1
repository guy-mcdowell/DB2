Import-Module ActiveDirectory

Get-ADComputer -Filter * | Select-Object Name #| Export-Csv -Path "$PSScriptRoot\CSV\servers.csv" -NoTypeInformation


$server = "THRC-AGTAPP01"

Invoke-Command -ComputerName $server -ScriptBlock {
    param($server)
    Write-Output $message
} -ArgumentList $variable
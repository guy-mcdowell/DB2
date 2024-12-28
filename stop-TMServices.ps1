<#
.SYNOPSIS
    Stop all TruckMate Windows services.

.DESCRIPTION


.PARAMETERS 


.EXAMPLE
    


.NOTES
    Author: Guy McDowell
    Date Created: 2024-11-05
    Last Modified: 2024-11-05
    Version: 1.0
    Dependencies:
    Assumptions:

.SUGGESTIONS
TruckMate API Service
TruckMate_API_Apache
ART[API_CD]
ART[API_IMAGING]
Apache2.4.57_TM4WEB
Apache2.4.58_TM4WEB


.REVISION HISTORY
    Date        Author       Version     Description
    ----        ------       -------     -----------
    2024-11-05  G. McDowell  1.0         Initial version.
    
#>

CLS

Start-Transcript -Path "$PSScriptRoot\stop-TMServices-LOG-$(get-date -f yyyy-MM-ddhhmmss).txt"

Import-Module ActiveDirectory

Get-ADComputer -Filter * | Select-Object Name | Export-Csv -Path "$PSScriptRoot\CSV\servers.csv" -NoTypeInformation

# List of base service names
$servicesToStop = @(
    "MileServ",
    "BillingRegisterService",
    "BillPrintingService",
    "IPAccrualService",
    "IPRegService",
    "MadHostSvc",
    "TruckMate API",
    "TruckMate_API_Apache",
    "Apache2.4.5",
    "ART"


)

# Output CSV file path
$outputFile = "StoppedServices.csv"
$stoppedServices = @()

# Input servers CSV
$servers = "servers.csv"

# Loop through servers
foreach ($server in $servers) {

    # Loop through each base service name
    foreach ($baseName in $servicesToStop) {

        # Find services with the exact name or followed by a number
        $matchingServices = Get-Service | Where-Object {
            $_.Name -match "^$baseName(\d*)$"
        }
        
        # Stop each matching service
        foreach ($service in $matchingServices) {
            if ($service.Status -eq 'Running') {
                try {
                    Write-Output "Stopping service: $($service.Name)"
                    Stop-Service -Name $service.Name -Force -ErrorAction Stop
                    Write-Output "Service $($service.Name) stopped successfully."

                    # Add to list of stopped services
                    $stoppedServices += [PSCustomObject]@{
                        ServiceName = $service.Name
                        Status      = "Stopped"
                    }
                } catch {
                    Write-Output "Failed to stop service $($service.Name): $($_.Exception.Message)"
                }
            } else {
                Write-Output "Service $($service.Name) is not running."
            }
        }
    }
}

# Export the stopped services list to CSV
$stoppedServices | Export-Csv -Path $outputFile -NoTypeInformation -Force
Write-Output "Stopped services list saved to $outputFile."

Stop-Transcript
<#
$server = "THRC-AGTAPP01"

Invoke-Command -ComputerName $server -ScriptBlock {
    param($server)
    Write-Output $message
} -ArgumentList $variable
#>
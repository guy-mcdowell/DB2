<#
.SYNOPSIS
    Start all TruckMate Windows services previously stopped by stop-TMServices.ps1

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


.REVISION HISTORY
    Date        Author       Version     Description
    ----        ------       -------     -----------
    2024-11-05  G. McDowell  1.0         Initial version.
    
#>

CLS

Start-Transcript -Path "$PSScriptRoot\start-TMServices-LOG-$(get-date -f yyyy-MM-ddhhmmss).txt"

# Input CSV file path
$inputFile = "StoppedServices.csv"

# Import the list of stopped services
if (Test-Path -Path $inputFile) {
    $stoppedServices = Import-Csv -Path $inputFile

    # Start each service listed in the CSV
    foreach ($service in $stoppedServices) {
        $serviceName = $service.ServiceName
        try {
            Write-Output "Starting service: $serviceName"
            Start-Service -Name $serviceName -ErrorAction Stop
            Write-Output "Service $serviceName started successfully."
        } catch {
            Write-Output "Failed to start service $serviceName : $($_.Exception.Message)"
        }
    }
} else {
    Write-Output "The CSV file $inputFile was not found. Please ensure the file exists."
}

Stop-Transcript
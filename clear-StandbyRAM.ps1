# Path to the RAMMap executable
$rammapPath = "C:\DB2 Utilities\3rd party tools\RAMMap.exe"
 
# Check if RAMMap executable exists
if (Test-Path $rammapPath) {
    # Run RAMMap with the -E option to empty the standby list
    Start-Process -FilePath $rammapPath -ArgumentList "-Et" -NoNewWindow -Wait
 
    Write-Host "Standby list cleared successfully."
} else {
    Write-Host "RAMMap executable not found at path: $rammapPath"
}
$serviceName = "DB2MGMTSVC_DB2COPY1"  # Replace with the actual name of your DB2 service
$service = Get-Service -Name $serviceName

if ($service.Status -eq 'Running') {
    Write-Output "DB2 service is running."
} else {
    Write-Output "DB2 service is stopped."
}

# Define the instance and database
$instance = "DB2"
$database = "TM24SP3"

# Set the DB2 environment
$env:DB2INSTANCE = $instance

# Execute the DB2 command to list applications
$cmd = "db2 list applications for database $database"
$result = & db2cmd /c /w /i $cmd

# Output the result
Write-Output $result


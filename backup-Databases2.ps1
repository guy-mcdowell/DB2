CLS

# Define variables
$dbName = "TM24SP3"
$backupDir = "C:\DB2BACKUPS"

# Function to get the database size
function Get-DB2DatabaseSize($dbName) {
    $sizeCommand = "db2 connect to TM24SP3 && db2 'SELECT SUM(TOTAL_SIZE) FROM SYSIBMADM.ADMINTABINFO'"
    $output = & db2cmd.exe /c $sizeCommand
    $output

    $sizeInPages = [regex]::Match($output, '\d+').Value

    # Assuming page size is 4KB (common DB2 page size)
    $pageSizeKB = 4
    $sizeInKB = $sizeInPages * $pageSizeKB
    $sizeInGB = [math]::Round($sizeInKB / 1024 / 1024, 2)
    return $sizeInGB
}

# Estimate the backup time based on the size of the database
function EstimateBackupTime($dbSizeGB, $backupSpeedMBps) {
    $backupTimeSeconds = ($dbSizeGB * 1024) / $backupSpeedMBps
    return [math]::Ceiling($backupTimeSeconds)
}

# Get the database size
$dbSizeGB = Get-DB2DatabaseSize $dbName

# Assume a backup speed of 100 MBps
$backupSpeedMBps = 100
$estimatedTimeSeconds = EstimateBackupTime $dbSizeGB, $backupSpeedMBps

# Initialize DB2 command line environment and execute commands
Write-Host "Initializing DB2 command line environment and executing commands..."
$commands = @"
db2 backup database $dbName to $backupDir without prompting
if %errorlevel% equ 0 (
    echo Backup completed successfully.
    ) else (
    echo Backup failed.
    )
db2start
"@

# Write the commands to a temporary batch file
$tempFile = [System.IO.Path]::GetTempFileName() + ".bat"
[System.IO.File]::WriteAllText($tempFile, $commands)

# Start the DB2 command in a separate process
$process = Start-Process "db2cmd.exe" -ArgumentList "/c $tempFile" -PassThru

# Simulate progress bar
$progressIncrement = 5
$elapsedTime = 0

while (!$process.HasExited) {
    $percentComplete = [math]::Min((($elapsedTime / $estimatedTimeSeconds) * 100), 100)
    
    Write-Progress -Activity "Backing up DB2 database" -Status "$percentComplete% Complete" -PercentComplete $percentComplete
    Start-Sleep -Seconds $progressIncrement
    $elapsedTime += $progressIncrement
}

# Wait for the process to complete if it hasn't already
$process.WaitForExit()

# Clean up the temporary batch file
Remove-Item $tempFile

# Output the result
if ($process.ExitCode -eq 0) {
    Write-Host "Backup completed successfully."
} else {
    Write-Host "Backup failed."
}

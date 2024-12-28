CLS

Start-Transcript -Path "$PSScriptRoot\LOGS\update-TestDB-LOG-$(get-date -f yyyy-MM-ddhhmmss).txt"

# Ensure that the DB2 command line processor is initialized
Set-Location "C:\Program Files\IBM\SQLLIB\BIN"

# Define the DB for the backup
$prodDB = "TM24SP3"
$testDB = "TEST"

# Define the path for the backup
$backupPath = "C:\DB2BACKUPS\OFFLINE"

# Ensure that the DB2 command line processor is initialized within the job, close all connections to the DB, and deactivate both the prod and test DBs
Set-Location "C:\Program Files\IBM\SQLLIB\BIN"
& "db2cmd.exe" /c /w /i db2 "force applications all"
& "db2cmd.exe" /c /w /i db2 "DEACTIVATE DATABASE $prodDB"

        
$backupCommand = "db2cmd.exe /c /w /i db2 backup database $prodDB to $backupPath compress without prompting"
#Invoke-Expression $backupCommand

# Execute the command and capture the output
Write-Host "Beginning backup of $prodDB" -ForegroundColor Yellow
$output = Invoke-Expression $backupCommand
Write-Output "Command output:"
Write-Output $output

# Use a regex to capture the backup file name from the output
$backupNamePattern = "Backup successful. The timestamp for this backup image is : (\d+)"

if ($output -match $backupNamePattern) {

    $timestamp = [regex]::match($output, '\d{14}').Value

    $backupName = "$prodDB.0.DB2.DBPART000.$timestamp.001"

    if ($LASTEXITCODE -eq 0) {
    Write-Host "Backup of $prodDB completed successfully." -ForegroundColor Green
    Write-Host "Backup file name: $backupName" -ForegroundColor Green
    & "db2cmd.exe" /c /w /i db2 "ACTIVATE DATABASE $prodDB"
    } else { 
        Write-Host "Backup of $prodDB failed." -ForegroundColor Red
        Exit
    }

} else {
    Write-Host "Failed to capture the backup file name" -ForegroundColor Red
    Exit
}

# Define source and destination paths
#$sourcePath = "\\REMOTESERVER\C$\DB2BACKUPS\offline" # Replace with your destination folder path
$sourcePath = "C:\DB2BACKUPS\OFFLINE" # Replace with your destination folder path 
$destinationPath = "C:\DB2BACKUPS\TEST" # Replace with your destination folder path

# Define log file path
$logFilePath = "$PSScriptRoot\LOGS\RobocopyLog-$(get-date -f yyyy-MM-ddhhmmss).txt" # Adjust the path as needed

# Robocopy command with options
# /Z enables restartable mode (for interrupted copies)
# /J enables unbuffered I/O (better for large files)
# /R:2 specifies 2 retries on failed copies (adjust as needed)
# /W:5 specifies a 5-second wait between retries (adjust as needed)
$robocopyOptions = "/Z", "/J", "/R:2", "/W:5", "/LOG:$logFilePath"

# Execute the robocopy command
robocopy $sourcePath $destinationPath $backupName $robocopyOptions

# Check if the copy was successful
if ($LASTEXITCODE -le 3) {
    Write-Host "File copied successfully." -ForegroundColor Green
    & "db2cmd.exe" /c /w /i db2 "DEACTIVATE DATABASE $testDB"
} else {
    Write-Host "Errors occurred during the copy process. Check logs for details." -ForegroundColor Red
    Exit
}

    Write-Host "Beginning restore into $testDB" -ForegroundColor Yellow

    $restoreCommand = "db2cmd.exe /c /w /i db2 restore database $prodDB from C:\DB2BACKUPS\TEST taken at $timestamp on C:\ into $testDB with 2 buffers buffer 1024 parallelism 1 without prompting"

    $restoreOutputPattern = "Restore is successful"
    #Invoke-Expression $restoreCommand
    # Execute the command and capture the output
    $restoreOutput = Invoke-Expression $restoreCommand

    if ($restoreOutput -match $restoreOutputPattern) {
        Write-Host "Restoration of $testDB completed successfully." -ForegroundColor Green
    }
    else{
        Write-Host "Command output: $restoreOutput" -ForegroundColor Red
    }
    
    & "db2cmd.exe" /c /w /i db2 "ACTIVATE DATABASE $testDB"

Stop-Transcript
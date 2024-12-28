CLS

# Define variables
$dbName = "TM24SP3"
$backupDir = '"C:\DB2BACKUPS"'

# Initialize DB2 command line environment and execute commands
Write-Host "Initializing DB2 command line environment and executing commands..."
$commands = @"

db2 backup database $dbName to $backupDir without prompting
if %errorlevel% equ 0 (
    echo Backup completed successfully.
) else (
    echo Backup failed.
)
pause
"@

# Write the commands to a temporary batch file
$tempFile = [System.IO.Path]::GetTempFileName() + ".bat"
[System.IO.File]::WriteAllText($tempFile, $commands)

# Execute the batch file within db2cmd
Start-Process "db2cmd.exe" -ArgumentList "/c $tempFile" -Wait

# Clean up the temporary batch file
Remove-Item $tempFile

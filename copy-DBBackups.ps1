<#
.SYNOPSIS
    Copy large DB backup files from one server to another within the same domain.

.DESCRIPTION
    Uing ROBOCOPY, all files are copied from a share on a source server to a share on a destination server.
    ROBOCOPY gives greater network fault tolerance and resumable transfers.
    NOTE: copy PoSh script to the root of the drive where the source DBs are stored.
    I prefer to run it in an elevated instance of PowerShell ISE so I can make changes as needed.
    It will create 2 logs:
    The PowerShell scripts transcript - for checking PoSh errors
    The ROBOCOPY log - for checking ROBOCOPY errors

.PARAMETERS 
    Key parameters:
    $sourcePath - The source share where the backups are.
    $destinationPath - the destination share.

.EXAMPLE
    
    $sourcePath = "\\LTSI-DB201\online" # Replace with your source folder path
    $destinationPath = "\\LTSI-TAPP01\DB2Backup\online" # Replace with your destination folder path

.NOTES
    Author: Guy McDowell
    Date Created: 2024-11-04
    Last Modified: 2024-11-04
    Version: 1.0
    Dependencies: 
    Shared folders on both servers
    Assumptions: 
    Logged in as user that has read/write on both shares
    Both shares are on the same domain
    All files in the source share need to be copied over

.SUGGESTIONS


.REVISION HISTORY
    Date        Author       Version     Description
    ----        ------       -------     -----------
    2024-11-04  G. McDowell  1.0         Initial version.

#>

CLS

Start-Transcript -Path "$PSScriptRoot\copy-DBBackups-LOG-$(get-date -f yyyy-MM-ddhhmmss).txt"

# Define source and destination paths
$sourcePath = "\\ONTA-DB201\G$\DB2BACKUPS\offline" # Replace with your source folder path
$destinationPath = "C:\DB2BACKUPS" # Replace with your destination folder path
# Define log file path
$logFilePath = "$PSScriptRoot\RobocopyLog.txt" # Adjust the path as needed

# Robocopy command with options
# /Z enables restartable mode (for interrupted copies)
# /J enables unbuffered I/O (better for large files)
# /R:2 specifies 2 retries on failed copies (adjust as needed)
# /W:5 specifies a 5-second wait between retries (adjust as needed)
$robocopyOptions = "/Z", "/J", "/R:2", "/W:5", "/LOG:$logFilePath"

# Execute the robocopy command
robocopy $sourcePath $destinationPath *.* $robocopyOptions

# Check if the copy was successful
if ($LASTEXITCODE -le 3) {
    Write-Output "Files copied successfully."
} else {
    Write-Output "Errors occurred during the copy process. Check logs for details."
}

Stop-Transcript
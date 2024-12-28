CLS


# Ensure that the DB2 command line processor is initialized
Set-Location "C:\Program Files\IBM\SQLLIB\BIN"
& "db2cmd.exe" /c /w /i db2 "ACTIVATE DATABASE $prodDB"

#Test DB backup

        # Execute DB2 commands
        & "db2cmd.exe" /c /w /i db2 "connect to TEST user TMWIN using M@dd0x01"

        # Run REORGCHK and capture the output
        & "db2cmd.exe" /c /w /i db2 "REORGCHK UPDATE STATISTICS ON TABLE ALL"
<#
        # Retrieve all table names
        $getTablesCmd = "db2 -x \"SELECT 'RUNSTATS ON TABLE ' || RTRIM(TABSCHEMA) || '.' || RTRIM(TABNAME) FROM SYSCAT.TABLES WHERE TYPE = 'T' AND TABSCHEMA NOT LIKE 'SYS%'\""
        $tableList = Invoke-Expression $getTablesCmd

        # Loop through each table and run RUNSTATS
        foreach ($table in $tableList) {
            $runstatsCmd = "db2 $table"
            Write-Output "Running: $runstatsCmd"
            Invoke-Expression $runstatsCmd
        }
#>
        # Disconnect from the database
        & "db2cmd.exe" /c /w /i db2 "disconnect TEST"
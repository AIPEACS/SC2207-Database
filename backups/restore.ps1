# Restore database from backup CSV file created by export_all or backup-YYYYMMDD-HHMMSS.csv.
# Usage: .\backups\restore.ps1

function Read-BackupFileName {
    $currentDir = Get-Location
    while ($true) {
        Write-Host "Available backup files in $currentDir (pattern backup-*.csv):"
        Get-ChildItem -Path $currentDir -Filter 'backup-*.csv' -File -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  $($_.Name)"
        }

        $fileName = Read-Host 'Enter backup file name (e.g. backup-20260329-123456.csv)'
        if ([string]::IsNullOrWhiteSpace($fileName)) {
            Write-Warning 'Please enter a file name.'
            continue
        }

        $fullPath = Join-Path -Path $currentDir -ChildPath $fileName
        if (Test-Path -Path $fullPath) {
            return $fullPath
        }

        Write-Warning "File not found: $fileName. Please choose an existing backup file."
    }
}

function Restore-BackupFromCsv {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BackupPath
    )

    $lines = Get-Content -Path $BackupPath -ErrorAction Stop

    $sections = @()
    $currentTable = $null
    $currentRows = @()

    foreach ($line in $lines) {
        if ($line -match '^---\s*([^\(]+?)\s*(?:\(\d+\srows\))?\s*---$') {
            if ($currentTable) {
                $sections += [PSCustomObject]@{ Table = $currentTable; Rows = $currentRows }
            }

            $currentTable = $matches[1].Trim()
            $currentRows = @()
        } elseif ($currentTable) {
            $currentRows += $line
        }
    }

    if ($currentTable) {
        $sections += [PSCustomObject]@{ Table = $currentTable; Rows = $currentRows }
    }

    if (-not $sections) {
        Throw "No table sections found in backup file $BackupPath"
    }

    $connectionString = 'Server=<HOST>;Database=<DATABASE>;User Id=<USERNAME>;Password=<PASSWORD>;Encrypt=False;TrustServerCertificate=True;'
    Add-Type -AssemblyName System.Data

    $connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $connection.Open()

    try {
        foreach ($section in $sections) {
            $tableName = $section.Table
            if (-not $tableName) { continue }
            $rows = $section.Rows

            if (-not $rows -or $rows.Count -lt 1) {
                Write-Host "[INFO] Skipping table '$tableName' (no data)"
                continue
            }

            $csvText = $rows -join "`n"
            $records = $csvText | ConvertFrom-Csv -ErrorAction Stop
            if (-not $records) {
                Write-Host "[INFO] Skipping table '$tableName' (no parsed rows)"
                continue
            }

            Write-Host "[INFO] Restoring table $tableName ($($records.Count) rows)"

            $command = $connection.CreateCommand()
            $command.CommandText = "TRUNCATE TABLE [$tableName]"
            try {
                $command.ExecuteNonQuery() | Out-Null
            } catch {
                Write-Warning "Could not truncate $tableName; attempting DELETE instead. $_"
                $command.CommandText = "DELETE FROM [$tableName]"
                $command.ExecuteNonQuery() | Out-Null
            }

            $columns = $records[0].PSObject.Properties.Name
            $colsQue = $columns -join ', '
            $params = $columns | ForEach-Object { "@$_" }
            $paramList = $params -join ', '

            $insertSql = "INSERT INTO [$tableName] ($colsQue) VALUES ($paramList)"
            $insertCmd = $connection.CreateCommand()
            $insertCmd.CommandText = $insertSql

            foreach ($record in $records) {
                $insertCmd.Parameters.Clear()
                foreach ($col in $columns) {
                    $value = $record.$col
                    if ($null -eq $value -or $value -eq '') {
                        $insertCmd.Parameters.AddWithValue("@$col", [DBNull]::Value) | Out-Null
                    } else {
                        $insertCmd.Parameters.AddWithValue("@$col", $value) | Out-Null
                    }
                }

                try {
                    $insertCmd.ExecuteNonQuery() | Out-Null
                } catch {
                    Write-Warning "Insert failed for table '$tableName': $($_.Exception.Message)"
                    break
                }
            }

            Write-Host "[OK] Table $tableName restored ($($records.Count) rows)."
        }
    } finally {
        $connection.Close()
    }

    Write-Host "[SUCCESS] Restore completed from $BackupPath"
}

# Entry point
$backupFilePath = Read-BackupFileName
Restore-BackupFromCsv -BackupPath $backupFilePath

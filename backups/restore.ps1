# Restore database from backup CSV file created by export_all or backup-YYYYMMDD-HHMMSS.csv.
# Usage: .\backups\restore.ps1

function Read-BackupFileName {
    $currentDir = Get-Location
    $files = Get-ChildItem -Path $currentDir -Filter 'backup-*.csv' -File -ErrorAction SilentlyContinue | Sort-Object Name

    if (-not $files) {
        Throw "No backup files found in $currentDir"
    }

    while ($true) {
        Write-Host "Available backup files in ${currentDir}:"
        $index = 0
        foreach ($file in $files) {
            $index++
            Write-Host "  [$index] $($file.Name)"
        }

        $input = Read-Host 'Enter number of backup to restore (e.g. 1)'
        if ([string]::IsNullOrWhiteSpace($input) -or -not ($input -as [int])) {
            Write-Warning 'Please enter a valid number.'
            continue
        }

        $selected = [int]$input
        if ($selected -lt 1 -or $selected -gt $files.Count) {
            Write-Warning "Invalid choice $selected. Enter a number between 1 and $($files.Count)."
            continue
        }

        return $files[$selected - 1].FullName
    }
}

function Restore-BackupFromCsv {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BackupPath
    )

    $lines = Get-Content -Path $BackupPath -ErrorAction Stop

    $sections = @{}
    $currentTable = $null
    $currentRows = @()

    foreach ($line in $lines) {
        if ($line -match '^---\s*([^\(]+?)\s*(?:\(\d+\srows\))?\s*---$') {
            if ($currentTable -and $currentRows.Count -gt 0) {
                $sections[$currentTable] = $currentRows
            }
            $currentTable = $matches[1].Trim()
            $currentRows = @()
            continue
        }
        if (-not $line.Trim()) { continue }
        if ($currentTable) {
            $currentRows += $line
        }
    }
    if ($currentTable -and $currentRows.Count -gt 0) {
        $sections[$currentTable] = $currentRows
    }

    if (-not $sections.Keys.Count) {
        Throw "No table sections found in backup file $BackupPath"
    }

    $connectionString = 'Server=<HOST>;Database=<DATABASE>;User Id=<USERNAME>;Password=<PASSWORD>;Encrypt=False;TrustServerCertificate=True;'
    Add-Type -AssemblyName System.Data

    $connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $connection.Open()

    try {
        # Disable FK constraints to allow any order
        $disableCmd = $connection.CreateCommand()
        $disableCmd.CommandText = "EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'"
        $disableCmd.ExecuteNonQuery() | Out-Null

        $identityTables = @('Client','Product','Supplier','Warehouse','Item','PurchaseOrder','Route','Shipment','Staff','Vehicle')
        $restoreOrder = @(
            'Client', 'Supplier', 'Warehouse', 'Product', 'Route', 'Vehicle', 'Staff', 'Employee', 'Driver', 'Zone',
            'Item', 'PurchaseOrder', 'Shipment', 'Shipment_Supplier', 'Shipment_Warehouse', 'Supply',
            'Inventory', 'InventoryMovement', 'OrderItem', 'ShipItem', 'ProductHandling'
        )

        foreach ($tableName in $restoreOrder) {
            if (-not $sections.ContainsKey($tableName)) {
                Write-Host "[INFO] Skipping missing table section $tableName"
                continue
            }

            $rows = $sections[$tableName]
            if (-not $rows -or $rows.Count -lt 2) {
                Write-Host "[INFO] Skipping empty table section $tableName"
                continue
            }

            $csvText = $rows -join "`n"
            $records = $csvText | ConvertFrom-Csv -ErrorAction Stop

            Write-Host "[INFO] Restoring table $tableName ($($records.Count) rows)"

            $cmd = $connection.CreateCommand()
            $cmd.CommandText = "DELETE FROM [$tableName]"
            $cmd.ExecuteNonQuery() | Out-Null

            $isIdentity = $identityTables -contains $tableName
            if ($isIdentity) {
                $idOnCmd = $connection.CreateCommand()
                $idOnCmd.CommandText = "SET IDENTITY_INSERT [$tableName] ON"
                $idOnCmd.ExecuteNonQuery() | Out-Null
            }

            $columns = $records[0].PSObject.Properties.Name
            $colsSql = $columns -join ', '

            foreach ($record in $records) {
                $paramNames = $columns | ForEach-Object { "@$_" }
                $paramList = $paramNames -join ', '

                $insertCmd = $connection.CreateCommand()
                $insertCmd.CommandText = "INSERT INTO [$tableName] ($colsSql) VALUES ($paramList)"

                foreach ($col in $columns) {
                    $value = $record.$col
                    if ($null -eq $value -or $value -eq '') {
                        $insertCmd.Parameters.AddWithValue("@$col", [DBNull]::Value) | Out-Null
                    } else {
                        $insertCmd.Parameters.AddWithValue("@$col", $value) | Out-Null
                    }
                }

                $insertCmd.ExecuteNonQuery() | Out-Null
            }

            if ($isIdentity) {
                $idOffCmd = $connection.CreateCommand()
                $idOffCmd.CommandText = "SET IDENTITY_INSERT [$tableName] OFF"
                $idOffCmd.ExecuteNonQuery() | Out-Null
            }

            Write-Host "[OK] Table $tableName restored ($($records.Count) rows)."
        }

        $enableCmd = $connection.CreateCommand()
        $enableCmd.CommandText = "EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'"
        $enableCmd.ExecuteNonQuery() | Out-Null
    }
    finally {
        $connection.Close()
    }

    Write-Host "[SUCCESS] Restore completed from $BackupPath"
}

# Entry point
$backupFilePath = Read-BackupFileName
Restore-BackupFromCsv -BackupPath $backupFilePath

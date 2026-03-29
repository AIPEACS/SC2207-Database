# Restore database from backup CSV file created by export_all or backup-YYYYMMDD-HHMMSS.csv.
# Usage:
#   .\backups\restore.ps1
#   .\backups\restore.ps1 -BackupPath 'S:\path\to\backups\backup-20260329-123456.csv'
param(
    [Parameter(Mandatory = $false)]
    [string]$BackupPath = ''
)

function Read-BackupFileName {
    $backupDir = $PSScriptRoot
    $files = Get-ChildItem -Path $backupDir -Filter 'backup-*.csv' -File -ErrorAction SilentlyContinue | Sort-Object Name

    if (-not $files) {
        Throw "No backup files found in $backupDir"
    }

    while ($true) {
        Write-Host "Available backup files in ${backupDir}:"
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
            'Delivery', 'Item', 'PurchaseOrder', 'Shipment', 'Shipment_Supplier', 'Shipment_Warehouse', 'Supply',
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

            function Convert-DateField {
                param (
                    [string]$raw,
                    [bool]$isDateOnly = $false
                )

                if ([string]::IsNullOrWhiteSpace($raw)) { return $null }

                if ($raw -match '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') {
                    # date-only value should stay as local date
                    return [datetime]::ParseExact($raw, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)
                }

                # Format "Wed Jan 28 2026 08:00:00 GMT+0800 (China Standard Time)" -> "Wed Jan 28 2026 08:00:00 +08:00"
                $expr = $raw -replace ' GMT([+-]\d{2})(\d{2})', ' $1:$2'
                $expr = $expr -replace '\s*\([^)]*\)$', ''

                if ($isDateOnly) {
                    try {
                        return [datetime]::Parse($expr).Date
                    } catch {}
                } else {
                    try { return [datetimeoffset]::Parse($expr).UtcDateTime } catch {}
                    try { return [datetime]::Parse($expr).ToUniversalTime() } catch {}
                }

                return [datetime]::Parse($expr)
            }

            $dateOnlyColumns = @('orderDate', 'exDelDate')
            $datetimeColumns = @('date', 'shippedDate', 'exArrDate', 'acArrDate', 'estArrTime', 'actArrTime')

            foreach ($record in $records) {
                $paramNames = $columns | ForEach-Object { "@$_" }
                $paramList = $paramNames -join ', '

                $insertCmd = $connection.CreateCommand()
                $insertCmd.CommandText = "INSERT INTO [$tableName] ($colsSql) VALUES ($paramList)"

                foreach ($col in $columns) {
                    $value = $record.$col
                    if ($null -eq $value -or $value -eq '') {
                        $insertCmd.Parameters.AddWithValue("@$col", [DBNull]::Value) | Out-Null
                    } elseif ($dateOnlyColumns -contains $col) {
                        $parsed = Convert-DateField $value -isDateOnly $true
                        if ($null -eq $parsed) {
                            $insertCmd.Parameters.AddWithValue("@$col", [DBNull]::Value) | Out-Null
                        } else {
                            $insertCmd.Parameters.AddWithValue("@$col", $parsed) | Out-Null
                        }
                    } elseif ($datetimeColumns -contains $col) {
                        $parsed = Convert-DateField $value -isDateOnly $false
                        if ($null -eq $parsed) {
                            $insertCmd.Parameters.AddWithValue("@$col", [DBNull]::Value) | Out-Null
                        } else {
                            $insertCmd.Parameters.AddWithValue("@$col", $parsed) | Out-Null
                        }
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
if ($BackupPath) {
    if (-not (Test-Path -LiteralPath $BackupPath)) {
        Throw "Backup file not found: $BackupPath"
    }
    $resolved = (Resolve-Path -LiteralPath $BackupPath).Path
    Restore-BackupFromCsv -BackupPath $resolved
} else {
    $backupFilePath = Read-BackupFileName
    Restore-BackupFromCsv -BackupPath $backupFilePath
}

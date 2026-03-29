# Run q1..q7 SQL queries and export to query_result (one CSV per result set).
# Multiple SELECT batches become qn_1.csv, qn_2.csv, ...; a single result set stays qn.csv.
$ErrorActionPreference = 'Stop'

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$queriesDir = Join-Path $baseDir 'SQL_files\queries'
$outDir = Join-Path $queriesDir 'query_result'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$server = '<HOST>'
$database = '<DATABASE>'
$user = '<USERNAME>'
$password = '<PASSWORD>'

function Export-SqlToCsvFiles {
    param (
        [string]$ConnectionString,
        [string]$SqlText,
        [string]$OutDir,
        [string]$BaseName
    )

    Add-Type -AssemblyName System.Data
    $connection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $SqlText

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('sqlcsv_' + [System.Guid]::NewGuid().ToString('N'))
    [void][System.IO.Directory]::CreateDirectory($tempDir)
    $partPaths = [System.Collections.Generic.List[string]]::new()

    $reader = $null
    try {
        $connection.Open()
        $reader = $command.ExecuteReader()

        while ($true) {
            if ($reader.FieldCount -gt 0) {
                $partPath = Join-Path $tempDir ('p{0}.csv' -f $partPaths.Count)

                $columns = @()
                for ($j = 0; $j -lt $reader.FieldCount; $j++) {
                    $columns += $reader.GetName($j)
                }

                $lines = [System.Collections.Generic.List[string]]::new()
                [void]$lines.Add(($columns -join ','))

                while ($reader.Read()) {
                    $rowValues = @()
                    for ($j = 0; $j -lt $reader.FieldCount; $j++) {
                        $value = $reader.GetValue($j)
                        if ($null -eq $value) { $rowValues += '' ; continue }
                        $str = [string]$value
                        if ($str -match '[,"\r\n]') {
                            $str = '"' + ($str -replace '"', '""') + '"'
                        }
                        $rowValues += $str
                    }
                    [void]$lines.Add(($rowValues -join ','))
                }

                Set-Content -Path $partPath -Value $lines -Encoding UTF8
                [void]$partPaths.Add($partPath)
            }

            if (-not $reader.NextResult()) { break }
        }
    } finally {
        if ($null -ne $reader) {
            try { $reader.Close() } catch { }
        }
        try { $connection.Close() } catch { }
    }

    try {
        $root = Join-Path $OutDir $BaseName
        if ($partPaths.Count -eq 0) {
            Set-Content -Path "$root.csv" -Value '' -Encoding UTF8
            Write-Host "[OK] Created $root.csv (empty: no column result sets)"
            return
        }

        if ($partPaths.Count -eq 1) {
            Move-Item -LiteralPath $partPaths[0] -Destination "$root.csv" -Force
            Write-Host "[OK] Created $root.csv"
            return
        }

        for ($k = 0; $k -lt $partPaths.Count; $k++) {
            $dest = '{0}_{1}.csv' -f $root, ($k + 1)
            Move-Item -LiteralPath $partPaths[$k] -Destination $dest -Force
            Write-Host "[OK] Created $dest"
        }
        Write-Host "[INFO] $($partPaths.Count) result sets for $BaseName"
    } finally {
        if (Test-Path -LiteralPath $tempDir) {
            try { Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue } catch { }
        }
    }
}

$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;Encrypt=False;TrustServerCertificate=True;"

for ($i = 1; $i -le 7; $i++) {
    $sqlFile = Join-Path $queriesDir "q${i}.sql"
    $baseName = "q$i"

    if (-not (Test-Path $sqlFile)) {
        Write-Warning "SQL file not found: $sqlFile, skipping"
        continue
    }

    Remove-Item -LiteralPath (Join-Path $outDir "$baseName.csv") -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $outDir "${baseName}_*.csv") -ErrorAction SilentlyContinue

    Write-Host "[INFO] Running $baseName -> $outDir\${baseName}.csv (or ${baseName}_N.csv if multiple result sets)"
    $sqlTextRaw = Get-Content -Path $sqlFile -Raw
    $sqlText = $sqlTextRaw -replace '(?mi)^\s*USE\s+\S+\s*;?', ''
    $sqlText = $sqlText -replace '(?mi)^\s*GO\s*$', ''

    Export-SqlToCsvFiles -ConnectionString $connectionString -SqlText $sqlText -OutDir $outDir -BaseName $baseName
}

Write-Host "[INFO] Exporting ALL table data to ALL.csv..."
if (Get-Command node -ErrorAction SilentlyContinue) {
    $exportProcess = Start-Process -FilePath node -ArgumentList 'script\export_all.js' -NoNewWindow -PassThru -Wait
    if ($exportProcess.ExitCode -ne 0) {
        Write-Warning "Warning: export_all.js failed with exit code $($exportProcess.ExitCode)."
    } else {
        Write-Host "[OK] ALL.csv generated."

      # Backup ALL.csv with timestamp
      $backupDir = Join-Path $baseDir 'backups'
      if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
      $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
      $backupPath = Join-Path $backupDir "backup-$timestamp.csv"
      Copy-Item -Path (Join-Path $baseDir 'ALL.csv') -Destination $backupPath -Force
      Write-Host "[OK] ALL.csv backed up to $backupPath"
    }
} else {
    Write-Warning "Node.js not found; cannot run export_all.js. Skipping ALL.csv generation."
}

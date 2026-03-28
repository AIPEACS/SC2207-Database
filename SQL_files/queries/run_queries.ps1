# Run q1..q7 SQL queries with sqlcmd and export to query_result qn.csv
$ErrorActionPreference = 'Stop'

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDir = Join-Path $baseDir 'query_result'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$server = '<HOST>'
$database = '<DATABASE>'
$user = '<USERNAME>'
$password = '<PASSWORD>'

function Export-QueryToCsv {
    param (
        [string]$ConnectionString,
        [string]$SqlText,
        [string]$OutPath
    )

    Add-Type -AssemblyName System.Data
    $connection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $SqlText

    try {
        $connection.Open()
        $reader = $command.ExecuteReader()

        if (-not $reader.HasRows) {
            Set-Content -Path $OutPath -Value '' -Encoding UTF8
            return
        }

        $columns = @()
        for ($j = 0; $j -lt $reader.FieldCount; $j++) {
            $columns += $reader.GetName($j)
        }

        $lines = @()
        $lines += ($columns -join ',')

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
            $lines += ($rowValues -join ',')
        }

        $reader.Close()
        Set-Content -Path $OutPath -Value $lines -Encoding UTF8
    } finally {
        if ($reader) { $reader.Close() }
        $connection.Close()
    }
}

$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;Encrypt=False;TrustServerCertificate=True;"

for ($i = 1; $i -le 7; $i++) {
    $sqlFile = Join-Path $baseDir "q${i}.sql"
    $outFile = Join-Path $outDir "q${i}.csv"

    if (-not (Test-Path $sqlFile)) {
        Write-Warning "SQL file not found: $sqlFile, skipping"
        continue
    }

    Write-Host "[INFO] Running q$i -> $outFile"
    $sqlText = Get-Content -Path $sqlFile -Raw
    Export-QueryToCsv -ConnectionString $connectionString -SqlText $sqlText -OutPath $outFile
    Write-Host "[OK] Created $outFile"
}

Write-Host "[SUCCESS] q1..q7 queries exported to $outDir"

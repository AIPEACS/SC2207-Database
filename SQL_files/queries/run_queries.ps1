# Run q1..q7 SQL queries with sqlcmd and export to query_result qn.csv
$ErrorActionPreference = 'Stop'

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDir = Join-Path $baseDir 'query_result'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$server = '<HOST>'
$database = '<DATABASE>'
$user = '<USERNAME>'
$password = '<PASSWORD>'

for ($i = 1; $i -le 7; $i++) {
    $sqlFile = Join-Path $baseDir "q${i}.sql"
    $outFile = Join-Path $outDir "q${i}.csv"

    if (-not (Test-Path $sqlFile)) {
        Write-Warning "SQL file not found: $sqlFile, skipping"
        continue
    }

    Write-Host "[INFO] Running q$i -> $outFile"
    sqlcmd -S $server -U $user -P $password -d $database -i $sqlFile -s ',' -W -o $outFile
    Write-Host "[OK] Created $outFile"
}

Write-Host "[SUCCESS] q1..q7 queries exported to $outDir"

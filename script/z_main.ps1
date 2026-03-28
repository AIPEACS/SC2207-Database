# Run index.js seeding, then q6_specific.js script.
# Usage: .\run_index_and_q6.ps1

$ErrorActionPreference = 'Stop'

Push-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "[INFO] Running index.js seed phase..."

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed or not in PATH. Install Node.js and rerun."
    Exit 1
}

if (-not (Test-Path "node_modules")) {
    Write-Host "[INFO] node_modules not found; running npm install..."
    npm install
}

# Full pipeline: run index.js for all model tables, then run q6_specific.
# Ensures data is present for all query types (q1..q7), not only q6.

$seedSteps = @(
    @{ table = 'Client'; count = 10 },
    @{ table = 'Product'; count = 10 },
    @{ table = 'Warehouse'; count = 10 },
    @{ table = 'Zone'; count = 5 },
    @{ table = 'Supplier'; count = 10 },
    @{ table = 'Staff'; count = 10 },
    @{ table = 'Vehicle'; count = 10 },
    @{ table = 'Employee'; count = 10 },
    @{ table = 'Driver'; count = 10 },
    @{ table = 'PurchaseOrder'; count = 10 },
    @{ table = 'Shipment'; count = 10 },
    @{ table = 'Item'; count = 15 },
    @{ table = 'OrderItem'; count = 15 },
    @{ table = 'ShipItem'; count = 15 },
    @{ table = 'Shipment_Supplier'; count = 15 },
    @{ table = 'Shipment_Warehouse'; count = 15 },
    @{ table = 'Supply'; count = 15 },
    @{ table = 'Inventory'; count = 20 },
    @{ table = 'InventoryMovement'; count = 20 },
    @{ table = 'Route'; count = 10 },
    @{ table = 'Delivery'; count = 10 },
    @{ table = 'ProductHandling'; count = 15 }
)

foreach ($step in $seedSteps) {
    $process = Start-Process -FilePath node -ArgumentList "index.js $($step.table) $($step.count)" -NoNewWindow -PassThru -Wait
    if ($process.ExitCode -ne 0) {
        Write-Warning "[WARN] $($step.table) seed failed, continuing (exit $($process.ExitCode))."
        continue
    }
    Write-Host "[OK] $($step.table) seeded ($($step.count))."
}

Write-Host "[INFO] Running q6_specific.js to ensure q6-valid supplier state..."
$process = Start-Process -FilePath node -ArgumentList 'q6_specific.js' -NoNewWindow -PassThru -Wait
if ($process.ExitCode -ne 0) {
    Write-Error "q6_specific.js failed with exit code $($process.ExitCode)."
    Pop-Location
    Exit $process.ExitCode
}

Write-Host "[INFO] Exporting ALL table data to ALL.csv..."
$process = Start-Process -FilePath node -ArgumentList 'export_all.js' -NoNewWindow -PassThru -Wait
if ($process.ExitCode -ne 0) {
    Write-Error "export_all.js failed with exit code $($process.ExitCode)."
    Pop-Location
    Exit $process.ExitCode
}

Write-Host "[SUCCESS] index + q6 + export pipeline completed."
Pop-Location

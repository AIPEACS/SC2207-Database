#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "[INFO] Running index.js seed phase..."

if ! command -v node >/dev/null 2>&1; then
  echo "[ERROR] Node.js is not installed or not in PATH. Install Node.js and rerun." >&2
  exit 1
fi

if [ ! -d "node_modules" ]; then
  echo "[INFO] node_modules not found; running npm install..."
  npm install
fi

seedSteps=(
  "Client:10"
  "Product:10"
  "Warehouse:10"
  "Zone:5"
  "Supplier:10"
  "Staff:10"
  "Vehicle:10"
  "Employee:10"
  "Driver:10"
  "PurchaseOrder:10"
  "Shipment:10"
  "Item:15"
  "OrderItem:15"
  "ShipItem:15"
  "Shipment_Supplier:15"
  "Shipment_Warehouse:15"
  "Supply:15"
  "Inventory:20"
  "InventoryMovement:20"
  "Route:10"
  "Delivery:10"
  "ProductHandling:15"
)

for step in "${seedSteps[@]}"; do
  IFS=':' read -r table count <<< "$step"
  echo "[INFO] Seeding $table ($count)"
  if ! node index.js "$table" "$count"; then
    echo "[WARN] $table seed failed, continuing." >&2
    continue
  fi
  echo "[OK] $table seeded ($count)."
done

echo "[INFO] Running q6_specific.js to ensure q6-valid supplier state..."
node q6_specific.js

echo "[INFO] Exporting ALL table data to ALL.csv..."
node export_all.js

echo "[SUCCESS] index + q6 + export pipeline completed."

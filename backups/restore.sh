#!/usr/bin/env bash
# Restore database from a backup-*.csv in this directory (same behavior as restore.ps1).
# Requires PowerShell: pwsh (preferred) or powershell.exe on Windows.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Backup directory not found: $BACKUP_DIR"
  exit 1
fi

echo "Available backup files:"
shopt -s nullglob
listed=0
for f in "$BACKUP_DIR"/backup-*.csv; do
  echo "  $(basename "$f")"
  listed=1
done
shopt -u nullglob
if [ "$listed" -eq 0 ]; then
  echo "  (none)"
fi

read -rp "Enter backup filename (e.g. backup-20260329-123456.csv): " backup_file
full_path="$BACKUP_DIR/$backup_file"
if [ ! -f "$full_path" ]; then
  echo "File not found: $full_path"
  exit 1
fi

run_restore() {
  local path="$1"
  if command -v pwsh >/dev/null 2>&1; then
    exec pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/restore.ps1" -BackupPath "$path"
  fi
  if command -v powershell.exe >/dev/null 2>&1; then
    exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/restore.ps1" -BackupPath "$path"
  fi
  echo "[ERROR] PowerShell not found (install pwsh, or use powershell.exe on Windows)."
  echo "        You can also run:  pwsh -File backups/restore.ps1 -BackupPath \"$path\""
  exit 1
}

run_restore "$full_path"

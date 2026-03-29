#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)/.."
BACKUP_DIR="$BASE_DIR/backups"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Backup directory not found: $BACKUP_DIR"
  exit 1
fi

echo "Available backup files:"
ls "$BACKUP_DIR"/backup-*.csv 2>/dev/null || true

tty=/dev/tty
if [ ! -e "$tty" ]; then
  tty=$(tty)
fi

read -rp "Enter backup filename (e.g. backup-20260329-123456.csv): " backup_file
full_path="$BACKUP_DIR/$backup_file"
if [ ! -f "$full_path" ]; then
  echo "File not found: $full_path"
  exit 1
fi

# parse file with sections like '--- Table (N rows) ---'
current_table=""
tmpfile=$(mktemp)
mapfile -t lines < "$full_path"

# prepare array records for each section
declare -A file_content

for line in "${lines[@]}"; do
  if [[ $line =~ ^---[[:space:]]*([^[:space:]].*?)[[:space:]]*(\\([0-9]+[[:space:]]rows\\))?[[:space:]]*---$ ]]; then
    current_table="${BASH_REMATCH[1]}"
    file_content["$current_table"]=""
  elif [[ -n $current_table ]]; then
    file_content["$current_table"]+="$line\n"
  fi
done

if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "${BASE_DIR}/backups/restore.ps1"
else
  echo "PowerShell not found; cannot run backup restore."
  exit 1
fi

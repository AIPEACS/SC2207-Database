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

# run restore via psql? we have mssql; use sqlcmd fallback not available.
# Use node to connect via sequelize and load this file content to DB if node installed.
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found; cannot perform restore from Bash. Install Node.js or use restore.ps1."
  exit 1
fi

node - <<'NODE'
const fs = require('fs');
const path = require('path');
const { sequelize } = require(path.resolve(__dirname, '..', 'script', 'init.js'));

(async () => {
  await sequelize.authenticate();

  const sections = [];
  const inputFile = process.argv[2];
  const text = fs.readFileSync(inputFile, 'utf8');

  const regex = /^---\s*([^\(]+?)(?:\s*\(\d+\s*rows\))?\s*---$/gm;
  let m, current = null, lines = [], pos = 0;

  while ((m = regex.exec(text)) !== null) {
    if (current) {
      sections.push({table: current, rows: lines});
    }
    current = m[1].trim();
    const start = regex.lastIndex;
    const next = text.slice(start).search(/^---\s*[^\(]+?\s*(?:\(\d+\s*rows\))?\s*---$/m);
    if (next === -1) {
      lines = text.slice(start).split(/\r?\n/).filter(l => l.length);
      break;
    } else {
      lines = text.slice(start, start + next).split(/\r?\n/).filter(l => l.length);
      regex.lastIndex = start + next;
    }
  }
  if (current && sections.length === 0) sections.push({table: current, rows: lines});

  for (const section of sections) {
    const tbl = section.table;
    const rows = section.rows;
    if (rows.length === 0) continue;

    const csv = rows.join('\n');
    const records = require('csv-parse/lib/sync')(csv, { columns: true, skip_empty_lines: true });

    if (!records.length) continue;

    console.log('Restoring', tbl, records.length, 'rows');
    await sequelize.query(`DELETE FROM [${tbl}]`);
    const columns = Object.keys(records[0]);
    const placeholders = columns.map((_, i) => '@p' + i).join(', ');

    for (const r of records) {
      const values = columns.map(c => (r[c] === '' ? null : r[c]));
      const params = values.map((v, i) => `@p${i}=${typeof v === 'string' ? `'${v.replace(/'/g, "''")}'` : v}`);
      const sql = `INSERT INTO [${tbl}] (${columns.join(',')}) VALUES (${columns.map(c=> '?').join(',')})`;
      await sequelize.query(sql, { replacements: values });
    }
  }

  await sequelize.close();
  console.log('Restore complete');
})();
NODE
 "$full_path"

echo "Restore from $full_path completed."

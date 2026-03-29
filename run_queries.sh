#!/usr/bin/env bash
set -euo pipefail

# Run q1..q7 and export one CSV per result set (qn.csv or qn_1.csv, qn_2.csv, ...).
# Uses Node + tedious (same stack as script/export_all.js) so multiple SELECT batches are split correctly.

DIR="$(cd "$(dirname "$0")" && pwd)"
QUERY_DIR="$DIR/SQL_files/queries"
OUTDIR="$QUERY_DIR/query_result"
mkdir -p "$OUTDIR"

SERVER="<HOST>"
DATABASE="<DATABASE>"
USER="<USERNAME>"
PASSWORD="<PASSWORD>"

if ! command -v node >/dev/null 2>&1; then
  echo "[ERROR] Node.js is required to export q1..q7 (multiple result sets per file need a TDS client)."
  echo "        Install Node and run npm install, or use run_queries.ps1 on Windows."
  exit 1
fi

export SQL_SERVER="$SERVER"
export SQL_DATABASE="$DATABASE"
export SQL_USER="$USER"
export SQL_PASSWORD="$PASSWORD"

for i in {1..7}; do
  sqlfile="$QUERY_DIR/q${i}.sql"
  base="q${i}"

  if [ ! -f "$sqlfile" ]; then
    echo "[WARN] $sqlfile not found, skipping"
    continue
  fi

  rm -f "$OUTDIR/${base}.csv"
  shopt -s nullglob
  rm -f "$OUTDIR/${base}_"*.csv
  shopt -u nullglob

  echo "[INFO] Running $base -> $OUTDIR/${base}.csv (or ${base}_N.csv if multiple result sets)"
  (cd "$DIR" && node script/export_sql_to_csv.js "$sqlfile" "$OUTDIR" "$base")

  if [ -f "$OUTDIR/${base}.csv" ]; then
    echo "[OK] Created $OUTDIR/${base}.csv"
  fi
  shopt -s nullglob
  for f in "$OUTDIR/${base}_"*.csv; do
    echo "[OK] Created $f"
  done
  shopt -u nullglob
done

echo "[INFO] Exporting ALL table data to ALL.csv..."
(cd "$DIR" && node script/export_all.js)
echo "[OK] ALL.csv generated."

echo "[SUCCESS] q1..q7 queries exported to $OUTDIR"

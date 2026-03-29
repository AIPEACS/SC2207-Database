#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
QUERY_DIR="$DIR/SQL_files/queries"
OUTDIR="$QUERY_DIR/query_result"
mkdir -p "$OUTDIR"

SERVER="<HOST>"
DATABASE="<DATABASE>"
USER="<USERNAME>"
PASSWORD="<PASSWORD>"

for i in {1..7}; do
  sqlfile="$QUERY_DIR/q${i}.sql"
  outfile="$OUTDIR/q${i}.csv"

  if [ ! -f "$sqlfile" ]; then
    echo "[WARN] $sqlfile not found, skipping"
    continue
  fi

  echo "[INFO] Running q$i -> $outfile"
  sqlcmd -S "$SERVER" -U "$USER" -P "$PASSWORD" -d "$DATABASE" -i "$sqlfile" -s"," -W -o "$outfile"
  echo "[OK] Created $outfile"
done

if command -v node >/dev/null 2>&1; then
  echo "[INFO] Exporting ALL table data to ALL.csv..."
  node script/export_all.js
  echo "[OK] ALL.csv generated."
else
  echo "[WARN] Node.js not found; cannot run script/export_all.js. Skipping ALL.csv generation."
fi

echo "[SUCCESS] q1..q7 queries exported to $OUTDIR"


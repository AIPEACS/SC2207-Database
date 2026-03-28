#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$DIR/query_result"
mkdir -p "$OUTDIR"

SERVER="<HOST>"
DATABASE="<DATABASE>"
USER="<USERNAME>"
PASSWORD="<PASSWORD>"

for i in {1..7}; do
  sqlfile="$DIR/q${i}.sql"
  outfile="$OUTDIR/q${i}.csv"

  if [ ! -f "$sqlfile" ]; then
    echo "[WARN] $sqlfile not found, skipping"
    continue
  fi

  echo "[INFO] Running q$i -> $outfile"
  sqlcmd -S "$SERVER" -U "$USER" -P "$PASSWORD" -d "$DATABASE" -i "$sqlfile" -s"," -W -o "$outfile"
  echo "[OK] Created $outfile"
done

echo "[SUCCESS] q1..q7 queries exported to $OUTDIR"
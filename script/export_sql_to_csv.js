/**
 * Run a .sql file against SQL Server and write one CSV per result set.
 * Usage: node script/export_sql_to_csv.js <sqlFile> <outDir> <baseName>
 * Env: SQL_SERVER, SQL_DATABASE, SQL_USER, SQL_PASSWORD (optional; defaults match repo scripts)
 */
const fs = require('fs');
const path = require('path');
const { Connection, Request } = require('tedious');

function quoteCsv(value) {
  if (value === null || value === undefined) return '';
  const text = String(value);
  if (/[",\r\n]/.test(text)) {
    return '"' + text.replace(/"/g, '""') + '"';
  }
  return text;
}

function stripUseAndGo(sql) {
  return sql
    .replace(/^\s*USE\s+\S+\s*;?/gim, '')
    .replace(/^\s*GO\s*$/gim, '');
}

function executeRecordsets(sqlText) {
  const server = process.env.SQL_SERVER || '<HOST>';
  const database = process.env.SQL_DATABASE || '<DATABASE>';
  const userName = process.env.SQL_USER || '<USERNAME>';
  const password = process.env.SQL_PASSWORD || '<PASSWORD>';

  return new Promise((resolve, reject) => {
    const recordsets = [];
    let current = null;

    const connection = new Connection({
      server,
      authentication: {
        type: 'default',
        options: { userName, password },
      },
      options: {
        database,
        encrypt: false,
        trustServerCertificate: true,
        enableArithAbort: true,
        useColumnNames: false,
      },
    });

    connection.on('connect', (err) => {
      if (err) {
        connection.close();
        return reject(err);
      }

      const request = new Request(sqlText, (reqErr) => {
        if (current) {
          recordsets.push(current);
          current = null;
        }
        connection.close();
        if (reqErr) return reject(reqErr);
        resolve(recordsets);
      });

      request.on('columnMetadata', (columns) => {
        if (current) {
          recordsets.push(current);
        }
        const colNames = [];
        for (let i = 0; i < columns.length; i++) {
          colNames.push(columns[i].colName);
        }
        current = { columns: colNames, rows: [] };
      });

      request.on('row', (columns) => {
        const row = [];
        for (let i = 0; i < columns.length; i++) {
          row.push(columns[i].value);
        }
        current.rows.push(row);
      });

      connection.execSql(request);
    });

    connection.on('error', (e) => reject(e));
    connection.connect();
  });
}

function writeCsv(filePath, { columns, rows }) {
  const lines = [columns.map(quoteCsv).join(',')];
  for (const row of rows) {
    lines.push(row.map(quoteCsv).join(','));
  }
  fs.writeFileSync(filePath, lines.join('\n'), 'utf8');
}

async function main() {
  const sqlPath = process.argv[2];
  const outDir = process.argv[3];
  const baseName = process.argv[4];

  if (!sqlPath || !outDir || !baseName) {
    console.error('Usage: node script/export_sql_to_csv.js <sqlFile> <outDir> <baseName>');
    process.exit(1);
  }

  const sqlText = stripUseAndGo(fs.readFileSync(sqlPath, 'utf8'));
  const root = path.join(outDir, baseName);

  fs.mkdirSync(outDir, { recursive: true });

  try {
    fs.unlinkSync(`${root}.csv`);
  } catch (_) {
    /* ignore */
  }
  for (const name of fs.readdirSync(outDir)) {
    if (name.startsWith(`${baseName}_`) && name.endsWith('.csv')) {
      try {
        fs.unlinkSync(path.join(outDir, name));
      } catch (_) {
        /* ignore */
      }
    }
  }

  try {
    const recordsets = await executeRecordsets(sqlText);
    const withColumns = recordsets.filter((rs) => rs.columns.length > 0);
    if (withColumns.length === 0) {
      fs.writeFileSync(`${root}.csv`, '', 'utf8');
      return;
    }
    if (withColumns.length === 1) {
      writeCsv(`${root}.csv`, withColumns[0]);
      return;
    }
    withColumns.forEach((rs, idx) => {
      writeCsv(`${root}_${idx + 1}.csv`, rs);
    });
  } catch (e) {
    console.error(e.message || e);
    process.exit(1);
  }
}

main();

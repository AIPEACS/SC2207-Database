const fs = require('fs');
const path = require('path');
const { sequelize } = require('./init');

const tables = [
  'Client','Delivery','Driver','Employee','Inventory','InventoryMovement','Item','OrderItem','Product','ProductHandling','PurchaseOrder','Route','ShipItem','Shipment','Shipment_Supplier','Shipment_Warehouse','Staff','Supplier','Supply','Vehicle','Warehouse','Zone'
];

function quoteCsv(value) {
  if (value === null || value === undefined) return '';
  const text = String(value);
  if (/[",\r\n]/.test(text)) {
    return '"' + text.replace(/"/g, '""') + '"';
  }
  return text;
}

(async function() {
  await sequelize.authenticate();

  const root = path.resolve(__dirname, '..');
  const outFile = path.join(root, 'ALL.csv');
  fs.writeFileSync(outFile, '');

  for (const table of tables) {
    const [rows] = await sequelize.query(`SELECT * FROM ${table}`);
    if (!rows.length) {
      fs.appendFileSync(outFile, `--- ${table} (0 rows) ---\n\n`);
      continue;
    }

    const columns = Object.keys(rows[0]);
    fs.appendFileSync(outFile, `--- ${table} (${rows.length} rows) ---\n`);
    fs.appendFileSync(outFile, columns.map(quoteCsv).join(',') + '\n');

    for (const row of rows) {
      const line = columns.map(c => quoteCsv(row[c])).join(',');
      fs.appendFileSync(outFile, line + '\n');
    }
    fs.appendFileSync(outFile, '\n');
  }

  console.log(`Created ALL.csv in ${root}`);
  await sequelize.close();
})();

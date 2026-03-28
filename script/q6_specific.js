const { sequelize } = require('./init');

const Q6_SQL = `
SELECT Supplier.supplierID AS supplierID
FROM Supplier
WHERE NOT EXISTS (
    SELECT sr.supplierID
    FROM Supplier sr
    JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
    JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
    JOIN Warehouse w ON w.warehouseID = shw.warehouseID
    WHERE w.address = 'Thailand'
        AND Supplier.supplierID = sr.supplierID
)
AND NOT EXISTS (
    SELECT w.warehouseID
    FROM Warehouse w
    WHERE w.address = 'Singapore'
        AND NOT EXISTS (
            SELECT sr.supplierID
            FROM Supplier sr
            JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
            JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
            JOIN Warehouse w1 ON w1.warehouseID = shw.warehouseID
            WHERE Supplier.supplierID = sr.supplierID
                AND w1.warehouseID = w.warehouseID
        )
)
`;

const r = (min, max) => Math.floor(Math.random() * (max - min + 1) + min);

const supplierNames = [
    'Orchid Logistics Pte Ltd',
    'Marina Bay Supply Co',
    'Lion City Distribution'
];

const warehouseSeed = [
    { address: 'Singapore', size: 12000, temperature: 'ambient', security: 'high' },
    { address: 'United States of America', size: 11000, temperature: 'ambient', security: 'high' },
    { address: 'Thailand', size: 15000, temperature: 'ambient', security: 'low' },
];

async function ensureWarehouseData() {
    const [warehouses] = await sequelize.query("SELECT warehouseID FROM Warehouse WHERE address = 'Singapore'");

    if (!warehouses.length) {
        console.log('No Singapore warehouses found, inserting seed warehouses...');
        for (const w of warehouseSeed) {
            await sequelize.query(
                "INSERT INTO Warehouse (address, size, temperature, security) VALUES (?, ?, ?, ?)",
                { replacements: [w.address, w.size, w.temperature, w.security] }
            );
        }
    }

    const [updatedWarehouses] = await sequelize.query("SELECT warehouseID FROM Warehouse WHERE address = 'Singapore'");
    return updatedWarehouses.map((w) => w.warehouseID);
}

async function main() {
    await sequelize.authenticate();
    console.log('Connected to DB.');

    const warehouseIds = await ensureWarehouseData();
    if (!warehouseIds.length) {
        throw new Error('Failed to create Singapore warehouses in reset phase.');
    }

    const createdSupplierIds = [];

    for (let i = 0; i < supplierNames.length; i++) {
        const supplierName = supplierNames[i];
        const [supplierInsert] = await sequelize.query(
            "INSERT INTO Supplier (leadTime, paymentTerms, name, country) OUTPUT INSERTED.supplierID VALUES (7, '30 days', ?, 'Singapore')",
            { replacements: [supplierName] }
        );
        const supplierID = supplierInsert[0].supplierID;

        const [poInsert] = await sequelize.query(
            "INSERT INTO PurchaseOrder (orderDate, status) OUTPUT INSERTED.orderID VALUES (GETDATE(), 'fully received')"
        );
        const orderID = poInsert[0].orderID;

        let trackingNumber;
        while (true) {
            trackingNumber = r(100000000, 999999999);
            const [exists] = await sequelize.query(
                'SELECT shipmentID FROM Shipment WHERE trackingNumber = ?',
                { replacements: [trackingNumber] }
            );
            if (!exists.length) break;
        }

        const [shipmentInsert] = await sequelize.query(
            "INSERT INTO Shipment (exArrDate, acArrDate, shippedDate, originalLocation, trackingNumber, orderID) OUTPUT INSERTED.shipmentID VALUES (DATEADD(day, 7, GETDATE()), NULL, GETDATE(), 'Singapore', ?, ?)",
            { replacements: [trackingNumber, orderID] }
        );
        const shipmentID = shipmentInsert[0].shipmentID;

        await sequelize.query(
            'INSERT INTO Shipment_Supplier (shipmentID, supplierID) VALUES (?, ?)',
            { replacements: [shipmentID, supplierID] }
        );

        for (const warehouseID of warehouseIds) {
            await sequelize.query(
                'IF NOT EXISTS (SELECT 1 FROM Shipment_Warehouse WHERE shipmentID = ? AND warehouseID = ?) INSERT INTO Shipment_Warehouse (shipmentID, warehouseID) VALUES (?, ?)',
                { replacements: [shipmentID, warehouseID, shipmentID, warehouseID] }
            );
        }

        createdSupplierIds.push(supplierID);
        console.log(`Created supplier ${supplierID} (${supplierName}) with shipment ${shipmentID}`);
    }

    console.log('Created suppliers:', createdSupplierIds);

    const [q6Rows] = await sequelize.query(Q6_SQL);
    if (!q6Rows.length) console.log('Q6 query returned no rows.');
    else {
        console.log('Q6 query supplierIDs:');
        q6Rows.forEach((row) => console.log(row.supplierID));
    }
}

main()
    .catch((err) => {
        console.error('Error:', err.message || err);
        process.exit(1);
    })
    .finally(() => sequelize.close());

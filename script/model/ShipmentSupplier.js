const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { assignUniqueFK, assignFK } = require("../insert");

const { Shipment } = require("./Shipment");
const { Supplier } = require("./Supplier");

const Shipment_Supplier = sequelize.define('Shipment_Supplier', {
    shipmentID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Shipment, 
            key: 'shipmentID', 
        }
    },
    supplierID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Supplier, 
            key: 'supplierID', 
        }
    },
}, {
    createdAt: false,
    updatedAt: false,
});

function generateRecord(){
    return {}
}

Shipment_Supplier.generateRecord = generateRecord;
Shipment_Supplier.insertRecords = async (records) => {
    const shipments = await Shipment.findAll();
    const suppliers = await Supplier.findAll();
    if (!shipments.length || !suppliers.length) {
        throw new Error('No shipments or suppliers available for Shipment_Supplier creation');
    }

    const existing = new Set();
    const allCurrent = await Shipment_Supplier.findAll();
    allCurrent.forEach(r => existing.add(`${r.shipmentID}|${r.supplierID}`));

    for (let i = 0; i < records.length; i++) {
        let attempts = 0;
        while (attempts < 10) {
            const shipment = shipments[Math.floor(Math.random() * shipments.length)];
            const supplier = suppliers[Math.floor(Math.random() * suppliers.length)];
            const key = `${shipment.shipmentID}|${supplier.supplierID}`;
            if (!existing.has(key)) {
                existing.add(key);
                records[i].shipmentID = shipment.shipmentID;
                records[i].supplierID = supplier.supplierID;
                break;
            }
            attempts++;
        }
        if (attempts >= 10) {
            records[i].shipmentID = shipments[Math.floor(Math.random() * shipments.length)].shipmentID;
            records[i].supplierID = suppliers[Math.floor(Math.random() * suppliers.length)].supplierID;
        }
    }

    await Shipment_Supplier.bulkCreate(records).catch(e => {
        console.warn('[WARN] Shipment_Supplier bulkCreate duplicate skipped');
    });
}

module.exports = {
    Shipment_Supplier
};
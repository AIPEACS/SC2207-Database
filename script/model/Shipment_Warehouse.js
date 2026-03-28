const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { assignUniqueFK, assignFK } = require("../insert");

const { Shipment } = require("./Shipment");
const { Warehouse } = require("./Warehouse");

const Shipment_Warehouse = sequelize.define('Shipment_Warehouse', {
    shipmentID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Shipment, 
            key: 'shipmentID', 
        }
    },
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Warehouse, 
            key: 'warehouseID', 
        }
    },
}, {
    createdAt: false,
    updatedAt: false,
});

function generateRecord(){
    return {}
}

Shipment_Warehouse.generateRecord = generateRecord;
Shipment_Warehouse.insertRecords = async (records) => {
    const shipments = await Shipment.findAll();
    const warehouses = await Warehouse.findAll();
    if (!shipments.length || !warehouses.length) {
        throw new Error('No shipments or warehouses available for Shipment_Warehouse creation');
    }

    const existing = new Set();
    const allCurrent = await Shipment_Warehouse.findAll();
    allCurrent.forEach(r => existing.add(`${r.shipmentID}|${r.warehouseID}`));

    for (let i = 0; i < records.length; i++) {
        let attempts = 0;
        while (attempts < 10) {
            const shipment = shipments[Math.floor(Math.random() * shipments.length)];
            const warehouse = warehouses[Math.floor(Math.random() * warehouses.length)];
            const key = `${shipment.shipmentID}|${warehouse.warehouseID}`;
            if (!existing.has(key)) {
                existing.add(key);
                records[i].shipmentID = shipment.shipmentID;
                records[i].warehouseID = warehouse.warehouseID;
                break;
            }
            attempts++;
        }
        if (attempts >= 10) {
            records[i].shipmentID = shipments[Math.floor(Math.random() * shipments.length)].shipmentID;
            records[i].warehouseID = warehouses[Math.floor(Math.random() * warehouses.length)].warehouseID;
        }
    }

    await Shipment_Warehouse.bulkCreate(records).catch(e => {
        console.warn('[WARN] Shipment_Warehouse bulkCreate duplicate skipped');
    });
}

module.exports = {
    Shipment_Warehouse
};
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
    await assignUniqueFK("Shipment", "Shipment_Warehouse", records, "shipmentID", 0);
    await assignFK(Warehouse, records);
    await Shipment_Warehouse.bulkCreate(records);
}

module.exports = {
    Shipment_Warehouse
};
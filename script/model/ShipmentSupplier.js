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
    await assignUniqueFK("Shipment", "Shipment_Supplier", records, "shipmentID", 0);
    await assignFK(Supplier, records);
    await Shipment_Supplier.bulkCreate(records);
}

module.exports = {
    Shipment_Supplier
};
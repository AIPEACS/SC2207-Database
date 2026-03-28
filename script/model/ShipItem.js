const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { Item } = require("./Item");
const { Shipment } = require("./Shipment");
const { OrderItem } = require("./OrderItem");
const { assignQueryResult } = require("../insert");

const ShipItem = sequelize.define('ShipItem', {
    shipmentID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Shipment, 
            key: 'shipmentID' 
        }
    },
    "itemSerial#": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Item, 
            key: 'orderID' 
        }
    },
    shippedQty: {
        type: DataTypes.INTEGER,
        allowNull: false,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

Item.hasMany(ShipItem, {foreignKey: "itemSerial#"});
ShipItem.belongsTo(Item, {foreignKey: "itemSerial#"});

Shipment.hasMany(ShipItem, {foreignKey: "shipmentId"});
ShipItem.belongsTo(Shipment, {foreignKey: "shipmentId"});


function generateRecord(){
    return { shippedQty: 1 }
}

ShipItem.generateRecord = generateRecord;
ShipItem.insertRecords = async (items) => {
    await assignQueryResult(items, 
        {
            "itemSerial#": "itemSerial#",
            "shipmentID" : "shipmentID",
            "shippedQty": "orderedQty"
        }, `
        SELECT *
        FROM Shipment S
        INNER JOIN OrderItem O
        ON S.orderID = O.orderID
        WHERE NOT EXISTS (
            SELECT *
            FROM ShipItem SI
            WHERE SI.[itemSerial#] = O.[itemSerial#] AND SI.shipmentID = S.shipmentID
        )`)
    await ShipItem.bulkCreate(items);
}


module.exports = {
    ShipItem
};
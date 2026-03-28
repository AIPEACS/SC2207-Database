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
    const [queryRecords] = await sequelize.query(`
        SELECT S.shipmentID, O.[itemSerial#], O.orderedQty
        FROM Shipment S
        INNER JOIN OrderItem O
        ON S.orderID = O.orderID
        WHERE NOT EXISTS (
            SELECT 1
            FROM ShipItem SI
            WHERE SI.[itemSerial#] = O.[itemSerial#] AND SI.shipmentID = S.shipmentID
        )`);

    if (!queryRecords.length) {
        const orders = await Shipment.findAll();
        const orderItems = await OrderItem.findAll();
        if (!orders.length || !orderItems.length) {
            throw new Error('No Shipment or OrderItem rows exist for ShipItem creation');
        }

        for (let i = 0; i < items.length; i++) {
            const order = orders[Math.floor(Math.random() * orders.length)];
            const oi = orderItems[Math.floor(Math.random() * orderItems.length)];
            items[i]['shipmentID'] = order.shipmentID;
            items[i]['itemSerial#'] = oi['itemSerial#'];
            items[i]['shippedQty'] = oi.orderedQty || 1;
        }
    } else {
        for (let i = 0; i < items.length; i++) {
            const record = queryRecords[i % queryRecords.length];
            items[i]['shipmentID'] = record.shipmentID;
            items[i]['itemSerial#'] = record['itemSerial#'];
            items[i]['shippedQty'] = record.orderedQty || 1;
        }
    }

    try {
        await ShipItem.bulkCreate(items);
    } catch (error) {
        console.warn('[WARN] ShipItem bulkCreate issues (likely duplicate PK) - continuing. ' + (error.message || error));
    }
}

module.exports = {
    ShipItem
};
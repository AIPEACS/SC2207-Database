const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { assignFK, assignQueryResult } = require("../insert");
const { Item } = require("./Item");
const { PurchaseOrder } = require("./PurchaseOrder");

const { randomInt, randomDefaultDate } = require("../util");
const { faker } = require("@faker-js/faker");

const OrderItem = sequelize.define('OrderItem', {
    "itemSerial#": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Item, 
            key: 'itemSerial#' 
        }
    },
    "orderID": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: PurchaseOrder, 
            key: 'orderID' 
        }
    },
    exDelDate: {
        type: DataTypes.DATEONLY,
        allowNull: false,
    },
    unitPrice: {
        type: DataTypes.DECIMAL(38, 2),
        allowNull: false,
    },
    orderedQty: {
        type: DataTypes.INTEGER,
        allowNull: false,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

Item.hasMany(OrderItem, {foreignKey: "itemSerial#"});
OrderItem.belongsTo(Item, {foreignKey: "itemSerial#"});

PurchaseOrder.hasMany(OrderItem, {foreignKey: "orderId"});
OrderItem.belongsTo(PurchaseOrder, {foreignKey: "orderId"});

const qtyRange = [100, 1000];

function generateRecord(){
    return {
        exDelDate: randomDefaultDate({type: "delivery"}),
        unitPrice: faker.commerce.price(),
        orderedQty: randomInt(...qtyRange),
    }
}

OrderItem.generateRecord = generateRecord;
OrderItem.insertRecords = async (items) => {
    await assignQueryResult(items,
        {
            "itemSerial#": "itemSerial#",
            "orderID": "orderID",
        }, `
        SELECT p.orderID, i.[itemSerial#]
        FROM PurchaseOrder p
        CROSS JOIN Item i
        WHERE NOT EXISTS (
            SELECT *
            FROM OrderItem o
            WHERE p.orderID = o.orderID AND i.[itemSerial#] = o.[itemSerial#] 
        )`
    )
    await OrderItem.bulkCreate(items);
}

module.exports = {
    OrderItem
};
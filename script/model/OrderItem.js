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
    const [queryRecords] = await sequelize.query(`
        SELECT p.orderID, i.[itemSerial#]
        FROM PurchaseOrder p
        CROSS JOIN Item i
        WHERE NOT EXISTS (
            SELECT 1
            FROM OrderItem o
            WHERE p.orderID = o.orderID AND i.[itemSerial#] = o.[itemSerial#] 
        )`);

    if (!queryRecords.length) {
        const orders = await PurchaseOrder.findAll();
        const allItems = await Item.findAll();
        if (!orders.length || !allItems.length) {
            throw new Error('No PurchaseOrder or Item rows exist for OrderItem creation');
        }

        for (let i = 0; i < items.length; i++) {
            const order = orders[Math.floor(Math.random() * orders.length)];
            const item = allItems[Math.floor(Math.random() * allItems.length)];
            items[i]['orderID'] = order.orderID;
            items[i]['itemSerial#'] = item['itemSerial#'];
        }
    } else {
        const available = queryRecords;
        for (let i = 0; i < items.length; i++) {
            const record = available[i % available.length];
            items[i]['orderID'] = record.orderID;
            items[i]['itemSerial#'] = record['itemSerial#'];
        }
    }

    try {
        await OrderItem.bulkCreate(items);
    } catch (error) {
        console.warn('[WARN] OrderItem bulkCreate issues (likely duplicate PK) - continuing. ' + (error.message || error));
    }
}

module.exports = {
    OrderItem
};
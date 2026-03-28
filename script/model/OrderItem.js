const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { assignFK, assignQueryResult } = require("../insert");
const { Item } = require("./Item");
const { PurchaseOrder } = require("./PurchaseOrder");

const { randomInt, randomDefaultDate } = require("../util");
const { faker } = require("@faker-js/faker");
const { Inventory } = require("./Inventory");
const { Supplier } = require("./Supplier");

// const OrderItem = sequelize.define('OrderItem', {
//     "itemSerial#": {
//         type: DataTypes.INTEGER,
//         primaryKey: true, 
//         references: {
//             model: Item, 
//             key: 'itemSerial#' 
//         }
//     },
//     "orderID": {
//         type: DataTypes.INTEGER,
//         primaryKey: true, 
//         references: {
//             model: PurchaseOrder, 
//             key: 'orderID' 
//         }
//     },
//     exDelDate: {
//         type: DataTypes.DATEONLY,
//         allowNull: false,
//     },
//     unitPrice: {
//         type: DataTypes.DECIMAL(38, 2),
//         allowNull: false,
//     },
//     orderedQty: {
//         type: DataTypes.INTEGER,
//         allowNull: false,
//     }
// }, {
//     createdAt: false,
//     updatedAt: false,
// });

// Item.hasMany(OrderItem, {foreignKey: "itemSerial#"});
// OrderItem.belongsTo(Item, {foreignKey: "itemSerial#"});

// PurchaseOrder.hasMany(OrderItem, {foreignKey: "orderId"});
// OrderItem.belongsTo(PurchaseOrder, {foreignKey: "orderId"});

// const qtyRange = [100, 1000];

// function generateRecord(){
//     return {
//         exDelDate: randomDefaultDate({type: "delivery"}),
//         unitPrice: faker.commerce.price(),
//         orderedQty: randomInt(...qtyRange),
//     }
// }

// OrderItem.generateRecord = generateRecord;
// OrderItem.insertRecords = async (items) => {
//     await assignQueryResult(items,
//         {
//             "itemSerial#": "itemSerial#",
//             "orderID": "orderID",
//         }, `
//         SELECT p.orderID, i.[itemSerial#]
//         FROM PurchaseOrder p
//         CROSS JOIN Item i
//         WHERE NOT EXISTS (
//             SELECT *
//             FROM OrderItem o
//             WHERE p.orderID = o.orderID AND i.[itemSerial#] = o.[itemSerial#] 
//         )`
//     )
//     await OrderItem.bulkCreate(items);
// }

const OrderItem = sequelize.define('OrderItem', {
    "itemSerial#": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Item, 
            key: 'itemSerial#' 
        }
    },
    orderID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: PurchaseOrder, 
            key: 'orderID' 
        }
    },
    "serial#": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Inventory, 
            key: 'serial#' 
        }
    },
    productID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Inventory, 
            key: 'productID' 
        }
    },
    clientID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Inventory, 
            key: 'clientID' 
        }
    },
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Inventory, 
            key: 'warehouseID' 
        }
    },
    supplierID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Supplier, 
            key: 'supplierID' 
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
    await assignQueryResult(items, {
        "itemSerial#": "itemSerial#",
        "orderID": "orderID",
        "serial#": "serial#",
        "productID": "productID",
        "clientID": "clientID",
        "warehouseID": "warehouseID",
        "supplierID": "supplierID",
    }, `
        SELECT * 
        FROM Inventory iv
        INNER JOIN Item it
            ON iv.productID = it.productID
        INNER JOIN supply s
            ON iv.clientID = s.clientID AND iv.productID = s.productID
        CROSS JOIN PurchaseOrder o
        WHERE NOT EXISTS (
            SELECT 1
            FROM OrderItem ot
            WHERE ot.serial# = iv.serial# AND ot.supplierID = s.supplierID AND ot.orderID = o.orderID
        )
    `)

    await OrderItem.bulkCreate(items);
}

module.exports = {
    OrderItem
};
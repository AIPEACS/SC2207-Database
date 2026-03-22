const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomInt } = require("../util");

const { Warehouse } = require("./Warehouse");
const { Product } = require("./Product");
const { Client } = require("./Client");
const { Zone } = require("./Zone");

const { assignFK } = require("../insert");

const Inventory = sequelize.define('Inventory', {
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Warehouse, 
            key: 'warehouseID' 
        }
    },
    productID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Product, 
            key: 'productID' 
        }
    },
    clientID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Client, 
            key: 'clientID' 
        }
    },
    "serial#": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
    },
    reservedQty: {
        type: DataTypes.INTEGER,
        allowNull: false, 
    },
    handQty: {
        type: DataTypes.INTEGER,
        allowNull: false, 
    },
    orderedQty: {
        type: DataTypes.INTEGER,
        allowNull: false, 
    },
    location: {
        type: DataTypes.INTEGER,
        allowNull: false, 
    }
}, {
    createdAt: false,
    updatedAt: false,
});

Warehouse.hasMany(Inventory, {foreignKey: "warehouseID"});
Inventory.belongsTo(Warehouse, {foreignKey: "warehouseID"});

Product.hasMany(Inventory, {foreignKey: "productID"});
Inventory.belongsTo(Product, {foreignKey: "productID"});

Client.hasMany(Inventory, {foreignKey: "clientID"});
Inventory.belongsTo(Client, {foreignKey: "clientID"});

const qtyRange = [0, 500];
const serialRange = [100000000, 999999999];

function generateRecord(){
    return {
        "serial#": randomInt(...serialRange),
        reservedQty: randomInt(...qtyRange),
        handQty: randomInt(...qtyRange),
        orderedQty: randomInt(...qtyRange),
    }
}

Inventory.generateRecord = generateRecord;
Inventory.insertRecords = async (inventories) => {
    await assignFK(Zone, inventories);
    await assignFK(Client, inventories);
    await assignFK(Product, inventories);
    await Inventory.bulkCreate(inventories);
}

module.exports = {
    Inventory
};
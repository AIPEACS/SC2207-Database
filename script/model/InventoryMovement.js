const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomElement, randomDefaultDate } = require("../util");

const { Inventory } = require("./Inventory");

const { assignFK } = require("../insert");
const { faker } = require("@faker-js/faker");

const movement = ["receipts", "putaways", "picks", "adjustments"];

const InventoryMovement = sequelize.define('InventoryMovement', {
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Inventory, 
            key: 'warehouseID' 
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
    "serial#": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Inventory, 
            key: 'serial#' 
        }
    },
    movement: {
        type: DataTypes.ENUM(movement),
        allowNull: false,
    },
    reason: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    timestamp: {
        type: DataTypes.DATE,
        primaryKey: true,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

function generateRecord(){
    return {
        movement: randomElement(movement),
        reason: faker.lorem.sentence(),
        timestamp: randomDefaultDate(),
    }
}

InventoryMovement.generateRecord = generateRecord;
InventoryMovement.insertRecords = async (movements) => {
    await assignFK(Inventory, movements);
    await InventoryMovement.bulkCreate(movements);
}

module.exports = {
    InventoryMovement
};
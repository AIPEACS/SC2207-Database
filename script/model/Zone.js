const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomInt, randomElement } = require("../util");

const { Warehouse } = require("./Warehouse");
const { assignFK } = require("../insert");

const code = ["receiving", "bulk storage", "picking area", "packing area", "shipping dock"];

const Zone = sequelize.define('Zone', {
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Warehouse, 
            key: 'warehouseID' 
        }
    },
    location: {
        type: DataTypes.INTEGER,
        primaryKey: true,
    },
    code: {
        type: DataTypes.ENUM(...code),
        allowNull: false,
    },
}, {
    createdAt: false,
    updatedAt: false,
});

Warehouse.hasMany(Zone, {foreignKey: "warehouseID"});
Zone.belongsTo(Warehouse, {foreignKey: "warehouseID"});

const locationRange = [0, 100000];

function generateRecord(){
    return {
        location: randomInt(...locationRange),
        code: randomElement(code),
    }
}

Zone.generateRecord = generateRecord;
Zone.insertRecords = async (zones) => {
    await assignFK(Warehouse, zones);
    await Zone.bulkCreate(zones);
}

module.exports = {
    Zone
};
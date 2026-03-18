const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');
const { faker } = require("@faker-js/faker");
const { randomNumber, randomElement } = require("../util")

const temperature = ["ambient", "refrigerated", "frozen"];
const security = ['low', 'medium', 'high'];

const Warehouse = sequelize.define('Warehouse', {
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    address: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    temperature: {
        type: DataTypes.ENUM(temperature),
        allowNull: false,
    },
    security: {
        type: DataTypes.ENUM(security),
        allowNull: false,
    },
    size: {
        type: DataTypes.DECIMAL(38, 2),
        allowNull: false
    },
}, {
    createdAt: false,
    updatedAt: false,
});

const sizeRange = [5000, 15000];

function generateRecord(){
    return {
        address: randomElement(["Singapore", faker.location.country()]),
        temperature: randomElement(temperature),
        security: randomElement(security),
        size: randomNumber(...sizeRange),
    };
}

Warehouse.generateRecord = generateRecord;

module.exports = {
    Warehouse
}
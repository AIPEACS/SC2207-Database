const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { faker } = require("@faker-js/faker");
const { randomInt, randomElement } = require("../util")

const vehicleType = ["van", "truck", "refrigerated truck"];

const Vehicle = sequelize.define('Vehicle', {
    vehicleID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    licensePlate: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
    vehicleType: {
        type: DataTypes.ENUM(...vehicleType),
        allowNull: false,
    },
    capacity: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
}, {
    createdAt: false,
    updatedAt: false,
});

const capacityRange = [500, 2000];

function generateRecord(){
    return {
        licensePlate: faker.vehicle.vrm(),
        vehicleType: randomElement(vehicleType),
        capacity: randomInt(...capacityRange),
    };
}

Vehicle.generateRecord = generateRecord;
Vehicle.insertRecords = Vehicle.bulkCreate;

module.exports = {
    Vehicle
}
const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');
const { randomElement, randomInt } = require("../util");

const status = ["planned", "in progress", "completed"];

const Route = sequelize.define('Route', {
    routeID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        autoIncrement: true,
    },
    totalDistance: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    status: {
        type: DataTypes.ENUM(status),
        allowNull: false, 
    },
}, {
    createdAt: false,
    updatedAt: false,
});

const distanceRange = [50, 100];

function generateRecord(){
    return {
        totalDistance: randomInt(...distanceRange),
        status: randomElement(status),
    }
}

Route.generateRecord = generateRecord;
Route.insertRecords = Route.bulkCreate;

module.exports = {
    Route
};
const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const serviceTier = ['bronze', 'silver', 'gold', 'platinum'];

const Client = sequelize.define('Client', {
    clientID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    serviceTier: {
        type: DataTypes.ENUM(...serviceTier),
        allowNull: false,
    },
    companyName: {
        type: DataTypes.STRING,
        allowNull: false
    },
    startDate: {
        type: DataTypes.DATEONLY,
        allowNull: false
    },
    contactPerson: {
        type: DataTypes.STRING,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

exports.serviceTier = serviceTier;
exports.Client = Client;
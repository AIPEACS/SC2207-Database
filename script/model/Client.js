const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');
const { faker } = require("@faker-js/faker");
const { randomDefaultDate, randomElement } = require("../util")

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

function generateRecord(){
    return {
        companyName: faker.company.name(),
        serviceTier: randomElement(serviceTier),
        startDate: randomDefaultDate(),
        contactPerson: faker.person.fullName(),
    }
}

Client.generateRecord = generateRecord;
Client.insertRecords = Client.bulkCreate;

module.exports = {
    Client
};
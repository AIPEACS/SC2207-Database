const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');
const { faker } = require("@faker-js/faker");
const { randomElement, randomInt } = require("../util")

const Supplier = sequelize.define('Supplier', {
    supplierID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    leadTime: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    paymentTerms: {
        type: DataTypes.STRING,
        allowNull: false
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    country: {
        type: DataTypes.STRING,
        allowNull: false,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

const leadTimeRange = [10, 30];
const paymentTerm = ["Net 30", "Net 60", "Net 90", "PIA", "EOM", "Due on Receipt"];

function generateRecord(){
    return {
        leadTime: randomInt(...leadTimeRange),
        paymentTerms: randomElement(paymentTerm),
        name: faker.company.name(),
        country: faker.location.country(),
    }
}

Supplier.generateRecord = generateRecord;
Supplier.insertRecords = Supplier.bulkCreate;

module.exports = {
    Supplier
};
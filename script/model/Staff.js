const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');
const { faker } = require("@faker-js/faker");
const { randomDefaultDate, randomElement } = require("../util");

const type = ["full-time", "part-time", "contract"];

const Staff = sequelize.define('Staff', {
    staffID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    type: {
        type: DataTypes.ENUM(...type),
        allowNull: false,
    },
    hireDate: {
        type: DataTypes.DATEONLY,
        allowNull: false,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

function generateRecord(){
    return {
        name: faker.person.fullName(),
        type: randomElement(type),
        hireDate: randomDefaultDate(),
    }
}

Staff.generateRecord = generateRecord;
Staff.insertRecords = Staff.bulkCreate;

module.exports = {
    Staff
}
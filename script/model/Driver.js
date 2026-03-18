const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { Staff } = require("./Staff");
const { Vehicle } = require("./Vehicle");
const { createParent, assignUniqueFK } = require("../insert");
const { faker } = require("@faker-js/faker");

const Driver = sequelize.define('Driver', {
    staffID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Staff, 
            key: 'staffID' 
        }
    },
    licenseNumber: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
    licenseExpiration: {
        type: DataTypes.DATE,
        allowNull: false,
    },
}, {
    createdAt: false,
    updatedAt: false,
});

Staff.hasOne(Driver, {foreignKey: "staffID"});
Driver.belongsTo(Staff, {foreignKey: "staffID"});

Vehicle.hasOne(Driver, {foreignKey: "vehicleID"});
Driver.belongsTo(Vehicle, {foreignKey: "vehicleID"});

function generateRecord(){
    return {
        licenseNumber: faker.commerce.upc(),
        licenseExpiration: faker.date.future({ years: 10 }),
    }
}

Driver.generateRecord = generateRecord;
Driver.insertRecords = async (drivers) => {
    await assignUniqueFK("Vehicle", "Driver", drivers, "vehicleID", 0.1);
    await createParent(Staff, "Staff", drivers, "staffID");
    await Driver.bulkCreate(drivers);
}

module.exports = {
    Driver
};
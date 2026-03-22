const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomElement } = require("../util");

const { Staff } = require("./Staff");
const { Warehouse } = require("./Warehouse");
const { createParent, assignFK } = require("../insert");

const certification = ["forklift operator", "hazmat handling", null];

const Employee = sequelize.define('Employee', {
    staffID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Staff, 
            key: 'staffID' 
        }
    },
    certification: {
        type: DataTypes.STRING,
    },
}, {
    createdAt: false,
    updatedAt: false,
});

Staff.hasOne(Employee, {foreignKey: "staffID"});
Employee.belongsTo(Staff, {foreignKey: "staffID"});

Warehouse.hasMany(Employee, {foreignKey: "warehouseID"});
Employee.belongsTo(Warehouse, {foreignKey: "warehouseID"});

function generateRecord(){
    return {
        certification: randomElement(certification),
    }
}

Employee.generateRecord = generateRecord;
Employee.insertRecords = async (employees) => {
    await createParent(Staff, "Staff", employees, "staffID");
    await assignFK(Warehouse, employees);
    await Employee.bulkCreate(employees);
}

module.exports = {
    Employee
};
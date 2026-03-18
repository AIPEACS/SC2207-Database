const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomElement } = require("../util");

const { Staff } = require("./Staff");
const { Warehouse } = require("./Warehouse");
const { insert } = require("../insert");

const certification = ["forklift operator", "hazmat handling", null];

const Employee = sequelize.define('Employee', {
    staffID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Staff, 
            key: 'staffId' 
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
    await insert(Staff, "Staff", employees.length);

    const [staffs, _] = await sequelize.query("SELECT staffID FROM STAFF WHERE staffID NOT IN (SELECT staffID FROM EMPLOYEE)");
    const warehouses = await Warehouse.findAll();

    for(let i=0; i<employees.length; i++){
        employees[i].staffID = staffs[i].staffID;
        employees[i].warehouseID = randomElement(warehouses).warehouseID;
    }

    await Employee.bulkCreate(employees);
}

module.exports = {
    Employee
};
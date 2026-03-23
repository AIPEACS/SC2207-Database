const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');
const { randomDefaultDate, randomElement } = require("../util");

const status = ["draft", "submitted", "confirmed", "partially received", "fully received", "cancelled"];

const PurchaseOrder = sequelize.define('PurchaseOrder', {
    orderID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        autoIncrement: true,
    },
    orderDate: {
        type: DataTypes.DATEONLY,
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

function generateRecord(){
    return {
        orderDate: randomDefaultDate(),
        status: randomElement(status),
    }
}

PurchaseOrder.generateRecord = generateRecord;
PurchaseOrder.insertRecords = PurchaseOrder.bulkCreate;

module.exports = {
    PurchaseOrder
};
const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { assignFK } = require("../insert");
const { faker } = require("@faker-js/faker");
const { PurchaseOrder } = require("./PurchaseOrder");
const { randomDefaultDate, randomElement, randomInt } = require("../util");

const Shipment = sequelize.define('Shipment', {
    shipmentID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        autoIncrement: true,
    },
    exArrDate: {
        type: DataTypes.DATE,
        allowNull: false,
    },
    acArrDate: {
        type: DataTypes.DATE,
    },
    shippedDate: {
        type: DataTypes.DATE,
    },
    originalLocation: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    trackingNumber: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true,
    },
}, {
    createdAt: false,
    updatedAt: false,
});

PurchaseOrder.hasMany(Shipment, {foreignKey: "orderID"});
Shipment.belongsTo(PurchaseOrder, {foreignKey: "orderID"});

const trackingNumberRange = [100000000, 999999999];

function generateRecord(){
    const acArrDate = randomDefaultDate({type: "actArrival"});
    const exArrDate = randomDefaultDate({type: "expArrival"});
    const shippedDate = faker.date.recent({ days: 100, refDate: exArrDate });
    
    return {
        exArrDate,
        acArrDate,
        shippedDate,
        originalLocation: randomElement(["United Kingdom", "Canada", "Germany"]),
        trackingNumber: randomInt(...trackingNumberRange),
    }
}

Shipment.generateRecord = generateRecord;
Shipment.insertRecords = async (shipments) => {
    await assignFK(PurchaseOrder, shipments);
    await Shipment.bulkCreate(shipments);
}

module.exports = {
    Shipment
};
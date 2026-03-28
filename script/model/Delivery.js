const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomDefaultDate } = require("../util");

const { assignFK } = require("../insert");

const { Route } = require("./Route");
const { Vehicle } = require("./Vehicle");
const { Warehouse } = require("./Warehouse");
const { Shipment } = require("./Shipment");

const Delivery = sequelize.define('Delivery', {
    routeID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Route, 
            key: 'routeID' 
        }
    },
    vehicleID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Vehicle, 
            key: 'vehicleID' 
        }
    },
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Warehouse, 
            key: 'warehouseID' 
        }
    },
    shipmentID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Shipment, 
            key: 'shipmentID', 
        }
    },
    date: {
        type: DataTypes.DATEONLY,
        primaryKey: true,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

function generateRecord(){
    return {
        date: randomDefaultDate({type: "delivery"})
    }
}

Delivery.generateRecord = generateRecord;
Delivery.insertRecords = async (deliveries) => {
    await assignFK(Route, deliveries);
    await assignFK(Warehouse, deliveries);
    await assignFK(Vehicle, deliveries);
    await assignFK(Shipment, deliveries);
    await Delivery.bulkCreate(deliveries);
}

module.exports = {
    Delivery
};
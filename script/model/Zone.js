const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomInt, randomElement } = require("../util");

const { Warehouse } = require("./Warehouse");
const { assignFK } = require("../insert");

const code = ["receiving", "bulk storage", "picking area", "packing area", "shipping dock"];

const Zone = sequelize.define('Zone', {
    warehouseID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Warehouse, 
            key: 'warehouseID' 
        }
    },
    location: {
        type: DataTypes.INTEGER,
        primaryKey: true,
    },
    code: {
        type: DataTypes.ENUM(...code),
        allowNull: false,
    },
}, {
    createdAt: false,
    updatedAt: false,
});

Warehouse.hasMany(Zone, {foreignKey: "warehouseID"});
Zone.belongsTo(Warehouse, {foreignKey: "warehouseID"});

const locationRange = [0, 100000];

function generateRecord(){
    return {
        location: randomInt(...locationRange),
        code: randomElement(code),
    }
}

Zone.generateRecord = generateRecord;
Zone.insertRecords = async (zones) => {
    const warehouses = await Warehouse.findAll({ attributes: ['warehouseID'] });
    const warehouseIDs = warehouses.map(w => w.warehouseID);

    if (warehouseIDs.length === 0) throw Error('No Warehouse records available for Zone assignment');

    // Guarantee at least one Zone per Warehouse
    // If requested zones < warehouses, add one Zone per warehouse (will exceed requested count).
    const baseZones = [];
    warehouseIDs.forEach(id => {
        baseZones.push({
            warehouseID: id,
            location: randomInt(...locationRange),
            code: randomElement(code),
        });
    });

    if (zones.length >= warehouseIDs.length) {
        // Assign each provided zone to a warehouse in round-robin order and save them.
        for (let i = 0; i < zones.length; i++) {
            zones[i].warehouseID = warehouseIDs[i % warehouseIDs.length];
            zones[i].location = zones[i].location ?? randomInt(...locationRange);
            zones[i].code = zones[i].code ?? randomElement(code);
        }
        await Zone.bulkCreate(zones);
    }

    // Create any required baseline zones to ensure full warehouse coverage.
    const usedWarehouseIDs = new Set(zones.map(z => z.warehouseID));
    const missing = warehouseIDs.filter(id => !usedWarehouseIDs.has(id));
    if (missing.length > 0) {
        const extras = missing.map(id => ({
            warehouseID: id,
            location: randomInt(...locationRange),
            code: randomElement(code),
        }));
        await Zone.bulkCreate(extras);
    }

    // Also include explicit per-warehouse zones where inscount < warehouses
    if (zones.length < warehouseIDs.length) {
        await Zone.bulkCreate(baseZones);
    }
};

module.exports = {
    Zone
};
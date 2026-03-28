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
    const warehouses = await Warehouse.findAll({ attributes: ['warehouseID'], order: [['warehouseID', 'ASC']] });
    const warehouseIDs = warehouses.map(w => w.warehouseID);

    if (warehouseIDs.length === 0) throw Error('No Warehouse records available for Zone assignment');

    // Assign as many zones as possible from the requested records.
    const seedCount = Math.min(zones.length, warehouseIDs.length);

    for (let i = 0; i < seedCount; i++) {
        zones[i].warehouseID = warehouseIDs[i];
        zones[i].location = zones[i].location ?? randomInt(...locationRange);
        zones[i].code = zones[i].code ?? randomElement(code);
    }

    // Extra seeded zones beyond one-per-warehouse come from random warehouses.
    for (let i = seedCount; i < zones.length; i++) {
        zones[i].warehouseID = warehouseIDs[Math.floor(Math.random() * warehouseIDs.length)];
        zones[i].location = zones[i].location ?? randomInt(...locationRange);
        zones[i].code = zones[i].code ?? randomElement(code);
    }

    await Zone.bulkCreate(zones);

    // Guarantee each warehouse has at least one zone. If any warehouse has no zone, insert one.
    const currentWarehouseIDs = new Set((await Zone.findAll({ attributes: ['warehouseID'] })).map(z => z.warehouseID));
    const missingIDs = warehouseIDs.filter(id => !currentWarehouseIDs.has(id));

    if (missingIDs.length > 0) {
        const extras = missingIDs.map(id => ({
            warehouseID: id,
            location: randomInt(...locationRange),
            code: randomElement(code),
        }));
        await Zone.bulkCreate(extras);
    }
};

module.exports = {
    Zone
};
const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { Product } = require("./Product");
const { Client } = require("./Client");
const { Supplier } = require("./Supplier");

const { assignFK, assignQueryResult } = require("../insert");
const { faker } = require("@faker-js/faker");

const Supply = sequelize.define('Supply', {
    supplierID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Supplier, 
            key: 'supplierID' 
        }
    },
    productID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Product, 
            key: 'productID' 
        }
    },
    clientID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Client, 
            key: 'clientID' 
        }
    },
    period: {
        type: DataTypes.DATE,
        allowNull: false,
    }
}, {
    createdAt: false,
    updatedAt: false,
});

Product.hasMany(Supply, {foreignKey: "productID"});
Supply.belongsTo(Product, {foreignKey: "productID"});

Client.hasMany(Supply, {foreignKey: "clientID"});
Supply.belongsTo(Client, {foreignKey: "clientID"});

Supplier.hasMany(Supply, {foreignKey: "supplierID"});
Supply.belongsTo(Supplier, {foreignKey: "supplierID"});

function generateRecord(){
    return {
        period: faker.date.future(5),
    }
}

Supply.generateRecord = generateRecord;
Supply.insertRecords = async (supplies) => {
    await assignFK(Supplier, supplies);
    await assignQueryResult(supplies, 
        {
            "productID": "productID",
            "clientID": "clientID",
        }, `
            SELECT DISTINCT i.productID, i.clientID
            FROM Inventory i
            WHERE NOT EXISTS (
                SELECT *
                FROM Supply s
                WHERE s.productID = i.productID AND s.clientID = i.clientID
            )
        `
    )
    await Supply.bulkCreate(supplies);
}

module.exports = {
    Supply
};
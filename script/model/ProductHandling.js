const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { randomElement } = require("../util");

const { Product } = require("./Product");
const { assignUniqueFK } = require("../insert");

const handlingRequirement = ["fragile", "hazardous", "temperature-controlled", "high-value"];

const ProductHandling = sequelize.define('ProductHandling', {
    productID: {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        references: {
            model: Product, 
            key: 'productID' 
        }
    },
    handlingRequirement: {
        type: DataTypes.ENUM(...handlingRequirement),
        primaryKey: true,
    },
}, {
    createdAt: false,
    updatedAt: false,
});

Product.hasMany(ProductHandling, {foreignKey: "productID"});
ProductHandling.belongsTo(Product, {foreignKey: "productID"});

function generateRecord(){
    return {
        handlingRequirement: randomElement(handlingRequirement),
    }
}

ProductHandling.generateRecord = generateRecord;
ProductHandling.insertRecords = async (handling) => {
    await assignUniqueFK("Product", "ProductHandling", handling, "productID", 0);

    for (const record of handling) {
        await ProductHandling.findOrCreate({
            where: {
                productID: record.productID,
                handlingRequirement: record.handlingRequirement,
            },
            defaults: record
        });
    }
}

module.exports = {
    ProductHandling
};
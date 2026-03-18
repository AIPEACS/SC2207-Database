const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const { Product } = require("./Product");
const { assignUniqueFK } = require("../insert");

const Item = sequelize.define('Item', {
    "itemSerial#": {
        type: DataTypes.INTEGER,
        primaryKey: true, 
        autoIncrement: true,
    },
}, {
    createdAt: false,
    updatedAt: false,
});

Product.hasOne(Item, {foreignKey: "productID"});
Item.belongsTo(Product, {foreignKey: "productID"});

function generateRecord(){
    return {}
}

Item.generateRecord = generateRecord;
Item.insertRecords = async (items) => {
    await assignUniqueFK("Product", "Item", items, "productID", 0);
    await Item.bulkCreate(items);
}

module.exports = {
    Item
};
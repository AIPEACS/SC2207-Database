const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');

const Product = sequelize.define('Product', {
    productID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    brand: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    cost: {
        type: DataTypes.DECIMAL(38, 2),
        allowNull: false
    },
    category: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    price: {
        type: DataTypes.DECIMAL(38, 2),
        allowNull: false
    },
    length: {
        type: DataTypes.DECIMAL(38, 2),
        allowNull: false
    },
    width: {
        type: DataTypes.DECIMAL(38, 2),
        allowNull: false
    },
    height: {
        type: DataTypes.DECIMAL(38, 2),
        allowNull: false
    },
}, {
    createdAt: false,
    updatedAt: false,
});

module.exports = {
    Product
}
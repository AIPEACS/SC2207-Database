const { DataTypes } = require("sequelize");
const { sequelize } = require('../init');
const { faker } = require("@faker-js/faker");
const { randomNumber, randomElement } = require("../util")

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

const priceRatioRange = [1.05, 1.3];
const dimRanges = [[1, 10], [10, 50], [50, 100]];

function generateRecord(){
    const cost = faker.commerce.price();
    const price = Math.round(cost * randomNumber(...priceRatioRange) * 100) / 100;
    const dimRange = randomElement(dimRanges);

    return {
        name: faker.commerce.productName(),
        brand: faker.company.name(),
        cost: cost,
        price: price,
        category: faker.commerce.department(),
        length: randomNumber(...dimRange),
        width: randomNumber(...dimRange),
        height: randomNumber(...dimRange),
    };
}

Product.generateRecord = generateRecord;
Product.insertRecords = Product.bulkCreate;

module.exports = {
    Product
}
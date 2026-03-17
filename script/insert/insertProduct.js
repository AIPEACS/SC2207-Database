const { Product } = require("../model/Product");
const { faker } = require("@faker-js/faker");
const { randomNumber, randomElement } = require("../util")

const priceRatioRange = [1.05, 1.3];
const dimRanges = [[1, 10], [10, 50], [50, 100]];

async function insertProduct(number) {
    const products = []

    for(let i=0; i<number; i++){
        const cost = faker.commerce.price();
        const price = Math.round(cost * randomNumber(...priceRatioRange) * 100) / 100;
        const dimRange = randomElement(dimRanges);

        products.push({
            name: faker.commerce.productName(),
            brand: faker.company.name(),
            cost: cost,
            price: price,
            category: faker.commerce.department(),
            length: randomNumber(...dimRange),
            width: randomNumber(...dimRange),
            height: randomNumber(...dimRange),
        });
    }

    await Product.bulkCreate(products)
    .then(() => console.log(`${number} Product created.`))
    .catch((error) => {
        console.error(`Product creation failed. Error: ${error}`);
        throw error;
    });
}

module.exports = {
    insertProduct
}
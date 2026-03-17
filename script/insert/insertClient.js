const { serviceTier, Client } = require("../model/Client");
const { faker } = require("@faker-js/faker");
const { randomDefaultDate } = require("../util")

async function insertClient(number) {
    const clients = []

    for(let i=0; i<number; i++){
        clients.push({
            companyName: faker.company.name(),
            serviceTier: serviceTier[Math.floor(Math.random() * serviceTier.length)],
            startDate: randomDefaultDate(),
            contactPerson: faker.person.fullName(),
        });
    }

    await Client.bulkCreate(clients)
    .then(() => console.log(`${number} Client created.`))
    .catch((error) => {
        console.error(`Client creation failed. Error: ${error}`);
        throw error;
    });
}

module.exports = {
    insertClient
}
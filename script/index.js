#!/usr/bin/env node

const { sequelize } = require("./init")

const { insert } = require("./insert");
const { Client } = require("./model/Client");
const { Product } = require("./model/Product");
const { Warehouse } = require("./model/Warehouse");
const { Employee } = require("./model/Employee");
const { Vehicle } = require("./model/Vehicle");

const { rl, question } = require("./cli");

const models = {
    Client,
    Product,
    Warehouse,
    Employee,
    Vehicle,
}

async function main(){
    const tables = Object.keys(models);
    console.log(`All Table: ${tables.join(", ")}`);

    let name = null
    let model = null;
    while(model == null){
        name = await question(`Enter table name: `);
        model = models[name];
        if(model == null) console.error(`Table '${name}' doesn't exists`);
    }

    let num = NaN;
    while(Number.isNaN(num)){
        num = await question(`Enter number of records to insert: `);
        num = parseInt(num);
        if(Number.isNaN(num)) console.error(`Please enter a valid number`);
    }

    sequelize.sync()

    insert(model, name, num)
    .catch((error) => {
        console.error(`Process terminated unexpectedly: ${error}`)
        rl.close();
        process.exit(-1);
    })
    .finally(() => {
        rl.close();
        process.exit(0);
    })
}

main();
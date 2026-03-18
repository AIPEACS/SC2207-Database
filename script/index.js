#!/usr/bin/env node

const { sequelize } = require("./init")

const { insert } = require("./insert");
const { Client } = require("./model/Client");
const { Driver } = require("./model/Driver");
const { Employee } = require("./model/Employee");
const { Product } = require("./model/Product");
const { ProductHandling } = require("./model/ProductHandling");
const { Supplier } = require("./model/Supplier");
const { Vehicle } = require("./model/Vehicle");
const { Warehouse } = require("./model/Warehouse");
const { Zone } = require("./model/Zone");

const { rl, question } = require("./cli");

const models = {
    Client,
    Driver,
    Employee,
    Product,
    ProductHandling,
    Supplier,
    Vehicle,
    Warehouse,
    Zone,
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
        console.error(`Process terminated unexpectedly: ${error.parent}`)
        rl.close();
        process.exit(-1);
    })
    .finally(() => {
        rl.close();
        process.exit(0);
    })
}

main();
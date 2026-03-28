#!/usr/bin/env node

const { sequelize } = require("./init")

const { insert } = require("./insert");
const { Client } = require("./model/Client");
const { Delivery } = require("./model/Delivery");
const { Driver } = require("./model/Driver");
const { Employee } = require("./model/Employee");
const { Inventory } = require("./model/Inventory");
const { InventoryMovement } = require("./model/InventoryMovement");
const { Item } = require("./model/Item");
const { OrderItem } = require("./model/OrderItem");
const { Product } = require("./model/Product");
const { ProductHandling } = require("./model/ProductHandling");
const { PurchaseOrder } = require("./model/PurchaseOrder");
const { Route } = require("./model/Route");
const { Shipment } = require("./model/Shipment");
const { Supplier } = require("./model/Supplier");
const { Supply } = require("./model/Supply");
const { Vehicle } = require("./model/Vehicle");
const { Warehouse } = require("./model/Warehouse");
const { Zone } = require("./model/Zone");

const { rl, question } = require("./cli");
const { ShipItem } = require("./model/ShipItem");
const { Shipment_Supplier } = require("./model/Shipment_Supplier");
const { Shipment_Warehouse } = require("./model/Shipment_Warehouse");

const models = {
    Client,
    Delivery,
    Driver,
    Employee,
    Inventory,
    InventoryMovement,
    Item,
    OrderItem,
    Product,
    ProductHandling,
    PurchaseOrder,
    Route,
    ShipItem,
    Shipment,
    Shipment_Supplier,
    Shipment_Warehouse,
    Supplier,
    Supply,
    Vehicle,
    Warehouse,
    Zone,
}

async function runInsertion(tableName, num) {
    const model = models[tableName];
    if (!model) {
        throw new Error(`Table '${tableName}' does not exist`);
    }

    if (isNaN(num) || num <= 0) {
        throw new Error(`Invalid number of records: ${num}`);
    }

    await sequelize.sync();
    await insert(model, tableName, num);
    console.log(`Inserted ${num} records into ${tableName}`);
}

async function main(){
    const tables = Object.keys(models);
    console.log(`All Table: ${tables.join(", ")}`);

    const args = process.argv.slice(2);
    if (args.length >= 2) {
        const [name, countStr] = args;
        const num = parseInt(countStr, 10);
        try {
            await runInsertion(name, num);
        } catch (error) {
            console.error(`Process terminated unexpectedly: ${error.parent || error.message}`);
            process.exit(-1);
        } finally {
            process.exit(0);
        }
        return;
    }

    let name = null;
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

    try {
        await runInsertion(name, num);
    } catch (error) {
        console.error(`Process terminated unexpectedly: ${error.parent || error.message}`);
        process.exit(-1);
    } finally {
        rl.close();
        process.exit(0);
    }
}

main();
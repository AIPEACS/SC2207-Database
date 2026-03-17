#!/usr/bin/env node

const { sequelize } = require("./init")
const { insertClient } = require("./insert/insertClient");
const { rl, question } = require("./cli");

const inserts = {
    Client: insertClient,
}

async function main(){
    const tables = Object.keys(inserts);
    console.log(`All Table: ${tables.join(", ")}`);

    let insert = null;
    while(insert == null){
        const table = await question(`Enter table name: `);
        insert = inserts[table];
        if(insert == null) console.error(`Table '${table}' doesn't exists`);
    }

    let num = NaN;
    while(Number.isNaN(num)){
        num = await question(`Enter number of records to insert: `);
        num = parseInt(num);
        if(Number.isNaN(num)) console.error(`Please enter a valid number`);
    }

    sequelize.sync()

    insert(num)
    .catch((error) => {
        rl.close();
        process.exit(-1);
    })
    .finally(() => {
        rl.close();
        process.exit(0);
    })
}

main()
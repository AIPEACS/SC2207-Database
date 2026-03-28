const { arrayShuffle } = require("array-shuffle");
const { sequelize } = require("./init");
const { randomElement } = require("./util");

async function insert(model, name, number){
    records = [];

    for(let i=0; i<number; i++){
        records.push(model.generateRecord());
    }

    await model.insertRecords(records)
    .then(() => console.log(`${number} ${name} created.`))
    .catch((error) => {
        console.error(`${name} creation failed. Error: ${error}`);
        throw error;
    });
}

async function createParent(parentModel, parentName, records, idName){
    await insert(parentModel, parentName, records.length);

    const [parents, _] = await sequelize.query(`SELECT TOP ${records.length} ${idName} FROM ${parentName} ORDER BY ${idName} DESC`);
    const ids = parents.map((parent) => parent[idName]);
    
    for(let i=0; i<records.length; i++){
        records[i][idName] = ids[i];
    }
}

async function assignFK(fkModel, records) {
    const keys = fkModel.primaryKeyAttributes;
    const fkrecords = await fkModel.findAll();
    
    records.forEach(record => {
        const fkrecord = randomElement(fkrecords);
        keys.forEach(key => {
            record[key] = fkrecord[key];
        })
    });
}

async function assignUniqueFK(fkModelName, modelName, records, fkName, nullProbability) {
    // This helper is used by join tables, where the same FK may appear in multiple records.
    // It now gracefully handles insufficient fk rows by reusing existing values instead of throwing.
    const [fkrecords, _] = await sequelize.query(`SELECT ${fkName} FROM ${fkModelName}`);

    if (fkrecords.length === 0) throw Error(`No FK records found for ${fkModelName}.${fkName}`);

    const availableIds = fkrecords.map(r => r[fkName]);

    records.forEach(record => {
        if (nullProbability > 0 && Math.random() < nullProbability) {
            record[fkName] = null;
        } else {
            const chosen = availableIds[Math.floor(Math.random() * availableIds.length)];
            record[fkName] = chosen;
        }
    });
}

async function assignQueryResult(records, columns, query) {
    const [queryRecords, _] = await sequelize.query(query);

    if(queryRecords.length < records.length) throw Error("Insufficient records");
    arrayShuffle(queryRecords);

    for(let i=0; i<records.length; i++){
        Object.entries(columns).forEach(([k, v]) => {
            records[i][k] = queryRecords[i][v];
        });
    }
}

module.exports = {
    insert,
    createParent,
    assignFK,
    assignUniqueFK,
    assignQueryResult,
}
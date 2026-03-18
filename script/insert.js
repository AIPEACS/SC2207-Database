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

async function assignFK(fkModel, records, fkName) {
    const fkrecords = await fkModel.findAll();

    records.forEach(record => {
        record[fkName] = randomElement(fkrecords)[fkName];
    });
}

async function assignUniqueFK(fkModelName, modelName, records, fkName, nullProbability) {
    const [fkrecords, _] = await sequelize.query(`SELECT ${fkName} FROM ${fkModelName} WHERE ${fkName} NOT IN (SELECT ${fkName} FROM ${modelName})`);

    if(nullProbability == 0 && fkrecords.length < records.length) throw Error("Insufficient Unique FK");

    let fkindex = 0;
    records.forEach(record => {
        if(fkindex >= fkrecords.length || Math.random() < nullProbability) record[fkName] = null;
        else record[fkName] = fkrecords[fkindex++][fkName];
    });
}

module.exports = {
    insert,
    createParent,
    assignFK,
    assignUniqueFK,
}
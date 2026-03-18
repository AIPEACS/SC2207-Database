async function insert(model, name, number){
    records = [];

    for(let i=0; i<number; i++){
        records.push(model.generateRecord());
    }

    await model.bulkCreate(records)
    .then(() => console.log(`${number} ${name} created.`))
    .catch((error) => {
        console.error(`${name} creation failed. Error: ${error}`);
        throw error;
    });
}

module.exports = {
    insert
}
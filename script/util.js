function randomDate(start, end) {
    const startTimestamp = start.getTime(); 
    const endTimestamp = end.getTime();     
    const timeDifference = endTimestamp - startTimestamp;
    
    const randomTime = Math.random() * timeDifference;
    
    return new Date(startTimestamp + randomTime); 
}

function randomDefaultDate(){
    const now = new Date();
    const fiveYearsAgo = new Date();
    fiveYearsAgo.setFullYear(now.getFullYear() - 5);

    return randomDate(now, fiveYearsAgo);
}

module.exports = {
    randomDate,
    randomDefaultDate
}
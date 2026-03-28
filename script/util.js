function randomDate(start, end) {
    const startTimestamp = start.getTime(); 
    const endTimestamp = end.getTime();     
    const randomTime = randomNumber(startTimestamp, endTimestamp);
    
    return new Date(randomTime); 
}

function getDateYearsAgo(num){
    const date = new Date();
    date.setFullYear(date.getFullYear() - num);
    return date;
}

function randomDefaultDate({type = null} = {}){
    if(type == null){
        const now = new Date();
        const fiveYearsAgo = getDateYearsAgo(5);

        return randomDate(now, fiveYearsAgo);
    }

    const startDate = {
        order: [new Date(2024, 0, 1), new Date(2024, 11, 31)],
        expArrival: [new Date(2025, 0, 1), new Date(2025, 6, 30)],
        actArrival: [new Date(2025, 0, 1), new Date(2025, 11, 31)],
        delivery: [new Date(2026, 0, 1), new Date()],
    }

    const dateRange = startDate[type];
    if(dateRange == null) throw Error(`Invalid date type: ${type}`);
    return randomDate(...dateRange);
}

function randomNumber(start, end){
    const diff = end - start;
    return start + Math.random() * diff; 
}

function randomInt(start, end){
    return Math.floor(randomNumber(start, end));
}

function randomElement(arr){
    const index = randomInt(0, arr.length);
    return arr[index];
}

module.exports = {
    randomDate,
    randomDefaultDate,
    randomNumber,
    randomInt,
    randomElement,
}
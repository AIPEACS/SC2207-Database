function randomDate(start, end) {
    const startTimestamp = start.getTime(); 
    const endTimestamp = end.getTime();     
    const randomTime = randomNumber(startTimestamp, endTimestamp);
    
    return new Date(randomTime); 
}

function randomDefaultDate(){
    const now = new Date();
    const fiveYearsAgo = new Date();
    fiveYearsAgo.setFullYear(now.getFullYear() - 5);

    return randomDate(now, fiveYearsAgo);
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
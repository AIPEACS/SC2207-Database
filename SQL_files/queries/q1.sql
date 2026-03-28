SELECT 
    warehouseID,
    clientID,
    SUM(orderedQty * unitPrice) AS business
FROM OrderItem
GROUP BY warehouseID, clientID
ORDER BY warehouseID ASC, business DESC;

WITH Business AS (
    SELECT 
        warehouseID,
        clientID,
        SUM(orderedQty * unitPrice) AS business
    FROM OrderItem
    GROUP BY warehouseID, clientID
),
Ranked AS (
    SELECT
        warehouseID,
        clientID,
        business,
        ROW_NUMBER() OVER (PARTITION BY warehouseID ORDER BY business DESC) AS rank
    FROM Business
)
SELECT warehouseID, clientID, business, rank
FROM Ranked
WHERE rank <= 3
ORDER BY warehouseID, rank;
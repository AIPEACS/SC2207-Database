USE [<DATABASE>];
GO

-- To verify results only
SELECT 
    warehouseID,
    clientID,
    SUM(orderedQty * unitPrice) AS business
FROM OrderItem
GROUP BY warehouseID, clientID
ORDER BY business DESC, warehouseID ASC;

-- Required query
WITH Business AS (
    SELECT 
        warehouseID,
        clientID,
        SUM(orderedQty * unitPrice) AS business
    FROM OrderItem i
    INNER JOIN PurchaseOrder o
        ON i.orderID = o.orderID
    WHERE o.status IN ('confirmed', 'partially recieved', 'fully received')
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
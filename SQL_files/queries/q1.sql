
-- For each warehouse, find its top 3 clients by total inventory value (handQty * product price)
SELECT
    warehouseID,
    clientID,
    companyName,
    totalValue
FROM (
    SELECT
        i.warehouseID,
        i.clientID,
        c.companyName,
        SUM(i.handQty * p.price) AS totalValue,
        DENSE_RANK() OVER (
            PARTITION BY i.warehouseID
            ORDER BY SUM(i.handQty * p.price) DESC
        ) AS r
    FROM Inventory i
    JOIN Product p ON i.productID = p.productID
    JOIN Client  c ON i.clientID  = c.clientID
    GROUP BY i.warehouseID, i.clientID, c.companyName
) ranked
WHERE r <= 3
ORDER BY warehouseID, r;
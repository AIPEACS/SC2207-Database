SELECT DISTINCT s.supplierID, w.address
FROM Supply s
INNER JOIN Inventory i
    ON s.productID = i.productID AND s.clientID = i.clientID
INNER JOIN Warehouse w
    ON i.warehouseID = w.warehouseID;

WITH SupplyAddress(supplierID, address) AS (
    SELECT DISTINCT s.supplierID, w.address
    FROM Supply s
    INNER JOIN Inventory i
        ON s.productID = i.productID AND s.clientID = i.clientID
    INNER JOIN Warehouse w
        ON i.warehouseID = w.warehouseID
)
SELECT s.supplierID, s.name
FROM Supplier s
WHERE EXISTS (
    SELECT 1
    FROM SupplyAddress sa
    WHERE sa.address = 'Singapore' AND s.supplierID = sa.supplierID
) AND NOT EXISTS (
    SELECT 1
    FROM SupplyAddress sa
    WHERE sa.address <> 'Singapore' AND s.supplierID = sa.supplierID
)
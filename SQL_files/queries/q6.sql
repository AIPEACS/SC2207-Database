USE [<DATABASE>];
GO

WITH SingaporeProduct(productID, clientID) AS (
    SELECT DISTINCT i.productID, i.clientID
    FROM Inventory i
    INNER JOIN Warehouse w
        ON i.warehouseID = w.warehouseID AND w.address = 'Singapore'
),
ThailandSupplier(supplierID) AS (
    SELECT DISTINCT s.supplierID
    FROM Supply s
    INNER JOIN Inventory i
        ON s.clientID = i.clientID AND s.productID = i.productID
    INNER JOIN Warehouse w
        ON i.warehouseID = w.warehouseID AND w.address = 'Thailand'
)
SELECT supplierID
FROM Supply s
WHERE EXISTS(
    SELECT 1
    FROM SingaporeProduct sp
    WHERE s.productID = sp.productID AND s.clientID = sp.clientID
) AND NOT EXISTS (
    SELECT 1
    FROM ThailandSupplier ts
    WHERE s.supplierID = ts.supplierID
)
GROUP BY s.supplierID
HAVING COUNT(DISTINCT productID) = (
    SELECT COUNT(DISTINCT productID) FROM SingaporeProduct
)
-- (
-- 	SELECT Supplier.supplierID AS supplierID, Supplier.name AS name
-- 	FROM Supplier
-- 	WHERE NOT EXISTS (
-- 		SELECT 1
-- 		FROM Supplier sr
-- 		JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
-- 		JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
-- 		JOIN Warehouse w ON w.warehouseID = shw.warehouseID
-- 		WHERE w.address = 'Thailand'
-- 			AND Supplier.supplierID = sr.supplierID
-- 	)
-- ) INTERSECT (
-- 	SELECT Supplier.supplierID AS supplierID, Supplier.name AS name
-- 	FROM Supplier
-- 	WHERE NOT EXISTS (
-- 		SELECT w.warehouseID
-- 		FROM Warehouse w
-- 		WHERE w.address = 'Singapore'
-- 			AND NOT EXISTS (
-- 				SELECT sr.supplierID
-- 				FROM Supplier sr
-- 				JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
-- 				JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
-- 				JOIN Warehouse w1 ON w1.warehouseID = shw.warehouseID
-- 				WHERE Supplier.supplierID = sr.supplierID
-- 					AND w1.warehouseID = w.warehouseID
-- 			)
-- 	)
-- )

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
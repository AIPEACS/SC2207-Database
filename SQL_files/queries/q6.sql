
(
	SELECT Supplier.supplierID AS supplierID, Supplier.name AS name
	FROM Supplier
	WHERE NOT EXISTS (
		SELECT sr.supplierID
		FROM Supplier sr
		JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
		JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
		JOIN Warehouse w ON w.warehouseID = shw.warehouseID
		WHERE w.address = 'Thailand'
			AND Supplier.supplierID = sr.supplierID
	)
) INTERSECT (
	SELECT Supplier.supplierID AS supplierID, Supplier.name AS name
	FROM Supplier
	WHERE NOT EXISTS (
		SELECT w.warehouseID
		FROM Warehouse w
		WHERE w.address = 'Singapore'
			AND NOT EXISTS (
				SELECT sr.supplierID
				FROM Supplier sr
				JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
				JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
				JOIN Warehouse w1 ON w1.warehouseID = shw.warehouseID
				WHERE Supplier.supplierID = sr.supplierID
					AND w1.warehouseID = w.warehouseID
			)
	)
)
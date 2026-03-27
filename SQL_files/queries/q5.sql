(
	SELECT DISTINCT sr.supplierID
	FROM Supplier sr
	JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
	JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
	JOIN Warehouse w ON w.warehouseID = shw.warehouseID
	WHERE w.address = 'Singapore'
) EXCEPT (
	SELECT DISTINCT sr.supplierID
	FROM Supplier sr
	JOIN Shipment_Supplier shsr ON sr.supplierID = shsr.supplierID
	JOIN Shipment_Warehouse shw ON shsr.shipmentID = shw.shipmentID
	JOIN Warehouse w ON w.warehouseID = shw.warehouseID
	WHERE w.address <> 'Singapore'
)

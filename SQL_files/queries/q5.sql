SELECT DISTINCT ss.supplierID,w.address
FROM Shipment_Supplier ss
LEFT JOIN Shipment_Warehouse sw
	ON ss.shipmentID = sw.shipmentID
LEFT JOIN Warehouse w 
	ON sw.warehouseID = w.warehouseID
WHERE w.address = 'Singapore'

SELECT DISTINCT ss.supplierID, w.address
FROM Shipment_Supplier ss
LEFT JOIN Shipment_Warehouse sw
	ON ss.shipmentID = sw.shipmentID
LEFT JOIN Warehouse w 
	ON sw.warehouseID = w.warehouseID
WHERE w.address <> 'Singapore'

(
	SELECT DISTINCT ss.supplierID, s.name
	FROM Shipment_Supplier ss
	LEFT JOIN Shipment_Warehouse sw
		ON ss.shipmentID = sw.shipmentID
	LEFT JOIN Warehouse w 
		ON sw.warehouseID = w.warehouseID
	LEFT JOIN supplier s ON ss.supplierID = s.supplierID
	WHERE w.address = 'Singapore'
) EXCEPT (
	SELECT DISTINCT ss.supplierID, s.name
	FROM Shipment_Supplier ss
	LEFT JOIN Shipment_Warehouse sw
		ON ss.shipmentID = sw.shipmentID
	LEFT JOIN Warehouse w 
		ON sw.warehouseID = w.warehouseID
	LEFT JOIN supplier s ON ss.supplierID = s.supplierID
	WHERE w.address <> 'Singapore'
)
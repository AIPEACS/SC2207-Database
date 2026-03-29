USE [<DATABASE>];
GO

SELECT o.orderDate AS orderDate, CAST(d.date AS DATE) AS deliveryDate, DATEDIFF(MONTH, o.orderDate, d.date) as monthDiff
FROM Delivery d
LEFT JOIN Shipment s
ON d.shipmentID = s.shipmentID
LEFT JOIN PurchaseOrder o   
ON s.orderID = o.orderID

/*
SELECT AVG(DATEDIFF(MONTH, o.orderDate, d.date)) as avg_month
FROM Delivery d
LEFT JOIN Shipment s
ON d.shipmentID = s.shipmentID
LEFT JOIN PurchaseOrder o   
ON s.orderID = o.orderID
*/
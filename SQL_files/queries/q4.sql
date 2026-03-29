USE [<DATABASE>];
GO

-- To verify results only
SELECT o.orderDate AS orderDate, CAST(d.date AS DATE) AS deliveryDate, DATEDIFF(MONTH, o.orderDate, d.date) as monthDiff
FROM Delivery d
LEFT JOIN Shipment s
ON d.shipmentID = s.shipmentID
LEFT JOIN PurchaseOrder o   
ON s.orderID = o.orderID

-- Required query
SELECT AVG(DATEDIFF(MONTH, o.orderDate, d.date)) as avgMonth
FROM Delivery d
INNER JOIN Shipment s
    ON d.shipmentID = s.shipmentID
INNER JOIN PurchaseOrder o   
    ON s.orderID = o.orderID
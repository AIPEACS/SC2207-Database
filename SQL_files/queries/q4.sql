SELECT AVG(DATEDIFF(day, po.orderDate, sh.acArrDate)) as avg_time
FROM PurchaseOrder po
JOIN Shipment sh ON sh.orderID = po.orderID
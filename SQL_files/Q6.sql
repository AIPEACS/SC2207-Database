SELECT p.orderID, i.[itemSerial#]
FROM PurchaseOrder p
CROSS JOIN Item i
WHERE NOT EXISTS (
    SELECT *
    FROM OrderItem o
    WHERE p.orderID = o.orderID AND i.[itemSerial#] = o.[itemSerial#] 
)
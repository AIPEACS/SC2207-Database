USE [<DATABASE>];
GO

WITH Business(SingaporeBusiness, LABusiness) AS (
    SELECT 
        SUM(CASE WHEN w.address = 'Singapore' THEN oi.orderedQty * oi.unitPrice END) AS SingaporeBusiness,
        SUM(CASE WHEN w.address = 'Los Angeles, USA' THEN oi.orderedQty * oi.unitPrice END) AS LABusiness
    FROM OrderItem oi
    INNER JOIN Warehouse w
        ON oi.warehouseID = w.warehouseID
)
SELECT 
    SingaporeBusiness,
    LABusiness,
    CASE WHEN SingaporeBusiness > LABusiness THEN 'True' ELSE 'False' END AS Result
FROM Business

    -- SELECT *
    -- FROM Delivery d
    -- INNER JOIN Shipment s
    --     ON d.shipmentID = s.shipmentID
    -- INNER JOIN Shipment_Warehouse sw
    --     ON s.shipmentID = sw.shipmentID
    -- INNER JOIN Warehouse w
    --     ON sw.warehouseID = w.warehouseID
    -- INNER JOIN PurchaseOrder o
    --     ON s.orderID = o.orderID
    -- INNER JOIN OrderItem oi
    --     ON o.orderID = oi.orderID
    -- INNER JOIN Client c
    --     ON oi.clientID = c.clientID
    -- WHERE s.acArrDate IS NOT NULL;

WITH DeliveryPerformance AS (
    SELECT
        c.clientID,
        c.companyName,
        w.address AS region,
        COUNT(*) AS totalDeliveries,
        SUM(CASE 
            WHEN oi.exDelDate <= d.date THEN 1 
            ELSE 0 
        END) AS onTimeDeliveries,
        SUM(CASE 
            WHEN oi.exDelDate > d.date THEN 1 
            ELSE 0 
        END) AS lateDeliveries
    FROM Delivery d
    INNER JOIN Shipment s
        ON d.shipmentID = s.shipmentID
    INNER JOIN PurchaseOrder o
        ON s.orderID = o.orderID
    INNER JOIN OrderItem oi
        ON o.orderID = oi.orderID
    INNER JOIN Client c
        ON oi.clientID = c.clientID
    INNER JOIN Warehouse w
        ON oi.warehouseID = w.warehouseID
    GROUP BY c.clientID, c.companyName, w.address
)
SELECT
    companyName,
    region,
    totalDeliveries,
    onTimeDeliveries,
    lateDeliveries,
    CAST(
        100.0 * onTimeDeliveries / NULLIF(totalDeliveries, 0) 
    AS DECIMAL(5,2)) AS onTimeRate
FROM DeliveryPerformance
ORDER BY companyName, onTimeRate DESC;
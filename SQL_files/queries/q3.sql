WITH MonthCount AS (
    SELECT
        YEAR(po.orderDate) AS year,
        MONTH(po.orderDate) AS month,
        COUNT(po.orderID) AS count
    FROM PurchaseOrder po
    WHERE po.orderDate >= DATEADD(YEAR, -2, GETDATE())
    GROUP BY YEAR(po.orderDate), MONTH(po.orderDate)
)
SELECT TOP 3 year, month, count
FROM MonthCount
ORDER BY count DESC;
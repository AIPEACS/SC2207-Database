USE [<DATABASE>];
GO

-- GETDATE(): TSQL today
-- YEAR(Date): TSQL to get a year form a date
SELECT TOP 3
	month,
	count
FROM (
	SELECT 
		MONTH(po.orderDate) AS month,
		COUNT(po.orderID) AS count
	FROM PurchaseOrder po
	WHERE YEAR(po.orderDate)>= YEAR(GETDATE()) - 2
	GROUP BY MONTH(po.orderDate)
) A
ORDER BY count DESC;
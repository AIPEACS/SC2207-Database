-- GETDATE(): TSQL today
-- YEAR(Date): TSQL to get a year form a date
SELECT
	month,
	rank
FROM (
	SELECT 
		MONTH(po.orderDate) AS month,
		DENSE_RANK() OVER (
			ORDER BY COUNT(po.orderID) DESC
		) AS rank
	FROM PurchaseOrder po
	WHERE YEAR(po.orderDate)>= YEAR(GETDATE()) - 2
	GROUP BY MONTH(po.orderDate)
) A
WHERE rank<=3;
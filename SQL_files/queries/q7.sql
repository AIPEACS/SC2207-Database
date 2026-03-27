SELECT originalLocation, COUNT(*) AS delayCount
FROM Shipment
WHERE DATEDIFF(MONTH, exArrDate, acArrDate) > 6
GROUP BY originalLocation
ORDER BY delayCount DESC

SELECT originalLocation, exArrDate, acArrDate
FROM Shipment
WHERE DATEDIFF(MONTH, exArrDate, acArrDate) > 6
/*
SELECT 
	originalLocation,
	MAX(DATEDIFF(MONTH,exArrDate,acArrDate)) AS delay_M,
	MAX(DATEDIFF(DAY,exArrDate,acArrDate)) AS delay_D
FROM Shipment
GROUP BY originalLocation
HAVING MAX(DATEDIFF(MONTH,exArrDate,acArrDate)) >= 6
ORDER BY delay_D;
*/
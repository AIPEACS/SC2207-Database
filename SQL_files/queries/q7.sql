USE [<DATABASE>];
GO


SELECT originalLocation, COUNT(*) AS delayCount
FROM Shipment
WHERE DATEDIFF(MONTH, exArrDate, acArrDate) > 6
GROUP BY originalLocation
ORDER BY delayCount DESC

SELECT originalLocation, exArrDate, acArrDate
FROM Shipment
WHERE DATEDIFF(MONTH, exArrDate, acArrDate) > 6

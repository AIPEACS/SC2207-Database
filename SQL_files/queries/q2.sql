SELECT w.address, SUM(i.handQty * p.price) AS countryTotalBusiness
FROM Warehouse w
LEFT JOIN Inventory i ON i.warehouseID=w.warehouseID
LEFT JOIN Product p ON p.productID=i.productID
WHERE w.address IN ('Singapore','United States of America')
GROUP BY w.address
ORDER BY countryTotalBusiness DESC
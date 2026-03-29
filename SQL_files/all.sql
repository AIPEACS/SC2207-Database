-- all.sql: return all table rows for every table in the schema
-- Run this in your SQL Server client to inspect every table.
USE [<DATABASE>];
GO

SELECT * FROM Client;
SELECT * FROM Delivery;
SELECT * FROM Driver;
SELECT * FROM Employee;
SELECT * FROM Inventory;
SELECT * FROM InventoryMovement;
SELECT * FROM Item;
SELECT * FROM OrderItem;
SELECT * FROM Product;
SELECT * FROM ProductHandling;
SELECT * FROM PurchaseOrder;
SELECT * FROM Route;
SELECT * FROM ShipItem;
SELECT * FROM Shipment;
SELECT * FROM Shipment_Supplier;
SELECT * FROM Shipment_Warehouse;
SELECT * FROM Staff;
SELECT * FROM Supplier;
SELECT * FROM Supply;
SELECT * FROM Vehicle;
SELECT * FROM Warehouse;
SELECT * FROM Zone;

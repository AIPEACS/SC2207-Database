CREATE table Client
(
clientID INT IDENTITY(1,1) PRIMARY KEY,
serviceTier varchar (255) not null,
companyName varchar (255) not null,
startDate date not null,
contactPerson varchar (255)
);
GO

CREATE table Product
(
productID INT IDENTITY(1,1) PRIMARY KEY,
name varchar (255) not null,
brand varchar (255) not null,
cost DECIMAL(38, 2) not null,
category varchar (255) not null,
price DECIMAL(38, 2) not null,
length DECIMAL(38, 2) not null,
width DECIMAL(38, 2) not null,
height DECIMAL(38, 2) not null
);
GO

CREATE table ProductHandling
(
productID INT,
handlingRequirement varchar(255) not null,
FOREIGN KEY (productID) REFERENCES Product(productID),
PRIMARY KEY (productID, handlingRequirement)
);
GO

CREATE table Supplier
(
supplierID INT IDENTITY(1,1) PRIMARY KEY,
leadTime INT not null,
paymentTerms varchar(255) not null,
name varchar(255) not null,
country varchar(255) not null
);
GO

CREATE table Supply
(
period date not null,
clientID INT not null,
supplierID INT not null,
productID INT not null,
FOREIGN KEY (clientID) REFERENCES Client(clientID),
FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID),
FOREIGN KEY (productID) REFERENCES Product(productID),
PRIMARY KEY (period, clientID, supplierID, productID)
);
GO

CREATE table Warehouse
(
warehouseID INT IDENTITY(1,1) PRIMARY KEY,
address varchar(255) not null,
size DECIMAL(38, 2) not null,
temperature DECIMAL(4, 1) not null,
security varchar(255) not null,
);
GO

CREATE table Zone
(
warehouseID INT not null,
location varchar (255) not null,
code varchar (255) not null,
FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
PRIMARY KEY (warehouseID, location),
);
GO

CREATE table Inventory
(
warehouseID INT not null,
productID INT not null,
clientID INT not null,
serial# INT not null,
reservedQty INT not null,
handQty INT not null,
orderedQty INT not null,
location varchar(255) not null,
FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
FOREIGN KEY (productID) REFERENCES Product(productID),
FOREIGN KEY (clientID) REFERENCES Client(clientID),
PRIMARY KEY (warehouseID, productID, clientID, serial#)
);
GO



CREATE table InventoryMovement
(
warehouseID INT not null,
productID INT not null,
clientID INT not null,
serial# INT not null,
movement varchar(255) not null,
reason varchar(255) not null,
timestamp timestamp not null,
FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
FOREIGN KEY (productID) REFERENCES Product(productID),
FOREIGN KEY (clientID) REFERENCES Client(clientID),
FOREIGN KEY (warehouseID, productID, clientID, serial#)
        REFERENCES Inventory(warehouseID, productID, clientID, serial#),
PRIMARY KEY (warehouseID, productID, clientID, serial#, movement, reason, timestamp)
);
GO

CREATE table Item
(
itemSerial# INT IDENTITY(1,1) PRIMARY KEY,
productID INT not null,
FOREIGN KEY (productID) REFERENCES Product(productID)
);

--OrderItem

CREATE table PurchaseOrder
(
orderID INT IDENTITY(1,1) PRIMARY KEY,
orderDate date not null,
status varchar (255) not null,
);
GO

--PurchaseOrder_Client
--PurchaseOrder_Supplier
--ShipItem

CREATE table Shipment
(
shipmentID INT IDENTITY(1,1) PRIMARY KEY,
exArrDate date not null,
acArrDate date not null,
shippedDate date not null,
originalLocation varchar(255) not null,
trackingNumber INT not null,
orderID INT not null,
FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID)
);
GO

--Shipment_Supplier
--Shipment_Warehouse

CREATE table Staff
(
 staffID INT IDENTITY(1,1) PRIMARY KEY,
 name varchar(255) not null,
 type varchar(255) not null,
 hireDate date not null
 );
GO

CREATE table Employee
(
  staffID INT not null,
  certification VARCHAR(255) not null,
  warehouseID INT not null, 
  FOREIGN KEY (staffID) REFERENCES Staff(staffID),
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
);
GO


--Employee
--Driver
--Vehicle
--Route
--Stop
--Delivery

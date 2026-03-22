CREATE TABLE Client
(
  clientID INT IDENTITY(1,1) PRIMARY KEY,
  serviceTier varchar(255) NOT NULL,
  companyName varchar(255) NOT NULL,
  startDate date NOT NULL,
  contactPerson varchar(255)
);
GO

CREATE TABLE Product
(
  productID INT IDENTITY(1,1) PRIMARY KEY,
  name varchar(255) NOT NULL,
  brand varchar(255) NOT NULL,
  cost DECIMAL(38, 2) NOT NULL,
  category varchar(255) NOT NULL,
  price DECIMAL(38, 2) NOT NULL,
  length DECIMAL(38, 2) NOT NULL,
  width DECIMAL(38, 2) NOT NULL,
  height DECIMAL(38, 2) NOT NULL
);
GO

CREATE TABLE ProductHandling
(
  productID INT,
  handlingRequirement varchar(255) NOT NULL,
  FOREIGN KEY (productID) REFERENCES Product(productID),
  PRIMARY KEY (productID, handlingRequirement)
);
GO

CREATE TABLE Supplier
(
  supplierID INT IDENTITY(1,1) PRIMARY KEY,
  leadTime INT NOT NULL,
  paymentTerms varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  country varchar(255) NOT NULL
);
GO

CREATE TABLE Supply
(
  period date NOT NULL,
  clientID INT NOT NULL,
  supplierID INT NOT NULL,
  productID INT NOT NULL,
  FOREIGN KEY (clientID) REFERENCES Client(clientID),
  FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID),
  FOREIGN KEY (productID) REFERENCES Product(productID),
  PRIMARY KEY (period, clientID, supplierID, productID)
);
GO

CREATE TABLE Warehouse
(
  warehouseID INT IDENTITY(1,1) PRIMARY KEY,
  address varchar(255) NOT NULL,
  size DECIMAL(38, 2) NOT NULL,
  temperature varchar(255) NOT NULL,
  security varchar(255) NOT NULL
);
GO

CREATE TABLE Zone
(
  warehouseID INT NOT NULL,
  location INTEGER NOT NULL,
  code varchar(255) NOT NULL,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
  PRIMARY KEY (warehouseID, location)
);
GO

CREATE TABLE Inventory
(
  warehouseID INT NOT NULL,
  productID INT NOT NULL,
  clientID INT NOT NULL,
  serial# INT NOT NULL,
  reservedQty INT NOT NULL,
  handQty INT NOT NULL,
  orderedQty INT NOT NULL,
  location INT NOT NULL,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
  FOREIGN KEY (productID) REFERENCES Product(productID),
  FOREIGN KEY (clientID) REFERENCES Client(clientID),
  PRIMARY KEY (warehouseID, productID, clientID, serial#)
);
GO



CREATE TABLE InventoryMovement
(
  warehouseID INT NOT NULL,
  productID INT NOT NULL,
  clientID INT NOT NULL,
  serial# INT NOT NULL,
  movement varchar(255) NOT NULL,
  reason varchar(255) NOT NULL,
  timestamp DATETIME2(7) NOT NULL,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
  FOREIGN KEY (productID) REFERENCES Product(productID),
  FOREIGN KEY (clientID) REFERENCES Client(clientID),
  FOREIGN KEY (warehouseID, productID, clientID, serial#)
    REFERENCES Inventory(warehouseID, productID, clientID, serial#),
  PRIMARY KEY (warehouseID, productID, clientID, serial#, timestamp)
);
GO

CREATE TABLE Item
(
  itemSerial# INT IDENTITY(1,1) PRIMARY KEY,
  productID INT NOT NULL UNIQUE,
  FOREIGN KEY (productID) REFERENCES Product(productID)
);
GO

--OrderItem

CREATE TABLE PurchaseOrder
(
  orderID INT IDENTITY(1,1) PRIMARY KEY,
  orderDate date NOT NULL,
  status varchar(255) NOT NULL
);
GO

--PurchaseOrder_Client
--PurchaseOrder_Supplier
--ShipItem

CREATE TABLE Shipment
(
  shipmentID INT IDENTITY(1,1) PRIMARY KEY,
  exArrDate date NOT NULL,
  acArrDate date NOT NULL,
  shippedDate date NOT NULL,
  originalLocation varchar(255) NOT NULL,
  trackingNumber INT NOT NULL,
  orderID INT NOT NULL,
  FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID)
);
GO

--Shipment_Supplier
--Shipment_Warehouse

CREATE TABLE Staff
(
  staffID INT IDENTITY(1,1) PRIMARY KEY,
  name varchar(255) NOT NULL,
  type varchar(255) NOT NULL,
  hireDate date NOT NULL
);
GO

CREATE TABLE Employee
( 
  staffID INT NOT NULL PRIMARY KEY,
  certification varchar(255),
  warehouseID INT NOT NULL,
  FOREIGN KEY (staffID) REFERENCES Staff(staffID) ON DELETE CASCADE,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
);
GO

CREATE TABLE DRIVER 
( 
  staffID INT NOT NULL PRIMARY KEY,
  licenseNumber VARCHAR(255) NOT NULL UNIQUE,
  licenseExpiration DATE NOT NULL,
  vehicleID INT,
  FOREIGN KEY (staffID) REFERENCES Staff(staffID) ON DELETE CASCADE,
  FOREIGN KEY (vehicleID) REFERENCES Vehicle(vehicleID) ON DELETE SET NULL
);
GO


--Employee
--Driver
--Vehicle
--Route
--Stop
--Delivery

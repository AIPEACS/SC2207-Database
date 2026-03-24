CREATE TABLE Client
(
  clientID INT IDENTITY(1,1) PRIMARY KEY,
  serviceTier VARCHAR(255) NOT NULL,
  companyName VARCHAR(255) NOT NULL,
  startDate DATE NOT NULL,
  contactPerson VARCHAR(255)
);
GO

CREATE TABLE Product
(
  productID INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  brand VARCHAR(255) NOT NULL,
  cost DECIMAL(38, 2) NOT NULL,
  category VARCHAR(255) NOT NULL,
  price DECIMAL(38, 2) NOT NULL,
  length DECIMAL(38, 2) NOT NULL,
  width DECIMAL(38, 2) NOT NULL,
  height DECIMAL(38, 2) NOT NULL
);
GO

CREATE TABLE ProductHandling
(
  productID INT NOT NULL,
  handlingRequirement VARCHAR(255) NOT NULL,
  FOREIGN KEY (productID) REFERENCES Product(productID),
  PRIMARY KEY (productID, handlingRequirement)
);
GO

CREATE TABLE Supplier
(
  supplierID INT IDENTITY(1,1) PRIMARY KEY,
  leadTime INT NOT NULL,
  paymentTerms VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL
);
GO

CREATE TABLE Supply
(
  period DATE NOT NULL,
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
  address VARCHAR(255) NOT NULL,
  size DECIMAL(38, 2) NOT NULL,
  temperature DECIMAL(4, 1) NOT NULL,
  security VARCHAR(255) NOT NULL
);
GO

CREATE TABLE Zone
(
  warehouseID INT NOT NULL,
  location VARCHAR(255) NOT NULL,
  code VARCHAR(255) NOT NULL,
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
  location VARCHAR(255) NOT NULL,
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
  movement VARCHAR(255) NOT NULL,
  reason VARCHAR(255) NOT NULL,
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
  productID INT NOT NULL,
  FOREIGN KEY (productID) REFERENCES Product(productID)
);
GO

CREATE TABLE PurchaseOrder
(
  orderID INT IDENTITY(1,1) PRIMARY KEY,
  orderDate DATE NOT NULL,
  status VARCHAR(255) NOT NULL
);
GO

CREATE TABLE PurchaseOrder_Client
(
  orderID INT NOT NULL,
  clientID INT NOT NULL,
  PRIMARY KEY (orderID, clientID),
  FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID),
  FOREIGN KEY (clientID) REFERENCES Client(clientID)
);
GO

CREATE TABLE PurchaseOrder_Supplier
(
  orderID INT NOT NULL,
  supplierID INT NOT NULL,
  PRIMARY KEY (orderID, supplierID),
  FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID),
  FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID)
);
GO

CREATE TABLE Shipment
(
  shipmentID INT IDENTITY(1,1) PRIMARY KEY,
  exArrDate DATE NOT NULL,
  acArrDate DATE,
  shippedDate DATE,
  originalLocation VARCHAR(255) NOT NULL,
  trackingNumber VARCHAR(255) UNIQUE NOT NULL,
  orderID INT NOT NULL,
  FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID)
);
GO

CREATE TABLE ShipItem
(
  shipmentID INT NOT NULL,
  itemSerial# INT NOT NULL,
  shippedQty INT NOT NULL,
  PRIMARY KEY (shipmentID, itemSerial#),
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID),
  FOREIGN KEY (itemSerial#) REFERENCES Item(itemSerial#)
);
GO

CREATE TABLE Shipment_Supplier
(
  shipmentID INT NOT NULL,
  supplierID INT NOT NULL,
  PRIMARY KEY (shipmentID, supplierID),
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID),
  FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID)
);
GO

CREATE TABLE Shipment_Warehouse
(
  shipmentID INT NOT NULL,
  warehouseID INT NOT NULL,
  PRIMARY KEY (shipmentID, warehouseID),
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID),
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
);
GO

CREATE TABLE Staff
(
  staffID INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(255) NOT NULL,
  hireDate DATE NOT NULL
);
GO

CREATE TABLE Employee
(
  staffID INT NOT NULL PRIMARY KEY,
  certification VARCHAR(255),
  warehouseID INT NOT NULL,
  FOREIGN KEY (staffID) REFERENCES Staff(staffID) ON DELETE CASCADE,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
);
GO

CREATE TABLE Vehicle
(
  vehicleID INT IDENTITY(1,1) PRIMARY KEY,
  licensePlate VARCHAR(16) UNIQUE NOT NULL,
  vehicleType VARCHAR(32) NOT NULL,
  capacity INT NOT NULL
);
GO

CREATE TABLE Driver
(
  staffID INT NOT NULL PRIMARY KEY,
  licenseNumber VARCHAR(255) NOT NULL UNIQUE,
  licenseExpiration DATE NOT NULL,
  vehicleID INT,
  FOREIGN KEY (staffID) REFERENCES Staff(staffID) ON DELETE CASCADE,
  FOREIGN KEY (vehicleID) REFERENCES Vehicle(vehicleID) ON DELETE SET NULL
);
GO

CREATE TABLE Route
(
  routeID INT IDENTITY(1,1) PRIMARY KEY,
  totalDistance INT NOT NULL,
  status VARCHAR(16) NOT NULL
);
GO

CREATE TABLE Stop
(
  routeID INT NOT NULL,
  sequence VARCHAR(255) NOT NULL,
  actArrTime DATETIME NOT NULL,
  PRIMARY KEY (routeID, sequence),
  FOREIGN KEY (routeID) REFERENCES Route(routeID)
);
GO

CREATE TABLE Delivery
(
  routeID INT NOT NULL,
  vehicleID INT NOT NULL,
  warehouseID INT NOT NULL,
  shipmentID INT NOT NULL,
  date DATETIME NOT NULL,
  PRIMARY KEY (routeID, vehicleID, warehouseID, shipmentID, date),
  FOREIGN KEY (routeID) REFERENCES Route(routeID),
  FOREIGN KEY (vehicleID) REFERENCES Vehicle(vehicleID),
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
);
GO

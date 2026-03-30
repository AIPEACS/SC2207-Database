USE [<DATABASE>];
GO
/*
  Client(clientID, serviceTier, companyName, startDate, contactPerson)
  Key: clientID
  Primary key: clientID
  Dependency:
    clientID -> serviceTier, companyName, startDate, contactPerson
*/
CREATE TABLE Client
(
  clientID INT IDENTITY(1,1) PRIMARY KEY,
  serviceTier VARCHAR(255) NOT NULL,
  companyName VARCHAR(255) NOT NULL,
  startDate DATE NOT NULL,
  contactPerson VARCHAR(255)
);
GO

/*
  Product(productID, name, brand, cost, category, price, length, width, height)
  Key: productID
  Primary key: productID
  Dependency:
    productID -> name, brand, cost, category, price, length, width, height
*/
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

/*
  ProductHandling(productID, handlingRequirement)
  Key: (productID, handlingRequirement)
  Primary key: (productID, handlingRequirement)
*/
CREATE TABLE ProductHandling
(
  productID INT NOT NULL,
  handlingRequirement VARCHAR(255) NOT NULL,
  FOREIGN KEY (productID) REFERENCES Product(productID)
    ON DELETE CASCADE,
  PRIMARY KEY (productID, handlingRequirement)
);
GO

/*
  Supplier(supplierID, leadTime, paymentTerms, name, country)
  Key: supplierID
  Primary key: supplierID
  Dependency:
    supplierID -> leadTime, paymentTerms, name, country
*/
CREATE TABLE Supplier
(
  supplierID INT IDENTITY(1,1) PRIMARY KEY,
  leadTime INT NOT NULL,
  paymentTerms VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL
);
GO

/*
  Supply(period, clientID, supplierID, productID)
  Key: (period, clientID, supplierID, productID)
  Primary key: (period, clientID, supplierID, productID)
  Dependency: None
*/
CREATE TABLE Supply
(
  period DATE NOT NULL,
  clientID INT NOT NULL,
  supplierID INT NOT NULL,
  productID INT NOT NULL,
  FOREIGN KEY (clientID) REFERENCES Client(clientID)
    ON DELETE CASCADE,
  FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID)
    ON DELETE CASCADE,
  FOREIGN KEY (productID) REFERENCES Product(productID) 
    ON DELETE CASCADE,
  PRIMARY KEY (period, clientID, supplierID, productID)
);
GO

/*
  Warehouse(warehouseID, address, size, temperature, security)
  Key: warehouseID
  Primary key: warehouseID
  Dependency:
    warehouseID -> address, size, temperature, security
*/
CREATE TABLE Warehouse
(
  warehouseID INT IDENTITY(1,1) PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  size DECIMAL(38, 2) NOT NULL,
  temperature VARCHAR(255) NOT NULL,
  security VARCHAR(255) NOT NULL
);
GO

/*
  Zone(warehouseID, location, code)
  Key: (warehouseID, location)
  Primary key: (warehouseID, location)
  Dependency:
    warehouseID, location -> code
*/
CREATE TABLE Zone
(
  warehouseID INT NOT NULL,
  location VARCHAR(255) NOT NULL,
  code VARCHAR(255) NOT NULL,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
    ON DELETE CASCADE,
  PRIMARY KEY (warehouseID, location)
);
GO

/*
  Inventory(warehouseID, productID, clientID, serial#, reservedQty, handQty, orderedQty, location)
  Key: (warehouseID, productID, clientID, serial#)
  Primary key: (warehouseID, productID, clientID, serial#)
  Dependency:
    warehouseID, productID, clientID, serial# -> reservedQty, handQty, orderedQty, location
*/
CREATE TABLE Inventory
(
  warehouseID INT NOT NULL,
  productID INT NOT NULL,
  clientID INT NOT NULL,
  serial# INT NOT NULL,
  reservedQty INT NOT NULL,
  handQty INT NOT NULL,
  -- saleQty = handQty - reservedQty
  orderedQty INT NOT NULL,
  location VARCHAR(255) NOT NULL,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
    ON DELETE CASCADE,
  FOREIGN KEY (productID) REFERENCES Product(productID)
    ON DELETE CASCADE,
  FOREIGN KEY (clientID) REFERENCES Client(clientID)
    ON DELETE CASCADE,
  PRIMARY KEY (warehouseID, productID, clientID, serial#)
);
GO

/*
  InventoryMovement(warehouseID, productID, clientID, serial#, movement, reason, timestamp)
  Key: (warehouseID, productID, clientID, serial#, timestamp)
  Primary key: (warehouseID, productID, clientID, serial#, timestamp)
*/
CREATE TABLE InventoryMovement
(
  warehouseID INT NOT NULL,
  productID INT NOT NULL,
  clientID INT NOT NULL,
  serial# INT NOT NULL,
  movement VARCHAR(255) NOT NULL,
  reason VARCHAR(255) NOT NULL,
  timestamp DATETIME2(7) NOT NULL,
  FOREIGN KEY (warehouseID, productID, clientID, serial#)
    REFERENCES Inventory(warehouseID, productID, clientID, serial#)
    ON DELETE CASCADE,
  PRIMARY KEY (warehouseID, productID, clientID, serial#, timestamp)
);
GO

/*
  Item(itemSerial#, productID)
  Key: itemSerial#, productID
  Primary key: itemSerial#
  Dependency:
    itemSerial# -> productID
    productID -> itemSerial#
*/
CREATE TABLE Item
(
  itemSerial# INT IDENTITY(1,1) PRIMARY KEY,
  productID INT NOT NULL UNIQUE,
  FOREIGN KEY (productID) REFERENCES Product(productID)
    ON DELETE CASCADE
);
GO

/*
  PurchaseOrder(orderID, orderDate, status)
  Key: orderID
  Primary key: orderID
  Dependency:
    orderID -> orderDate, status
  derived value = SUM(orderQty x unitPrice)).
*/
CREATE TABLE PurchaseOrder
(
  orderID INT IDENTITY(1,1) PRIMARY KEY,
  orderDate DATE NOT NULL,
  status VARCHAR(255) NOT NULL
);
GO

/*
  PurchaseOrder_Client(orderID, clientID)
  Key: (orderID, clientID)
  Primary key: (orderID, clientID)
  Dependency: None
*/
/*
CREATE TABLE PurchaseOrder_Client
(
  orderID INT NOT NULL,
  clientID INT NOT NULL,
  PRIMARY KEY (orderID, clientID),
  FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID)
    ON DELETE CASCADE,
  FOREIGN KEY (clientID) REFERENCES Client(clientID)
    ON DELETE CASCADE
);
GO
*/

/*
  PurchaseOrder_Supplier(orderID, supplierID)
  Key: (orderID, supplierID)
  Primary key: (orderID, supplierID)
  Dependency: None
*/
CREATE TABLE PurchaseOrder_Supplier
(
  orderID INT NOT NULL,
  supplierID INT NOT NULL,
  PRIMARY KEY (orderID, supplierID),
  FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID)
    ON DELETE CASCADE,
  FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID)
    ON DELETE CASCADE
);
GO

/*
  OrderItem(orderID, serial#, exDelDate, unitPrice, orderedQty)
  Key: (orderID, serial#)
  Primary key: (orderID, serial#)
  Dependency:
    orderID, serial# -> exDelDate, unitPrice, orderedQty
*/
-- CREATE TABLE OrderItem
-- (
--   orderID INT NOT NULL,
--   itemSerial# INT NOT NULL,
--   exDelDate DATE NOT NULL,
--   unitPrice DECIMAL(38, 2) NOT NULL,
--   orderedQty INT NOT NULL,
--   PRIMARY KEY (orderID, itemSerial#),
--   FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID)
--     ON DELETE CASCADE,
--   FOREIGN KEY (itemSerial#) REFERENCES Item(itemSerial#)
--     ON DELETE CASCADE
-- );
-- GO
CREATE TABLE OrderItem
(
  orderID INT NOT NULL,
  serial# INT NOT NULL,
  productID INT NOT NULL,
  clientID INT NOT NULL,
  warehouseID INT NOT NULL,
  supplierID INT NOT NULL,
  exDelDate DATE NOT NULL,
  unitPrice DECIMAL(38, 2) NOT NULL,
  orderedQty INT NOT NULL,
  PRIMARY KEY (orderID, serial#, productID, clientID, warehouseID, supplierID),
  FOREIGN KEY (orderID) REFERENCES PurchaseOrder(orderID)
    ON DELETE CASCADE,
  FOREIGN KEY (warehouseID, productID, clientID, serial#) REFERENCES Inventory(warehouseID, productID, clientID, serial#)
    ON DELETE CASCADE,
  FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID)
    ON DELETE CASCADE
);
GO;

/*
  Shipment(shipmentID, exArrDate, acArrDate, shippedDate, originalLocation, trackingNumber, orderID)
  Key: shipmentID, trackingNumber
  Primary key: shipmentID
  Dependency:
    shipmentID -> trackingNumber, exArrDate, acArrDate, shippedDate, originalLocation, orderID
    trackingNumber -> shipmentID, exArrDate, acArrDate, shippedDate, originalLocation, orderID
*/
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
    ON DELETE CASCADE
);
GO

/*
  ShipItem(shipmentID, serial#, shippedQty)
  Key: (shipmentID, serial#)
  Primary key: (shipmentID, serial#)
  Dependency:
    shipmentID, serial# -> shippedQty
*/
CREATE TABLE ShipItem
(
  shipmentID INT NOT NULL,
  itemSerial# INT NOT NULL,
  shippedQty INT NOT NULL,
  PRIMARY KEY (shipmentID, itemSerial#),
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
    ON DELETE CASCADE,
  FOREIGN KEY (itemSerial#) REFERENCES Item(itemSerial#)
    ON DELETE CASCADE
);
GO

/*
  Shipment_Supplier(shipmentID, supplierID)
  Key: (shipmentID, supplierID)
  Primary key: (shipmentID, supplierID)
  Dependency: None
*/
CREATE TABLE Shipment_Supplier
(
  shipmentID INT NOT NULL,
  supplierID INT NOT NULL,
  PRIMARY KEY (shipmentID, supplierID),
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
    ON DELETE CASCADE,
  FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID)
    ON DELETE CASCADE
);
GO

/*
  Shipment_Warehouse(shipmentID, warehouseID)
  Key: (shipmentID, warehouseID)
  Primary key: (shipmentID, warehouseID)
  Dependency: None
*/
CREATE TABLE Shipment_Warehouse
(
  shipmentID INT NOT NULL,
  warehouseID INT NOT NULL,
  PRIMARY KEY (shipmentID, warehouseID),
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
    ON DELETE CASCADE,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
    ON DELETE CASCADE
);
GO

/*
  Staff(staffID, name, type, hireDate)
  Key: staffID
  Primary key: staffID
  Dependency:
    staffID -> name, type, hireDate
*/
CREATE TABLE Staff
(
  staffID INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(255) NOT NULL,
  hireDate DATE NOT NULL
);
GO

/*
  Employee(staffID, certification, warehouseID)
  Key: staffID
  Primary key: staffID
  Dependency:
    staffID -> certification, warehouseID
*/
CREATE TABLE Employee
(
  staffID INT NOT NULL PRIMARY KEY,
  certification VARCHAR(255),
  warehouseID INT NOT NULL,
  FOREIGN KEY (staffID) REFERENCES Staff(staffID) 
    ON DELETE CASCADE,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
    ON DELETE CASCADE
);
GO

/*
  Vehicle(vehicleID, type, licensePlate, capacity)
  Key: vehicleID, licensePlate
  Primary key: vehicleID
  Dependency:
    vehicleID -> type, licensePlate, capacity
    licensePlate -> vehicleID, type, capacity
*/
CREATE TABLE Vehicle
(
  vehicleID INT IDENTITY(1,1) PRIMARY KEY,
  licensePlate VARCHAR(16) UNIQUE NOT NULL,
  vehicleType VARCHAR(32) NOT NULL,
  capacity INT NOT NULL
);
GO

/*
  Driver(staffID, licenseNumber, licenseExpiration, vehicleID)
  Key: staffID, licenseNumber
  Primary key: staffID
  Dependency:
    staffID -> licenseNumber, licenseExpiration, vehicleID
    licenseNumber -> staffID, licenseExpiration, vehicleID
*/
CREATE TABLE Driver
(
  staffID INT NOT NULL PRIMARY KEY,
  licenseNumber VARCHAR(255) NOT NULL UNIQUE,
  licenseExpiration DATE NOT NULL,
  vehicleID INT,
  FOREIGN KEY (staffID) REFERENCES Staff(staffID) 
    ON DELETE CASCADE,
  FOREIGN KEY (vehicleID) REFERENCES Vehicle(vehicleID) 
    ON DELETE SET NULL
);
GO

/*
  Route(routeID, totalDistance, status)
  Key: routeID
  Primary key: routeID
  Dependency:
    routeID -> totalDistance, status
*/
CREATE TABLE Route
(
  routeID INT IDENTITY(1,1) PRIMARY KEY,
  totalDistance INT NOT NULL,
  status VARCHAR(16) NOT NULL
);
GO

/*
  Stop(routeID, sequence, estArrTime, actArrTime)
  Key: (routeID, sequence)
  Primary key: (routeID, sequence)
  Dependency:
    routeID, sequence -> estArrTime, actArrTime
*/
CREATE TABLE Stop
(
  routeID INT NOT NULL,
  sequence VARCHAR(255) NOT NULL,
  estArrTime DATETIME NOT NULL,
  actArrTime DATETIME,
  PRIMARY KEY (routeID, sequence),
  FOREIGN KEY (routeID) REFERENCES Route(routeID)
    ON DELETE CASCADE
);
GO

/*
  Delivery(routeID, vehicleID, warehouseID, shipmentID, date)
  Key: (routeID, vehicleID, warehouseID, shipmentID, date)
  Primary key: (routeID, vehicleID, warehouseID, shipmentID, date)
  Dependency: None
*/
CREATE TABLE Delivery
(
  routeID INT NOT NULL,
  vehicleID INT NOT NULL,
  warehouseID INT NOT NULL,
  shipmentID INT NOT NULL,
  date DATETIME NOT NULL,
  PRIMARY KEY (routeID, vehicleID, warehouseID, shipmentID, date),
  FOREIGN KEY (routeID) REFERENCES Route(routeID)
    ON DELETE CASCADE,
  FOREIGN KEY (vehicleID) REFERENCES Vehicle(vehicleID)
    ON DELETE CASCADE,
  FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
    ON DELETE CASCADE,
  FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
    ON DELETE CASCADE
);
GO

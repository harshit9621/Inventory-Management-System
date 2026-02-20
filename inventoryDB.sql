DROP DATABASE IF EXISTS InventoryDB;
CREATE DATABASE InventoryDB;
USE InventoryDB;

-- 1. PRODUCT: Central catalog of items
CREATE TABLE Product (
  ProductID       INT            PRIMARY KEY,
  Name            VARCHAR(100)   NOT NULL,
  Category        VARCHAR(50),
  UnitPrice       DECIMAL(10,2)  NOT NULL,
  UnitsInStock    INT            NOT NULL DEFAULT 0,
  ReorderLevel    INT            NOT NULL DEFAULT 0
);

-- 2. SUPPLIER: Vendors who supply products
CREATE TABLE Supplier (
  SupplierID      INT            PRIMARY KEY,
  Name            VARCHAR(100)   NOT NULL,
  ContactPerson   VARCHAR(100),
  Phone           VARCHAR(20),
  Email           VARCHAR(100),
  Address         VARCHAR(255)
);

-- 3. PURCHASEORDER: Orders placed to suppliers
CREATE TABLE PurchaseOrder (
  POID                  INT            PRIMARY KEY,
  SupplierID            INT            NOT NULL,
  OrderDate             DATE           NOT NULL,
  ExpectedDeliveryDate  DATE,
  Status                VARCHAR(20)    NOT NULL DEFAULT 'PLACED',
  FOREIGN KEY (SupplierID)
    REFERENCES Supplier(SupplierID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 4. PURCHASEORDERDETAIL: Line-items within each PO (weak entity)
CREATE TABLE PurchaseOrderDetail (
  POID            INT            NOT NULL,
  ProductID       INT            NOT NULL,
  QuantityOrdered INT            NOT NULL,
  UnitPrice       DECIMAL(10,2)  NOT NULL,
  PRIMARY KEY (POID, ProductID),
  FOREIGN KEY (POID)
    REFERENCES PurchaseOrder(POID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (ProductID)
    REFERENCES Product(ProductID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 5. CUSTOMER: Buyers who place sales orders
CREATE TABLE Customer (
  CustomerID     INT            PRIMARY KEY,
  Name           VARCHAR(100)   NOT NULL,
  Phone          VARCHAR(20),
  Email          VARCHAR(100),
  Address        VARCHAR(255)
);

-- 6. SALESORDER: Orders placed by customers
CREATE TABLE SalesOrder (
  SOID           INT            PRIMARY KEY,
  CustomerID     INT            NOT NULL,
  OrderDate      DATE           NOT NULL,
  ShipDate       DATE,
  Status         VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
  FOREIGN KEY (CustomerID)
    REFERENCES Customer(CustomerID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 7. SALESORDERDETAIL: Line-items within each sales order (weak entity)
CREATE TABLE SalesOrderDetail (
  SOID            INT           NOT NULL,
  ProductID       INT           NOT NULL,
  QuantitySold    INT           NOT NULL,
  UnitPrice       DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (SOID, ProductID),
  FOREIGN KEY (SOID)
    REFERENCES SalesOrder(SOID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (ProductID)
    REFERENCES Product(ProductID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 8. INVENTORYTRANSACTION: Audit of every stock movement
CREATE TABLE InventoryTransaction (
  TransactionID   BIGINT AUTO_INCREMENT PRIMARY KEY,
  ProductID       INT           NOT NULL,
  Type            ENUM('RECEIPT','ISSUE','ADJUST','TRANSFER') NOT NULL,
  Quantity        INT           NOT NULL,
  TransactionTime DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ReferenceID     VARCHAR(50),       -- e.g., POID, SOID, or adjustment code
  FromLocation    VARCHAR(50),       -- for TRANSFERs
  ToLocation      VARCHAR(50),       -- for TRANSFERs
  LoggedBy        VARCHAR(50),       -- user or device ID
  Notes           TEXT,
  FOREIGN KEY (ProductID)
    REFERENCES Product(ProductID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);


-- 1. PRODUCTS
INSERT INTO Product (ProductID, Name, Category, UnitPrice, UnitsInStock, ReorderLevel) VALUES
  (1, 'Widget A', 'Hardware',    10.00,  5, 10),   -- below reorder
  (2, 'Gadget B', 'Electronics',  25.00, 20, 15),   -- above reorder
  (3, 'Tool C',   'Hardware',     15.00,  0,  5),   -- out of stock
  (4, 'Part D',   'Components',    5.50, 50, 20),   -- plenty on hand
  (5, 'Device E', 'Electronics',  100.00, 2,  5);   -- near reorder

-- 2. SUPPLIERS
INSERT INTO Supplier (SupplierID, Name, ContactPerson, Phone, Email, Address) VALUES
  (1, 'Acme Supplies',  'John Doe',  '123-4567', 'acme@example.com',   '123 Main St'),
  (2, 'Global Parts',   'Jane Smith','987-6543', 'global@example.com', '456 Elm St');

-- 3. PURCHASE ORDERS (PO)
INSERT INTO PurchaseOrder (POID, SupplierID, OrderDate, ExpectedDeliveryDate, Status) VALUES
  (1001, 1, '2025-07-01', '2025-07-05', 'PLACED'),
  (1002, 2, '2025-07-02', '2025-07-07', 'RECEIVED');

-- 4. PURCHASEORDERDETAIL (line-items for POs)
INSERT INTO PurchaseOrderDetail (POID, ProductID, QuantityOrdered, UnitPrice) VALUES
  (1001, 1, 20, 10.00),  -- reorder Widget A from Acme
  (1001, 3, 10, 15.00),  -- order Tool C
  (1002, 4, 30,  5.50);  -- already received Part D

-- 5. CUSTOMERS
INSERT INTO Customer (CustomerID, Name, Phone, Email, Address) VALUES
  (1, 'Alice', '555-0001', 'alice@domain.com', '789 Maple St'),
  (2, 'Bob',   '555-0002', 'bob@domain.com',   '321 Oak St');

-- 6. SALES ORDERS (SO)
INSERT INTO SalesOrder (SOID, CustomerID, OrderDate, ShipDate, Status) VALUES
  (2001, 1, '2025-07-03', '2025-07-04', 'PENDING'),
  (2002, 2, '2025-07-04', NULL,         'PENDING');

-- 7. SALESORDERDETAIL (line-items for SOs)
INSERT INTO SalesOrderDetail (SOID, ProductID, QuantitySold, UnitPrice) VALUES
  (2001, 2,  5, 25.00),  -- Alice buys 5 Gadget B
  (2001, 5,  2,100.00),  -- Alice buys 2 Device E
  (2002, 1,  3, 10.00),  -- Bob buys 3 Widget A
  (2002, 3,  1, 15.00);  -- Bob buys 1 Tool C

-- 8. INVENTORY TRANSACTIONS (Historical Data)
INSERT INTO InventoryTransaction (
  ProductID, Type, Quantity, TransactionTime, ReferenceID,
  FromLocation, ToLocation, LoggedBy, Notes
) VALUES
  (1, 'RECEIPT', 20, '2025-07-05 10:00:00', '1001', NULL, NULL, 'system', 'PO #1001 receipt, Widget A'),
  (3, 'RECEIPT', 10, '2025-07-05 10:05:00', '1001', NULL, NULL, 'system', 'PO #1001 receipt, Tool C'),
  (4, 'RECEIPT', 30, '2025-07-07 09:00:00', '1002', NULL, NULL, 'system', 'PO #1002 receipt, Part D'),
  (2, 'ISSUE',   5, '2025-07-04 15:00:00', '2001', NULL, NULL, 'system', 'SO #2001 issue, Gadget B'),
  (5, 'ISSUE',   2, '2025-07-04 15:05:00', '2001', NULL, NULL, 'system', 'SO #2001 issue, Device E'),
  (1, 'ISSUE',   3, '2025-07-05 11:00:00', '2002', NULL, NULL, 'system', 'SO #2002 issue, Widget A'),
  (3, 'ISSUE',   1, '2025-07-05 11:05:00', '2002', NULL, NULL, 'system', 'SO #2002 issue, Tool C'),
  (2, 'ADJUST', -2, '2025-07-06 12:00:00', 'ADJ100', NULL, NULL, 'operator', 'Cycle count correction, Gadget B'),
  (2, 'TRANSFER', 10, '2025-07-06 13:00:00', 'TRF200', 'WH1', 'WH2', 'operator', 'Transfer Gadget B WH1->WH2');
  
  
-- AUTOMATION TRIGGERS
DELIMITER //

-- Trigger 1: Auto-update Stock on PURCHASE (Receipts)
CREATE TRIGGER AfterPurchaseOrderInsert
AFTER INSERT ON PurchaseOrderDetail
FOR EACH ROW
BEGIN
    -- Increase stock in Product table
    UPDATE Product 
    SET UnitsInStock = UnitsInStock + NEW.QuantityOrdered
    WHERE ProductID = NEW.ProductID;

    -- Log the transaction automatically
    INSERT INTO InventoryTransaction (ProductID, Type, Quantity, ReferenceID, LoggedBy, Notes)
    VALUES (NEW.ProductID, 'RECEIPT', NEW.QuantityOrdered, CAST(NEW.POID AS CHAR(50)), 'System_Trigger', CONCAT('Auto-Receipt for PO #', NEW.POID));
END; //

-- Trigger 2: Auto-update Stock on SALE (Issues)
CREATE TRIGGER AfterSalesOrderInsert
AFTER INSERT ON SalesOrderDetail
FOR EACH ROW
BEGIN
    -- Decrease stock in Product table
    UPDATE Product 
    SET UnitsInStock = UnitsInStock - NEW.QuantitySold
    WHERE ProductID = NEW.ProductID;

    -- Log the transaction automatically
    INSERT INTO InventoryTransaction (ProductID, Type, Quantity, ReferenceID, LoggedBy, Notes)
    VALUES (NEW.ProductID, 'ISSUE', NEW.QuantitySold, CAST(NEW.SOID AS CHAR(50)), 'System_Trigger', CONCAT('Auto-Issue for SO #', NEW.SOID));
END; //

DELIMITER ;
  
  -- q1
  
SELECT ProductID,
       Name,
       UnitsInStock,
       ReorderLevel
FROM Product
WHERE UnitsInStock < ReorderLevel;


-- q2

SELECT po.POID,
       s.Name      AS SupplierName,
       COUNT(pod.ProductID) AS LineItemCount
FROM PurchaseOrder AS po
JOIN Supplier AS s
  ON po.SupplierID = s.SupplierID
LEFT JOIN PurchaseOrderDetail AS pod
  ON pod.POID = po.POID
GROUP BY po.POID, s.Name;

-- q3

SELECT p.ProductID,
       p.Name,
       SUM(pod.QuantityOrdered) AS TotalOrdered
FROM PurchaseOrderDetail AS pod
JOIN Product AS p
  ON pod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name;

-- q4

SELECT so.SOID,
       c.Name AS CustomerName,
       SUM(sod.QuantitySold * sod.UnitPrice) AS OrderTotal
FROM SalesOrder AS so
JOIN Customer AS c
  ON so.CustomerID = c.CustomerID
JOIN SalesOrderDetail AS sod
  ON sod.SOID = so.SOID
GROUP BY so.SOID, c.Name;

-- q5

SELECT p.ProductID,
       p.Name
FROM Product AS p
LEFT JOIN SalesOrderDetail AS sod
  ON sod.ProductID = p.ProductID
WHERE sod.ProductID IS NULL;

-- q6

SELECT TransactionID,
       Type,
       Quantity,
       TransactionTime,
       ReferenceID
FROM InventoryTransaction
WHERE ProductID = 2
ORDER BY TransactionTime DESC
LIMIT 5;


-- q7

SELECT Category,
       SUM(UnitsInStock * UnitPrice) AS StockValue
FROM Product
GROUP BY Category;
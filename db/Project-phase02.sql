CREATE DATABASE IF NOT EXISTS commerce;
USE commerce;

CREATE Table IF NOT EXISTS Small_Business_Seller
(
    BusinessID int          NOT NULL AUTO_INCREMENT,
    UserName   varchar(100) NOT NULL UNIQUE,
    PassWord   int          Not NULL,
    Email      varchar(50)  NOT NULL,
    Profile    varchar(300) NOT NULL,
    PRIMARY KEY (BusinessID)
);

CREATE TABLE IF NOT EXISTS Orders
(
    OrderID         int          NOT NULL AUTO_INCREMENT,
    Cost            int          NOT NULL,
    PlacedTime      datetime     NOT NULL,
    ShippingAddress varchar(100) NOT NULL,
    Status          int          NOT NULL,
    PRIMARY KEY (OrderID)
);


CREATE TABLE IF NOT EXISTS Products
(
    ProductID             int          NOT NULL AUTO_INCREMENT,
    Price                 int          Not NULL,
    UnitsInStock          int          NOT NULL,
    ProductName           varchar(50)  NOT NULL,
    ProductionDescription varchar(200) NOT NULL,
    BusinessID            int          NOT NULL,
    UnitsSold             int          not null,
    OnSale                boolean      not null default false,
    PRIMARY KEY (ProductID),
    CONSTRAINT fk_06 FOREIGN KEY (BusinessID)
        REFERENCES Small_Business_Seller (BusinessID)
        on update cascade on delete restrict
);


CREATE TABLE IF NOT EXISTS Customers
(
    CustomerID int          NOT NULL AUTO_INCREMENT,
    UserName   varchar(50)  NOT NULL,
    PassWord   varchar(50)  NOT NULL,
    Email      varchar(50)  NOT NULL,
    Address    varchar(100) NOT NULL,
    PRIMARY KEY (CustomerID)
);


CREATE TABLE IF NOT EXISTS Shippers
(
    CompanyName    varchar(100) NOT NULL,
    CompanyAddress varchar(100) NOT NULL,
    Rating         int          NOT NULL,
    PRIMARY KEY (CompanyName)
);

CREATE TABLE IF NOT EXISTS ServiceRepresentative
(
    EmployeeID int NOT NULL AUTO_INCREMENT,
    Phone      varchar(10),
    Name       varchar(50),
    PRIMARY KEY (EmployeeID)
);

CREATE TABLE IF NOT EXISTS OrderDetails
(
    ProductID int NOT NULL,
    OrderID   int NOT NULL,
    Quantity  int NOT NULL,
    PRIMARY KEY (ProductID, OrderID),
    CONSTRAINT fk_08 FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID)
        on update cascade on delete restrict,
    CONSTRAINT fk_09 FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
        on update cascade on delete restrict
);



CREATE TABLE IF NOT EXISTS Card
(
    CustomerID     int          NOT NULL,
    CardNumber     int          NOT NULL,
    ExpirationDate Date         NOT NULL,
    BillingAddress varchar(100) NOT NULL,
    PRIMARY KEY (CardNumber),
    CONSTRAINT fk_20 FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        on update cascade on delete restrict
);


CREATE TABLE IF NOT EXISTS Cart
(
    CustomerID  int NOT NULL,
    TotalItems  int NOT NULL,
    Total_Price int NOT NULL,
    PRIMARY KEY (CustomerID),
    CONSTRAINT fk_19 FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        on update cascade on delete restrict
);

CREATE TABLE IF NOT EXISTS Product_In_Cart
(
    CustomerID int NOT NULL,
    ProductID  int NOT NULL,
    Quantity   int NOT NULL,
    Price      int NOT NULL,
    PRIMARY KEY (CustomerID, ProductID),
    CONSTRAINT fk_01
        FOREIGN KEY (CustomerID) REFERENCES Cart (CustomerID)
            on update cascade on delete restrict,
    CONSTRAINT fk_02
        FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
            on update cascade on delete restrict
);

CREATE TABLE IF NOT EXISTS Service
(
    ServiceID   int                                         NOT NULL AUTO_INCREMENT,
    Type        enum ('Return','Exchange','Repair','Other') NOT NULL,
    CustomerID  int                                         NOT NULL,
    OrderID     int                                         NOT NULL,
    StartTime   datetime                                    NOT NULL,
    EndTime     datetime                                    NOT NULL,
    RepID       int                                         NOT NULL,
    Description varchar(500)                                not null,
    PRIMARY KEY (ServiceID),
    CONSTRAINT fk_16 FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
        on update cascade on delete restrict,
    CONSTRAINT fk_17 FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        on update cascade on delete restrict,
    CONSTRAINT fk_18 FOREIGN KEY (RepID)
        REFERENCES ServiceRepresentative (EmployeeID)
        on update cascade on delete restrict
);

CREATE TABLE IF NOT EXISTS Response
(
    ResponseID int          NOT NULL,
    Contents   varchar(500) NOT NULL,
    Type       enum ('Phone','Website','Email','Carrier Pigeon','Walkie Talkie','Talking'),
    ServiceID  int          NOT NULL,
    EmployeeID int          NOT NULL,
    PRIMARY KEY (ResponseID),
    CONSTRAINT fk_14 FOREIGN KEY (EmployeeID)
        REFERENCES ServiceRepresentative (EmployeeID)
        on update cascade on delete restrict,
    CONSTRAINT fk_15 FOREIGN KEY (ServiceID)
        REFERENCES Service (ServiceID)
        on update cascade on delete restrict
);

CREATE TABLE IF NOT EXISTS Drivers
(
    DriverID                int          NOT NULL AUTO_INCREMENT,
    CompanyName             varchar(100) NOT NULL,
    Age                     int          NOT NULL,
    YearsOfService          int          NOT NULL,
    DriverLicenseExpiration boolean      NOT NULL,
    Phone                   varchar(20)  NOT NULL,
    PRIMARY KEY (DriverID, CompanyName),
    CONSTRAINT fk_05
        FOREIGN KEY (CompanyName) REFERENCES Shippers (CompanyName)
            on update cascade on DELETE restrict
);



CREATE TABLE IF NOT EXISTS Shipping_Detail
(
    TrackingNumber          int          NOT NULL AUTO_INCREMENT,
    DriverID                int          NOT NULL,
    CompanyName             varchar(100) NOT NULL,
    Destination             varchar(100) NOT NULL,
    Estimated_Shipping_TIme datetime     NOT NULL,
    Actual_Estimated_Time   datetime     NOT NULL,
    PackageSize             Int          NOT NULL,
    OrderID                 int          NOT NULL,
    CustomerID              int          NOT NULL,
    PRIMARY KEY (TrackingNumber),
    CONSTRAINT fk_10 FOREIGN KEY (DriverID)
        REFERENCES Drivers (DriverID)
        on update cascade on delete restrict,
    CONSTRAINT fk_11 FOREIGN KEY (CompanyName)
        REFERENCES Shippers (CompanyName)
        on update cascade on delete restrict,
    CONSTRAINT fk_12 FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
        on update cascade on delete restrict,
    CONSTRAINT fk_13 FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        on update cascade on delete restrict
);
#fake data
INSERT INTO Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES
(50, 'seller50', 12345, 'seller50@example.com', 'Profile of seller 50'),
(51, 'seller51', 12346, 'seller51@example.com', 'Profile of seller 51');

INSERT INTO Orders (OrderID, Cost, PlacedTime, ShippingAddress, Status) VALUES
(50, 1000, '2024-04-02 10:00:00', '123 Main St, Anytown', 1),
(51, 1500, '2024-04-03 11:00:00', '456 Elm St, Sometown', 2);

INSERT INTO Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES
(50, 200, 10, 'Product 50', 'Description of product 50', 50, 5, false),
(51, 300, 15, 'Product 51', 'Description of product 51', 51, 3, true);

INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES
(50, 'customer50', 'password50', 'customer50@example.com', '789 Pine St, Yourtown'),
(51, 'customer51', 'password51', 'customer51@example.com', '101 Oak St, Mytown');

INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES
('Shipper50', '100 Shipper St, Shippertown', 5),
('Shipper51', '200 Shipper Ave, Shipville', 4);

INSERT INTO ServiceRepresentative (EmployeeID, Phone, Name) VALUES
(50, '1234567890', 'Rep 50'),
(51, '0987654321', 'Rep 51');

INSERT INTO OrderDetails (ProductID, OrderID, Quantity) VALUES
(50, 50, 1),
(51, 51, 2);

INSERT INTO Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES
(50, 50000000, '2025-12-31', '123 Main St, Anytown'),
(51, 51000000, '2026-12-31', '456 Elm St, Sometown');

INSERT INTO Cart (CustomerID, TotalItems, Total_Price) VALUES
(50, 3, 600),
(51, 2, 500);

INSERT INTO Product_In_Cart (CustomerID, ProductID, Quantity, Price) VALUES
(50, 50, 1, 200),
(51, 51, 1, 300);

INSERT INTO Service (ServiceID, Type, CustomerID, OrderID, StartTime, EndTime, RepID, Description) VALUES
(50, 'Return', 50, 50, '2024-04-02 12:00:00', '2024-04-03 12:00:00', 50, 'Return of Product 50'),
(51, 'Repair', 51, 51, '2024-04-03 14:00:00', '2024-04-04 14:00:00', 51, 'Repair of Product 51');

INSERT INTO Response (ResponseID, Contents, Type, ServiceID, EmployeeID) VALUES
(50, 'Response for Service 50', 'Email', 50, 50),
(51, 'Response for Service 51', 'Phone', 51, 51);

INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES
(50, 'Shipper50', 35, 10, false, '1234567890'),
(51, 'Shipper51', 40, 15, true, '0987654321');

INSERT INTO Shipping_Detail (TrackingNumber, DriverID, CompanyName, Destination, Estimated_Shipping_TIme, Actual_Estimated_Time, PackageSize, OrderID, CustomerID) VALUES
(50, 50, 'Shipper50', '789 Pine St, Yourtown', '2024-04-05 10:00:00', '2024-04-05 12:00:00', 3, 50, 50),
(51, 51, 'Shipper51', '101 Oak St, Mytown', '2024-04-06 11:00:00', '2024-04-06 13:00:00', 2, 51, 51);


# 1.1 As a Small Business Seller, I would like to easily list my products with
# detailed descriptions and images, so that customers can fully understand
# and appreciate the quality and uniqueness of my offerings.
INSERT INTO Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile)
VALUES (1, 'Alex Rivera', 1234, 'alex.rivera@gmail.com',
        'I am a small business seller who sells handmade jewelry.
 I have been in business for 5 years and have a passion for creating unique pieces.');
# 1.2 As a Small Business Seller, I want to access detailed analytics about my sales (the revenue for a specific product)
INSERT INTO Products
VALUES (2, 50, 10, 'NonhumanMade Necklace', 'This beautiful necklace is not handcrafted with high-quality materials
and intricate design details.', 1, 0, 1);
INSERT INTO Orders
VALUES (1, 0, '2021-10-01 10:00:00', '2021-10-01 12:00:00', 1);
INSERT INTO OrderDetails
VALUES (2, 1, 10);
UPDATE Orders
SET Cost = (SELECT sum(od.Quantity * p.Price)
            FROM OrderDetails od
                     join Products p on od.ProductID = p.ProductID
            WHERE od.OrderID = 1)
WHERE OrderID = 1;
# 1.3 As a Small Business Seller, I need to be able to manage my
# inventory efficiently on the platform, so I can ensure that my product
# listings are always up to date and avoid overselling or stockouts.
INSERT INTO Products
VALUES (1, 50, 10, 'Handmade Necklace', 'This beautiful necklace is handcrafted with high-quality materials
and intricate design details.', 1, 0, 1);
INSERT INTO OrderDetails
VALUES (1, 1, 10);
UPDATE Products
SET UnitsSold = (SELECT sum(Quantity)
                 FROM OrderDetails od
                 Where od.ProductID = 1)
WHERE ProductID = 1;
#1.4 As a Small Business Seller, I would like to update my
# profile to accurately reflect my up-to-date information
UPDATE Small_Business_Seller
SET Email   = '123@edu.neu',
    Profile = 'The Handmade Necklace will not be available in next three weeks since the final exam'
WHERE BusinessID = 1;
# 1.5 As a Small Business Seller, I would like to apply for a sale for a specific product.
UPDATE Products
SET OnSale = true,
    Price  = 45
Where ProductName = 'Handmade Necklace';
# 2.1 As a customer, I would like to filter products by local small businesses so that I can
# support my community and find unique, locally-made items.
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address)
VALUES (1, 'Aayush Bagga', 'password', 'aayush@gmail.com', '360 Huntington Ave, Boston, MA 02115');


SELECT *
FROM Products
WHERE BusinessID = 1;


# 2.2 As a customer, I want to be able to add products that I wish to buy to my cart.
INSERT INTO Cart (CustomerID, TotalItems, Total_Price)
VALUES (1, 1, 50);

#2.3 As a customer, I would like to track my order in real-time to know exactly when my items will arrive and plan accordingly and to remember when my order actually was received at my place.
INSERT INTO Orders
VALUES (2, 50, '2021-10-01 10:00:00', '360 Huntington Ave, Boston, MA 02115', 1);
INSERT INTO Shippers
VALUES ('ShippingButFast', '345 street', 3.0);
INSERT INTO Drivers
VALUES (1, 'ShippingButFast', 30, 5, TRUE, '123-456-7890');
INSERT INTO Customers
VALUES (4, '123', '456', '678@neu.edu', '123street');
INSERT INTO Shipping_Detail (TrackingNumber, DriverID, CompanyName, Destination, Estimated_Shipping_TIme,
                             Actual_Estimated_Time, PackageSize, OrderID, CustomerID)
VALUES (1, 1, 'ShippingButFast', '360 Huntington Ave, Boston, MA 02115', '2021-10-01 10:00:00', '2021-10-01 12:00:00',
        1, 1, 4);
SELECT Shipping_Detail.Estimated_Shipping_TIme
FROM Shipping_Detail
WHERE CustomerID = 1;
SELECT Shipping_Detail.Actual_Estimated_Time
FROM Shipping_Detail
WHERE CustomerID = 1;

#2.4 As a customer, I would like to submit my service request for a specific order to address any issues or special requirements directly related to that purchase
INSERT INTO ServiceRepresentative
VALUES (123, '12345555', 'bb');
INSERT INTO Service
VALUES (1, 'Exchange', 1, 1, '2021-10-01 10:00:00', '2021-10-01 12:00:00', 123,
        'I want to exchange the products in this order'),
       (2, 'Repair', 1, 1, '2021-10-01 10:00:00', '2021-10-01 12:00:00', 123,
        'I want to exchange the products in this order');

#2.5 As a customer, I would like to add different payment methods
INSERT INTO Card
VALUES (1, 12345, '2021-10-01', '123 street'),
       (1, 23456, '2027-10-01', '123 street');

#3.1 As a Customer Service Rep, I need to have access to a
# comprehensive customer and order database, so I can quickly
# retrieve information and resolve any issues or inquiries that customers may have.
INSERT INTO ServiceRepresentative
VALUES (1, 123456, 'Ali');

INSERT INTO Orders (OrderID, Cost, PlacedTime, Status, ShippingAddress)
VALUES (3, 50, '2021-10-01 10:00:00', 1, '360 Huntington Ave, Boston, MA 02115');


INSERT INTO Card (CustomerID, CardNumber, ExpirationDate, BillingAddress)
VALUES (1, 0000000000, '2021-10-01 10:00:00', '360 Huntington Ave, Boston, MA 02115')
;



INSERT INTO Service
VALUES (1111, 'Return', 1, 1, '2023-10-01 10:00:00', '2021-10-02 10:00:00', 1, 'i want t0 retur')
;


SELECT Customers.CustomerID, Customers.Address, Customers.Email, Customers.Username
FROM Customers;


SELECT Orders.OrderID, Orders.Status, Orders.ShippingAddress
FROM Orders;


SELECT Card.CardNumber, Card.BillingAddress, Card.ExpirationDate
FROM Card
         JOIN Customers ON Card.CustomerID = Customers.CustomerID;


SELECT Service.ServiceID, Service.EndTime, Service.StartTime, Service.Type
FROM Service
         JOIN Customers ON Service.CustomerID = Customers.CustomerID;



#3.2 As a Customer Service Rep, I want to resolve customer issues or complaints
# by providing different services promptly, and maintain high customer satisfaction.
INSERT INTO Orders (OrderID, Cost, PlacedTime, Status, ShippingAddress)
VALUES (4, 50, now(), 1, '361 Huntington Ave, Boston, MA 02115');


INSERT INTO Orders (OrderID, Cost, PlacedTime, Status, ShippingAddress)
VALUES (5, 50, now(), 1, '362 Huntington Ave, Boston, MA 02115');


INSERT INTO Orders (OrderID, Cost, PlacedTime, Status, ShippingAddress)
VALUES (6, 50, now(), 1, '363 Huntington Ave, Boston, MA 02115');


INSERT INTO Orders (OrderID, Cost, PlacedTime, Status, ShippingAddress)
VALUES (7, 50, now(), 1, '364 Huntington Ave, Boston, MA 02115');



INSERT INTO Service
VALUES (10, 'Repair', 1, 4, NOW(), NOW(), 1, 'I want the Exchange the products');


INSERT INTO Service
VALUES (11, 'Return', 1, 5, NOW(), NOW(), 1, 'I want the Exchange the products');


INSERT INTO Service
VALUES (12, 'Exchange', 1, 6, NOW(), NOW(), 1, 'I want the Exchange the products');


INSERT INTO Service
VALUES (13, 'Other', 1, 7, NOW(), NOW(), 1, 'Discount code: 123');
--111111111


SELECT *
FROM Service
WHERE Type = 'Repair'
ORDER BY ServiceID DESC;

SELECT *
FROM Service
WHERE Type = 'Return'
ORDER BY ServiceID DESC;

SELECT *
FROM Service
WHERE Type = 'Exchange'
ORDER BY ServiceID DESC;

SELECT *
FROM Service
WHERE Type = 'Other'
ORDER BY ServiceID DESC;



#3.3 As a Customer Service Rep, I need to be able to manage and track the status of
# customer issues, from the initial report to resolution, to ensure that nothing
# falls through the cracks and customers are kept informed.
UPDATE Service
SET EndTime = NOW()
WHERE OrderID = 4
  AND Type = 'Repair';

UPDATE Service
SET EndTime = NOW()
WHERE OrderID = 5
  AND Type = 'Return';

UPDATE Service
SET EndTime = NOW()
WHERE OrderID = 6
  AND Type = 'Exchange';

UPDATE Service
SET EndTime = NOW()
WHERE OrderID = 7
  AND Type = 'Other';

#3.4 As a Customer Service Rep, I would need to have access to a customer’s
# order so I can help the customer to manage
# any issues related to the order itself (applying discount code/change shipping method/recall a order)

SELECT *
FROM Orders
WHERE OrderID = 7;


UPDATE Orders
SET Cost = 40
Where OrderID = 7;

#3.5As a Customer Service Rep, I need access to resources and product
# information on the platform, so I can provide accurate and helpful
# assistance to customers, enhancing their overall experience.
SELECT *
FROM OrderDetails od
         join Orders o on od.OrderID = o.OrderID
         join Products p on od.ProductID = p.ProductID
WHERE o.OrderID = 7;

# 4.1 As a driver, I would like to know the years of service I've worked so that I can understand my own experience level and expertise.

INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone)
VALUES (2, 'ShippingButFast', 30, 5, TRUE, '123-456-7890');
SELECT Drivers.YearsOfService
FROM Drivers
WHERE DRIVERID = 1;


# 4.2 As a driver, I want to know new orders that need shipping, including details like package size, and destination, to plan my logistics effectively. (Modified since Phase 1)
SELECT *
FROM Shipping_Detail
WHERE DriverID = 1;

# 4.3 As a driver, I need to be able to easily update the shipping status in order to keep the seller and customer informed about the delivery progress. (Modified since Phase 1)
UPDATE Orders
SET Status = 2
WHERE OrderID = 1;

# 4.4 As a driver, I would like to know the estimated time of arrival for each order so that I can plan my delivery route efficiently.
SELECT Shipping_Detail.Estimated_Shipping_TIme
FROM Shipping_Detail
WHERE DriverID = 1;

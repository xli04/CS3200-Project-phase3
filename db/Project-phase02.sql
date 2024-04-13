CREATE DATABASE IF NOT EXISTS commerce;
USE commerce;

CREATE Table IF NOT EXISTS Small_Business_Seller
(
    BusinessID int          NOT NULL AUTO_INCREMENT,
    UserName   varchar(100) NOT NULL UNIQUE,
    PassWord   varchar(50)          Not NULL,
    Email      varchar(50)  NOT NULL,
    Profile    varchar(300) NOT NULL,
    PRIMARY KEY (BusinessID)
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

CREATE TABLE IF NOT EXISTS Orders
(
    OrderID         int          NOT NULL AUTO_INCREMENT,
    Cost            int          NOT NULL,
    PlacedTime      datetime     NOT NULL,
    Status          int          NOT NULL,
    CustomerID       int          NOT NULL,
    PRIMARY KEY (OrderID),
    CONSTRAINT fk_40 FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        on update cascade on delete restrict
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
    CardNumber     varchar(100)          NOT NULL,
    ExpirationDate DATETIME         NOT NULL,
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
    PRIMARY KEY (CustomerID, ProductID),
    CONSTRAINT fk_01
        FOREIGN KEY (CustomerID) REFERENCES Cart (CustomerID)
            on update cascade,
    CONSTRAINT fk_02
        FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
            on update cascade
);

CREATE TABLE IF NOT EXISTS Service
(
    ServiceID   int                                         NOT NULL AUTO_INCREMENT,
    Type        enum ('Return','Exchange','Repair','Other') NOT NULL,
    OrderID     int                                         NOT NULL,
    StartTime   datetime                                    NOT NULL,
    EndTime     datetime                                    NOT NULL,
    Description varchar(500)                                not null,
    PRIMARY KEY (ServiceID),
    CONSTRAINT fk_16 FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
        on update cascade on delete restrict
);

CREATE TABLE IF NOT EXISTS Response
(
    ResponseID int          NOT NULL auto_increment,
    Contents   varchar(500) NOT NULL,
    Type       enum ('Phone','Website','Email','Carrier Pigeon','Walkie Talkie','Talking'),
    ServiceID  int          NOT NULL,
    RepID      int          NOT NULL,
    PRIMARY KEY (ResponseID),
    CONSTRAINT fk_15 FOREIGN KEY (ServiceID)
        REFERENCES Service (ServiceID)
        on update cascade on delete restrict,
    CONSTRAINT fk_22 FOREIGN KEY (RepID)
        REFERENCES ServiceRepresentative (EmployeeID)
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
    Destination             varchar(100) NOT NULL,
    Estimated_Shipping_TIme datetime     NOT NULL,
    Actual_Shipping_Time   datetime     NOT NULL,
    PackageSize             Int          NOT NULL,
    OrderID                 int          NOT NULL,
    CustomerID              int          NOT NULL,
    PRIMARY KEY (TrackingNumber),
    CONSTRAINT fk_10 FOREIGN KEY (DriverID)
        REFERENCES Drivers (DriverID)
        on update cascade on delete restrict,
    CONSTRAINT fk_12 FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
        on update cascade on delete restrict,
    CONSTRAINT fk_13 FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
        on update cascade on delete restrict
);

CREATE TABLE IF not exists BankAccount(
    AccountNumber           varchar(50)  NOT NULL ,
    BankName               varchar(100)          NOT NULL,
    BillAddress              varchar(100) NULL,
    OwnerID     int not null,
    PRIMARY KEY (AccountNumber, OwnerID),
    CONSTRAINT fk_33 FOREIGN KEY (OwnerID)
        REFERENCES Small_Business_Seller (BusinessID)
        on update cascade on delete restrict
);

CREATE TRIGGER cost_update AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE total_cost INT DEFAULT 0;
    SELECT SUM(Products.Price * NEW.Quantity) INTO total_cost
    FROM OrderDetails
    JOIN Products ON Products.ProductID = OrderDetails.ProductID
    WHERE OrderDetails.OrderID = NEW.OrderID;
    UPDATE Orders
    SET Cost = total_cost
    WHERE OrderID = NEW.OrderID;
END;

CREATE TRIGGER sold_update AFTER INSERT on OrderDetails
    FOR EACH ROW
    BEGIN
        DECLARE total_sold int default 0;
        SELECT SUM(OD.Quantity) INTO total_sold
        FROM Orders o join OrderDetails OD on o.OrderID = OD.OrderID
        join Products P on P.ProductID = OD.ProductID
        WHERE OD.ProductID = NEW.ProductID;
        UPDATE Products
        SET  UnitsSold = total_sold
        WHERE ProductID = NEW.ProductID;
    end;

CREATE TRIGGER Check_Quantity_Before_Insert_Update BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE stock INT;
    SELECT UnitsInStock INTO stock
    FROM Products
    WHERE ProductID = NEW.ProductID;
    IF NEW.Quantity > stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Quantity exceeds units in stock.';
    END IF;
END;

CREATE TRIGGER count_num AFTER INSERT on Product_In_Cart
    FOR EACH ROW
    BEGIN
        DECLARE total_num int default 0;
        SELECT SUM(pi.Quantity) INTO total_num
        FROM Product_In_Cart pi join Products p on pi.ProductID = p.ProductID
        join Cart C on pi.CustomerID = C.CustomerID
        WHERE C.CustomerID = NEW.CustomerID;
        UPDATE Cart
        SET TotalItems = total_num
        WHERE CustomerID = NEW.CustomerID;
    end;


CREATE TRIGGER count_price AFTER INSERT on Product_In_Cart
    FOR EACH ROW
    BEGIN
        DECLARE total_cost int default 0;
        SELECT SUM(p.Price * pi.Quantity) INTO total_cost
        FROM Product_In_Cart pi join Products p on pi.ProductID = p.ProductID
        join Cart C on pi.CustomerID = C.CustomerID
        WHERE C.CustomerID = NEW.CustomerID;
        UPDATE Cart
        SET Total_Price = total_cost
        WHERE CustomerID = NEW.CustomerID;
    end;
#fake data
#shippers
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Ankunding, Murray and Romaguera', '6274 Buell Plaza', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Armstrong-Steuber', '56 Caliangt Plaza', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Auer, Renner and Bechtelar', '4827 Crest Line Lane', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Bahringer, Russel and Blanda', '9112 Emmet Road', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Barton and Sons', '19 Florence Pass', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Bechtelar LLC', '40 Kipling Circle', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Brakus-Wisozk', '42 Scott Street', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Buckridge-Kertzmann', '25 Cherokee Road', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Casper-Cremin', '8 Dayton Hill', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Considine-Mante', '8038 Westport Avenue', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Ernser and Sons', '83792 Logan Street', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Feeney, Veum and Wyman', '76 Warrior Street', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Flatley, Ortiz and Yost', '69901 Lillian Crossing', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Frami-Kreiger', '63 Haas Junction', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Frami-Russel', '64 Darwin Trail', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Gerlach LLC', '7455 Vahlen Avenue', 2);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Goodwin-Torp', '9 Bashford Junction', 2);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Goyette LLC', '2 Glendale Drive', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Grady, Kuvalis and Hagenes', '6471 Steensland Place', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Grant-Kohler', '036 Melrose Court', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Hackett Group', '3 Haas Pass', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Harvey LLC', '7 Ramsey Road', 2);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Heathcote Group', '95898 Lindbergh Plaza', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Herman, Kris and Bergstrom', '73811 Stephen Court', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Hilll-Mante', '64689 Caliangt Junction', 2);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Hodkiewicz-Walker', '302 Reinke Street', 2);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Hodkiewicz, Herman and Rowe', '4445 Hermina Circle', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Huel and Sons', '30 Crest Line Parkway', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Kshlerin, Grimes and McDermott', '4482 Thackeray Alley', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Kuphal-Stehr', '8 Calypso Terrace', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Lakin LLC', '949 David Circle', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Larson-Wisoky', '11 Basil Crossing', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Lynch-Carroll', '870 Sundown Junction', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Mertz Inc', '2 Hallows Plaza', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Mitchell-Bergstrom', '426 Waywood Center', 2);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Mohr, Lind and Green', '9660 Cherokee Avenue', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Pouros-Powlowski', '13021 Mayfield Pass', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Rice-Mueller', '6495 Warner Crossing', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Ruecker-King', '49055 Ridgeway Point', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Russel, Wunsch and Durgan', '1 High Crossing Circle', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Schaden-Considine', '6062 Aberg Trail', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Schiller-Botsford', '16 Pond Terrace', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Schmitt-Jacobi', '42591 Thompson Circle', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Shields-Prohaska', '12987 Raven Hill', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Spencer, Terry and Hermann', '953 Scott Place', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Sporer-Gusikowski', '700 Annamark Terrace', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Stamm-Jast', '13000 Loftsgordon Center', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Stiedemann and Sons', '79 Heath Junction', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Terry-Hodkiewicz', '84 Pine View Way', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Torp Group', '8 Dawn Alley', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Torphy Group', '302 Service Center', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Volkman, Larson and Borer', '2712 5th Junction', 1);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Walter-Marvin', '35 Darwin Alley', 4);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Wilkinson, Watsica and McDermott', '336 Holmberg Trail', 3);
INSERT INTO Shippers (CompanyName, CompanyAddress, Rating) VALUES ('Wyman-O\Conner', '23919 Arkansas Way', 4);

#driver
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (1, 'Goyette LLC', 31, 4, 0, '868-687-7090');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (2, 'Hackett Group', 29, 2, 1, '324-350-0070');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (3, 'Pouros-Powlowski', 50, 1, 0, '997-341-4682');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (4, 'Herman, Kris and Bergstrom', 18, 3, 1, '996-648-4730');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (5, 'Feeney, Veum and Wyman', 47, 5, 0, '369-636-5642');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (6, 'Ruecker-King', 20, 2, 1, '979-183-5784');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (7, 'Terry-Hodkiewicz', 25, 5, 1, '556-615-0144');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (8, 'Hilll-Mante', 18, 3, 1, '814-822-0057');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (9, 'Mertz Inc', 35, 4, 1, '291-265-9428');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (10, 'Casper-Cremin', 45, 1, 1, '959-304-5844');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (11, 'Harvey LLC', 32, 4, 1, '731-262-3576');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (12, 'Barton and Sons', 48, 3, 0, '858-426-1399');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (13, 'Grant-Kohler', 29, 2, 1, '931-519-7860');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (14, 'Schiller-Botsford', 34, 4, 0, '286-171-3998');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (15, 'Lakin LLC', 21, 3, 0, '368-650-0200');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (16, 'Rice-Mueller', 26, 2, 0, '206-837-8880');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (17, 'Schaden-Considine', 47, 2, 1, '581-620-2677');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (18, 'Torphy Group', 49, 1, 0, '304-490-2602');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (19, 'Bahringer, Russel and Blanda', 46, 4, 0, '437-669-7566');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (20, 'Stiedemann and Sons', 19, 4, 1, '181-409-3056');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (21, 'Flatley, Ortiz and Yost', 40, 4, 1, '579-636-8015');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (22, 'Frami-Kreiger', 30, 5, 1, '799-475-3255');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (23, 'Gerlach LLC', 31, 2, 0, '796-528-1380');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (24, 'Frami-Russel', 37, 2, 0, '403-706-5782');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (25, 'Russel, Wunsch and Durgan', 38, 2, 1, '650-908-5641');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (26, 'Hodkiewicz, Herman and Rowe', 34, 3, 1, '404-541-7727');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (27, 'Sporer-Gusikowski', 33, 2, 1, '960-384-7030');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (28, 'Schmitt-Jacobi', 18, 2, 1, '291-428-9949');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (29, 'Wilkinson, Watsica and McDermott', 28, 3, 0, '462-817-9654');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (30, 'Shields-Prohaska', 41, 3, 0, '272-157-5445');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (31, 'Bechtelar LLC', 22, 3, 1, '305-449-5950');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (32, 'Walter-Marvin', 29, 1, 0, '160-600-0844');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (33, 'Kshlerin, Grimes and McDermott', 48, 1, 0, '276-552-4735');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (34, 'Goodwin-Torp', 29, 2, 0, '133-957-0903');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (35, 'Larson-Wisoky', 35, 5, 0, '861-112-7298');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (36, 'Mohr, Lind and Green', 49, 1, 0, '532-410-1996');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (37, 'Lynch-Carroll', 39, 1, 1, '706-585-8441');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (38, 'Torp Group', 42, 4, 0, '857-628-9599');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (39, 'Ernser and Sons', 39, 5, 1, '574-559-7120');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (40, 'Grady, Kuvalis and Hagenes', 33, 2, 0, '354-761-3186');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (41, 'Mitchell-Bergstrom', 40, 3, 0, '832-467-0957');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (42, 'Spencer, Terry and Hermann', 35, 4, 0, '486-876-9016');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (43, 'Kuphal-Stehr', 23, 3, 0, '984-638-9390');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (44, 'Armstrong-Steuber', 37, 4, 1, '847-463-0388');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (45, 'Volkman, Larson and Borer', 35, 5, 1, '182-797-0786');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (46, 'Buckridge-Kertzmann', 48, 1, 0, '913-448-7332');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (47, 'Hodkiewicz-Walker', 43, 2, 0, '877-229-6233');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (48, 'Considine-Mante', 29, 5, 1, '945-347-3489');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (49, 'Heathcote Group', 43, 2, 0, '704-251-5950');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (50, 'Brakus-Wisozk', 20, 1, 1, '516-602-4769');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (51, 'Wyman-O\Conner', 34, 4, 1, '473-294-6597');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (52, 'Auer, Renner and Bechtelar', 42, 4, 0, '663-293-2892');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (53, 'Stamm-Jast', 37, 3, 0, '362-816-0042');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (54, 'Huel and Sons', 25, 2, 0, '270-329-0944');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (55, 'Ankunding, Murray and Romaguera', 46, 2, 0, '681-647-1158');
INSERT INTO Drivers (DriverID, CompanyName, Age, YearsOfService, DriverLicenseExpiration, Phone) VALUES (56, 'Goyette LLC', 38, 1, 0, '766-544-6743');

#customers
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (1, 'mpiscot0', 'xY1>\'''8|T3}v+@+Y%', 'rbroomer0@merriam-webster.com', '30431 Daystar Alley');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (2, 'xbrookhouse1', 'lT8}gkX5<(a', 'eskelhorn1@cloudflare.com', '72 Eliot Point');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (3, 'cromanet2', 'vV8*J{emkQHLR', 'jbohje2@techcrunch.com', '62800 Northview Place');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (4, 'dportail3', 'cK2.R>7a!|}rt`', 'alimmer3@bizjournals.com', '220 Ilene Center');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (5, 'jcheccuzzi4', 'iX2~f\'Ydbhb', 'amichelet4@bluehost.com', '05316 Northridge Terrace');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (6, 'npeplay5', 'kX6$\\%gs"~TH', 'tterzi5@google.co.uk', '43016 Prentice Court');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (7, 'hdelorenzo6', 'pQ1+v}{/Q~&N', 'etrayton6@hubpages.com', '5 Waxwing Court');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (8, 'ddarlison7', 'xW3}Xsxn', 'cparlet7@cdc.gov', '69 Arkansas Plaza');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (9, 'mgregoraci8', 'dL4@33&61', 'wpiesold8@bizjournals.com', '913 Gina Court');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (10, 'rcalan9', 'bF1#nicXS', 'adidomenico9@europa.eu', '16587 Riverside Court');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (11, 'dbandea', 'wA5.Kktl5', 'rkennicotta@microsoft.com', '7766 Union Pass');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (12, 'zgreserb', 'mH6$.>zS(CGXRT#\\', 'uoldaleb@deviantart.com', '9 Michigan Way');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (13, 'vvasyukhnovc', 'aI0<$*d$JI4', 'mcuttenc@sphinn.com', '6 Messerschmidt Park');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (14, 'kleyninyed', 'sR5(Z!Jc', 'pdyned@rediff.com', '220 Manley Avenue');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (15, 'nbeauvaise', 'dR6%_Zs="', 'dbritlande@wordpress.org', '13947 Independence Court');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (16, 'afairpoolf', 'yR8=k~!c\\psRy@N\'', 'rhewlingsf@i2i.jp', '849 Burrows Circle');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (17, 'dwedong', 'tG8"y_55st=*)ak', 'ctyrwhittg@patch.com', '263 Spohn Park');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (18, 'sclarkinh', 'aE4@E#(}i+w%', 'ffaceyh@ning.com', '245 School Trail');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (19, 'okebelli', 'lR3|(P41jZ0h+xM', 'fpedleri@adobe.com', '820 Hermina Hill');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (20, 'breadmanj', 'kO8<L(Y7nTE2\'7_', 'mdunabiej@woothemes.com', '8853 Mesta Court');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (21, 'bsuccamorek', 'wW7%JWEyaK', 'clittlekitk@chron.com', '66 Ridgeview Alley');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (22, 'remmanuelil', 'mU2/%tjr<Ilhxy', 'sworgenl@marketwatch.com', '65 Drewry Drive');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (23, 'ewoodersonm', 'nH8=E~XUS', 'djirim@hugedomains.com', '5 Pleasure Plaza');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (24, 'bvoasen', 'uO4@WGBxc', 'akleynenn@xinhuanet.com', '55010 Hollow Ridge Park');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (25, 'prexo', 'cU8=zzX2kDvWFf,8', 'ncalveyo@theatlantic.com', '8110 Riverside Crossing');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (26, 'aargentp', 'gM1>(whJv', 'sflipsp@cbslocal.com', '597 Ludington Alley');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (27, 'qmalletrattq', 'lZ9,8@SxW_k', 'rtomasiq@plala.or.jp', '00374 Bluestem Hill');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (28, 'lcaveaur', 'pT1=`Z+)6R', 'ljakucewiczr@ovh.net', '59528 Trailsway Pass');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (29, 'eboyns', 'hH7%60E"', 'kstitsons@netlog.com', '4 Sauthoff Hill');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (30, 'rvanarsdallt', 'iU1%wyVqzH(o?*mT', 'tneaglet@booking.com', '619 Dawn Junction');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (31, 'rgrunbaumu', 'fK6<Wq%&', 'sdennesu@psu.edu', '729 Ridge Oak Way');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (32, 'eswansonv', 'tY3,Ih)2fDR', 'mgrahlv@utexas.edu', '89367 Eagan Place');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (33, 'lsenchenkow', 'zU0?cL(kP0tV9#(j', 'rbassamw@exblog.jp', '17408 Loftsgordon Alley');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (34, 'kalgorex', 'tA7|~b.=H', 'evanarsdalenx@wunderground.com', '10425 Orin Road');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (35, 'gmangeony', 'nF0|hRee5k"Ne', 'mpricketty@blogs.com', '82296 Fallview Plaza');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (36, 'cmatejicz', 'zO8<UABpn3', 'frousellz@trellian.com', '2 Vahlen Point');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (37, 'ccowdry10', 'cV9\\0qOcsz&BvF(', 'iludy10@wufoo.com', '05754 Milwaukee Crossing');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (38, 'vmaciver11', 'zH1}E\\d~f\\uagM', 'hewan11@vinaora.com', '3492 Truax Trail');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (39, 'agres12', 'mV6{.rNqH_', 'cdonnersberg12@techcrunch.com', '6 Heffernan Parkway');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (40, 'fmatteoni13', 'fT9/3=Lo', 'fdeclerc13@macromedia.com', '313 South Alley');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (41, 'dantonioni14', 'tZ7`2giK))b%u1!r', 'jleser14@clickbank.net', '1 Sundown Road');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (42, 'bgoroni15', 'tY4=|B(6dx+j1c@4', 'odury15@tripod.com', '084 Ramsey Street');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (43, 'ndy16', 'dY4=oslm\'%', 'gbennington16@virginia.edu', '03008 Bellgrove Road');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (44, 'jangliss17', 'wI3=14!7m', 'tcrab17@wikimedia.org', '52 Union Drive');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (45, 'kbarter18', 'nY4|FC$_Pt=2(2', 'acolombier18@bluehost.com', '93901 Blackbird Plaza');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (46, 'pfleckness19', 'gA6}h7xJUqR', 'severly19@theguardian.com', '7 Melvin Plaza');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (47, 'arosenshine1a', 'iX2<@uW=RTi@{', 'mgreenly1a@cyberchimps.com', '5 Dakota Center');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (48, 'lsabate1b', 'lO5)_?}d5~', 'ashemmans1b@weibo.com', '614 Ruskin Avenue');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (49, 'mmatthias1c', 'zV0@M12|(', 'tharpin1c@typepad.com', '4 Independence Circle');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (50, 'pternouth1d', 'zV6)Yb+>>LSjl=', 'mmonnelly1d@liveinternet.ru', '3981 Mitchell Road');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (51, 'wpenwell1e', 'hO2<|tw2Bq', 'bflintuff1e@techcrunch.com', '08447 Declaration Junction');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (52, 'aleech1f', 'iE3=@ELp@!1#l~', 'kbotfield1f@pen.io', '441 Menomonie Trail');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (53, 'rsoppit1g', 'wX8~LOhMu?_XJi', 'fllywarch1g@prnewswire.com', '4981 Macpherson Avenue');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (54, 'drayman1h', 'uT0+dGYpcrEs>Nr', 'astroband1h@utexas.edu', '0 Oriole Plaza');
INSERT INTO Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (55, 'ajoan1i', 'oW3=73SfhNzhH', 'kcolvine1i@amazonaws.com', '1 Lyons Point');

#Orders
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (1, 0, '2023-10-15 09:07:19', 2, 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (2, 0, '2023-03-08 12:24:49', 1, 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (3, 0, '2023-03-23 14:16:13', 2, 3);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (4, 0, '2023-09-03 12:16:56', 2, 4);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (5, 0, '2023-08-09 04:11:49', 2, 5);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (6, 0, '2023-07-04 04:17:32', 1, 6);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (7, 0, '2023-05-19 15:06:48', 1, 7);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (8, 0, '2023-03-22 03:11:57', 1, 8);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (9, 0, '2023-06-15 20:26:38', 2, 9);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (10, 0, '2023-06-24 06:45:54', 2, 10);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (11, 0, '2023-03-29 08:10:48', 2, 11);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (12, 0, '2023-11-11 15:29:44', 1, 12);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (13, 0, '2023-07-18 03:19:54', 1, 13);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (14, 0, '2023-12-11 11:54:10', 2, 14);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (15, 0, '2024-01-18 18:14:59', 1, 15);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (16, 0, '2023-03-12 00:53:00', 2, 16);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (17, 0, '2024-02-04 13:55:55', 1, 17);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (18, 0, '2023-07-01 02:18:09', 1, 18);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (19, 0, '2024-01-19 08:37:09', 2, 19);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (20, 0, '2023-12-11 20:28:40', 2, 20);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (21, 0, '2023-08-22 12:18:34', 1, 21);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (22, 0, '2024-01-02 17:29:29', 1, 22);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (23, 0, '2024-02-12 12:21:47', 1, 23);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (24, 0, '2023-07-22 08:06:25', 1, 24);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (25, 0, '2024-01-12 13:12:14', 2, 25);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (26, 0, '2023-09-30 13:57:30', 2, 26);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (27, 0, '2023-05-05 02:00:51', 1, 27);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (28, 0, '2023-06-20 20:09:11', 2, 28);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (29, 0, '2024-03-24 22:23:28', 1, 29);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (30, 0, '2023-10-04 02:24:35', 1, 30);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (31, 0, '2023-12-19 17:54:53', 2, 31);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (32, 0, '2024-02-12 13:28:55', 2, 32);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (33, 0, '2023-06-25 09:32:28', 2, 33);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (34, 0, '2024-01-14 02:11:14', 2, 34);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (35, 0, '2023-08-22 04:08:47', 2, 35);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (36, 0, '2023-08-22 16:00:56', 2, 36);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (37, 0, '2024-01-24 07:09:34', 2, 37);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (38, 0, '2023-07-11 19:32:44', 2, 38);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (39, 0, '2023-11-29 15:17:03', 1, 39);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (40, 0, '2023-12-20 01:06:04', 1, 40);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (41, 0, '2023-08-10 15:55:05', 2, 41);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (42, 0, '2023-09-10 01:44:58', 1, 42);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (43, 0, '2023-03-20 14:11:30', 1, 43);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (44, 0, '2023-07-26 11:10:32', 1, 44);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (45, 0, '2023-05-12 02:25:02', 2, 45);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (46, 0, '2023-03-30 09:00:46', 2, 46);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (47, 0, '2023-09-13 22:02:26', 2, 47);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (48, 0, '2023-12-18 19:50:43', 2, 48);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (49, 0, '2024-02-06 14:09:17', 2, 49);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (50, 0, '2024-01-27 19:40:25', 1, 50);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (51, 0, '2023-06-16 14:26:59', 1, 51);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (52, 0, '2023-07-21 12:18:59', 2, 52);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (53, 0, '2023-11-05 00:46:11', 2, 53);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (54, 0, '2023-04-09 14:24:23', 1, 54);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status, CustomerID) VALUES (55, 0, '2023-03-26 09:00:36', 2, 55);


#Small_Business_Seller
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (1, 'stgrewe0', 'yK5!FxXQ', 'ncristofolo0@google.com', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (2, 'sjseaborne1', 'qX9{SK&h5*B+|z6', 'lhacker1@theglobeandmail.com', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (3, 'splashley2', 'yU2\\lJHl_O9|5>_', 'sabbate2@dropbox.com', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (4, 'sbmainston3', 'eA2,#%`F6n', 'hlynnett3@last.fm', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (5, 'sgabys4', 'nD2+@Uy>/=B`>', 'vmose4@usda.gov', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (6, 'sdcrohan5', 'wB1}F\\CAP_U*ei', 'fvanderplas5@wikipedia.org', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (7, 'smmatteotti6', 'eA3.o_u(L\\n9\'H', 'cdupre6@mozilla.org', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (8, 'svcollison7', 'aL3_(cS3Zh_%9+H*', 'rcooling7@yandex.ru', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (9, 'snburridge8', 'uT8_@FH&}\\n?\\$9', 'ogoning8@parallels.com', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (10, 'sgdoe9', 'kM2,3/#s#T~', 'bsahnow9@nba.com', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (11, 'skellita', 'aZ1#{Oi7v"J', 'bstaga@twitter.com', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (12, 'smspragueb', 'lR9/N|ER8I)6ED{7', 'icookesb@google.it', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (13, 'stcrippinc', 'kK9+\\x`$$qL/p>,y', 'nfranklinc@so-net.ne.jp', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (14, 'sbommanneyd', 'zN3{*fWs+AcR', 'tbernardtd@squarespace.com', 'Team player with strong communication skills');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (15, 'sbbunte', 'sF0.!!Td)', 'btrowsdalle@nps.gov', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (16, 'sjhaskurf', 'pV9*rrqA<8', 'pfranckf@ow.ly', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (17, 'sjelveyg', 'gY0)(w$$4DI4\\n<\'', 'pkyteleyg@mapquest.com', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (18, 'sjmonelleh', 'mL9?\'I9_(p', 'ldraynh@google.co.jp', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (19, 'sflatouri', 'aZ7+rb~1', 'gkeeffei@desdev.cn', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (20, 'spmilleryj', 'bK5*h?94', 'ncancellorj@bing.com', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (21, 'siranscombek', 'sK4\\m5,ZJ', 'sthreadgallk@ustream.tv', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (22, 'sapinnelll', 'vZ7+|DQ,org>.', 'froizinl@nationalgeographic.com', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (23, 'sericardoum', 'cV8_k@+oK?>', 'mfazackerleym@aboutads.info', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (24, 'snshepperdn', 'nH2#XH{a(W', 'cbrindedn@berkeley.edu', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (25, 'sfstroulgero', 'rS8<bd5A*s&TNj', 'pgutowskao@exblog.jp', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (26, 'scscipseyp', 'iR0\'(9oh', 'eringp@gnu.org', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (27, 'srblackeyq', 'qV9`2Na?NTw|ll~h', 'bzollnerq@usda.gov', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (28, 'solisterr', 'nW5%*K+}5cAzGZ', 'wchapellowr@ox.ac.uk', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (29, 'shmattersons', 'lD4$aLle"P\'T', 'nparratts@networkadvertising.org', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (30, 'slorchartt', 'rN6=0}L"Kb', 'pharmont@gov.uk', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (31, 'sgkedwardu', 'iL8`QM!FPZQIKa1Q', 'aaingellu@prlog.org', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (32, 'sbdalgarnov', 'wQ5(0>nJ3b"d1', 'kharsantv@acquirethisname.com', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (33, 'soparadew', 'uL7~)>d|q#+', 'mgeroldow@mashable.com', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (34, 'srdingatex', 'xO2(OyE\\uy9KK<', 'rdesseinex@surveymonkey.com', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (35, 'stokaney', 'mY2#tCr\\Qe', 'ksantelloy@behance.net', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (36, 'svmessittz', 'vA8)(QM0s#', 'mwesthoffz@blog.com', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (37, 'soshekle10', 'zH1*t=D,#C.%', 'dgoeff10@cmu.edu', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (38, 'smfochs11', 'hF0,!iu=&', 'gthunders11@bloglovin.com', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (39, 'sbschrader12', 'xS6{DBOwASl1', 'wmckerrow12@dailymotion.com', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (40, 'svlitherborough13', 'jG4/n,akmK', 'kbernette13@altervista.org', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (41, 'smvasyukov14', 'fI5,1,(M', 'ibryan14@goo.gl', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (42, 'srkhrishtafovich15', 'yV0<W4`sJjBVLA7', 'pbonallack15@e-recht24.de', 'Team player with strong communication skills');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (43, 'slomailey16', 'vB1#D}!BH_D|n~GP', 'tdunsmore16@eepurl.com', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (44, 'sdpinwell17', 'rU5+i@g\\y+', 'mterrelly17@usgs.gov', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (45, 'stgarriock18', 'lY1|sE`XJ<~w.', 'cbesse18@ow.ly', 'Team player with strong communication skills');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (46, 'sflemery19', 'jS6@|>$%<Eh!`Y2', 'lpotten19@ebay.com', 'Passionate about innovation and creativity');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (47, 'sohoneyghan1a', 'zJ6@{*FJ', 'odymock1a@weebly.com', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (48, 'sgraitt1b', 'cY9\\*ja\'R@rw+', 'tslym1b@state.tx.us', 'Team player with strong communication skills');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (49, 'siusherwood1c', 'fR8@nvtL&%3dX', 'sassender1c@jugem.jp', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (50, 'scshipton1d', 'pZ4@lRw7VPQ<W4Em', 'mgligorijevic1d@sakura.ne.jp', 'Detail-oriented with a focus on delivering high-quality results');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (51, 'slclatworthy1e', 'gB5#{o(=@bGfESS', 'mascrofte1e@ow.ly', 'Experienced professional with over 10 years in the industry');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (52, 'spfogt1f', 'yY4%Pw1<H`u+y_|E', 'tsendley1f@webeden.co.uk', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (53, 'sitague1g', 'xI1{#{.o65UJ#', 'ktattam1g@blog.com', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (54, 'sgsylett1h', 'aI3!v*q/3JmN', 'abaxstair1h@weather.com', 'Self-motivated individual with a track record of exceeding goals');
INSERT INTO commerce.Small_Business_Seller (BusinessID, UserName, PassWord, Email, Profile) VALUES (55, 'smtownsend1i', 'sE6{=+#|7X0PXisX', 'epeegrem1i@linkedin.com', 'Experienced professional with over 10 years in the industry');

#ServiceRepresentative
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (1, '411-161-41', 'Denney Goodreid');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (2, '144-960-00', 'Ximenez Giovanni');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (3, '925-308-00', 'Joelly Dowty');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (4, '659-421-37', 'Sibel Eilhersen');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (5, '653-709-53', 'Barty Yakushkin');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (6, '557-746-96', 'Mohandis Hunt');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (7, '322-429-84', 'Purcell Satterfitt');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (8, '816-680-21', 'Russell Binning');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (9, '452-588-85', 'Elbertine Borrowman');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (10, '731-138-85', 'Filippo Batham');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (11, '444-566-31', 'Caressa Brandsma');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (12, '732-971-30', 'Anton Dominey');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (13, '482-552-32', 'Tarrance Le Fevre');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (14, '147-556-87', 'Joni Beslier');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (15, '561-821-27', 'Luke Schoenleiter');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (16, '237-222-20', 'Flynn McAlinion');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (17, '537-172-49', 'Cathryn Meric');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (18, '688-819-27', 'Tobe Dobeson');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (19, '127-237-30', 'Alli Labbez');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (20, '387-114-21', 'Rafi Heitz');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (21, '136-658-39', 'Josselyn Moorhouse');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (22, '724-565-83', 'Karlotta Castagnier');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (23, '800-234-01', 'Ambrosius Brabon');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (24, '522-244-17', 'Hollis Blundel');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (25, '962-194-67', 'Griffith Stainsby');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (26, '855-613-39', 'Mitchel Tilzey');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (27, '635-907-01', 'Tadio Dent');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (28, '229-984-12', 'Jewell Georgiades');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (29, '959-368-09', 'Alie Jewar');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (30, '848-883-53', 'Tove Claus');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (31, '984-583-25', 'Chanda Stanhope');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (32, '136-973-57', 'Carey Slyme');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (33, '509-914-03', 'Aila Mansbridge');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (34, '140-801-55', 'Thelma Iliffe');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (35, '344-627-54', 'Baron Allsworth');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (36, '595-126-53', 'Aila Farthing');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (37, '677-468-99', 'Eddie Leveritt');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (38, '512-349-99', 'Murry Duffer');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (39, '796-979-69', 'Phil Sherrocks');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (40, '610-815-92', 'Gayel McKennan');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (41, '884-131-68', 'Cristian Goodbar');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (42, '787-573-74', 'Osmond Rannald');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (43, '116-484-49', 'Rosalinda Wessell');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (44, '819-843-27', 'Jewel Gage');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (45, '641-488-05', 'Bertram Scholig');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (46, '527-624-57', 'Kattie Okeshott');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (47, '253-123-29', 'Cletis Minet');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (48, '497-581-98', 'Kellen Jesper');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (49, '778-139-36', 'Jock Lensch');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (50, '871-552-64', 'Dione Crowcum');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (51, '528-241-75', 'Josephine Berge');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (52, '520-371-68', 'Dasya Reinmar');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (53, '115-455-36', 'Teresita Betonia');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (54, '552-791-53', 'Garvey Meneely');
INSERT INTO commerce.ServiceRepresentative (EmployeeID, Phone, Name) VALUES (55, '896-104-89', 'Ivory Steffens');

#products
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (1, 69, 280, 'Container - Hngd Cll Blk 7x7x3', 'Celebrating creativity', 1, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (2, 4, 288, 'Pork - Backfat', 'Whimsical details', 2, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (3, 53, 270, 'Ginger - Crystalized', 'Timeless elegance', 3, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (4, 13, 215, 'Beer - Maudite', 'Artisanal', 4, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (5, 12, 272, 'Rolled Oats', 'Statement piece', 5, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (6, 6, 257, 'Soup - Campbells', 'Functional design', 6, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (7, 11, 239, 'Creme De Cacao Mcguines', 'Bold and vibrant', 7, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (8, 54, 273, 'Gloves - Goldtouch Disposable', 'Eco-friendly', 8, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (9, 59, 290, 'Milk Powder', 'Understated beauty', 9, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (10, 96, 201, 'Pepper - Black, Whole', 'Minimalist', 10, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (11, 14, 218, 'Cheese - Cottage Cheese', 'Celebrating individuality', 11, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (12, 92, 255, 'Bread - Hot Dog Buns', 'Soft pastel tones', 12, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (13, 42, 215, 'Plums - Red', 'Scandinavian design', 13, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (14, 15, 204, 'Butter Sweet', 'Industrial chic', 14, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (15, 27, 264, 'Napkin White', 'Artisanal', 15, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (16, 39, 283, 'Fruit Salad Deluxe', 'Versatile and practical', 16, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (17, 42, 251, 'Chicken - Livers', 'Statement piece', 17, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (18, 63, 300, 'Capicola - Hot', 'Understated beauty', 18, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (19, 33, 274, 'Thermometer Digital', 'Understated beauty', 19, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (20, 66, 289, 'Bread - Hamburger Buns', 'Urban edge', 20, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (21, 80, 233, 'Ice Cream - Fudge Bars', 'Classic and refined', 21, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (22, 4, 270, 'Calypso - Lemonade', 'Bohemian style', 22, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (23, 98, 201, 'True - Vue Containers', 'Playful and fun', 23, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (24, 90, 251, 'Canadian Emmenthal', 'Timeless elegance', 24, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (25, 56, 204, 'Muffin - Mix - Strawberry Rhubarb', 'Statement piece', 25, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (26, 13, 228, 'Onion Powder', 'Celebrating individuality', 26, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (27, 80, 251, 'Cheese - Gorgonzola', 'Celebrating tradition', 27, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (28, 4, 225, 'Sausage - Meat', 'Modern design', 28, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (29, 47, 287, 'Muskox - French Rack', 'Geometric pattern', 29, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (30, 87, 226, 'Tamarind Paste', 'Vintage-inspired', 30, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (31, 36, 248, 'Langers - Cranberry Cocktail', 'Chic and sophisticated', 31, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (32, 81, 264, 'Wine - Kwv Chenin Blanc South', 'Soft pastel tones', 32, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (33, 89, 210, 'Cheese - Comtomme', 'Celebrating creativity', 33, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (34, 30, 270, 'Dehydrated Kelp Kombo', 'Versatile and practical', 34, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (35, 22, 207, 'Rootbeer', 'Statement piece', 35, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (36, 34, 268, 'Sugar - Brown', 'High-quality materials', 36, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (37, 13, 213, 'Berry Brulee', 'Modern design', 37, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (38, 92, 275, 'Bread - White Epi Baguette', 'Versatile and practical', 38, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (39, 94, 202, 'Spinach - Frozen', 'Customizable options', 39, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (40, 25, 243, 'Corn - On The Cob', 'Limited edition', 40, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (41, 100, 300, 'Beans - Navy, Dry', 'Celebrating diversity', 41, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (42, 30, 207, 'Wine - Barolo Fontanafredda', 'Celebrating innovation', 42, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (43, 28, 226, 'Calypso - Black Cherry Lemonade', 'Trendy and stylish', 43, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (44, 59, 276, 'Cape Capensis - Fillet', 'Celebrating innovation', 44, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (45, 34, 257, 'Table Cloth 72x144 White', 'Celebrating tradition', 45, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (46, 14, 292, 'Lemon Pepper', 'Soft pastel tones', 46, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (47, 83, 230, 'Coffee - Hazelnut Cream', 'Versatile and practical', 47, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (48, 38, 290, 'Cake - Pancake', 'Artisanal', 48, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (49, 53, 238, 'Pail With Metal Handle 16l White', 'Playful and fun', 49, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (50, 28, 275, 'Bagelers', 'Urban edge', 50, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (51, 40, 266, 'Grapes - Green', 'Versatile and practical', 51, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (52, 43, 213, 'Plasticforkblack', 'Classic and refined', 52, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (53, 54, 285, 'Chocolate - Feathers', 'Celebrating heritage', 53, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (54, 97, 224, 'Wine - Chateau Timberlay', 'Industrial chic', 54, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (55, 89, 220, 'Wine - Ej Gallo Sonoma', 'Organic', 55, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (56, 80, 205, 'Tomatoes - Cherry, Yellow', 'Urban edge', 1, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (57, 26, 219, 'Wine - Ej Gallo Sonoma', 'Timeless elegance', 2, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (58, 72, 230, 'Coffee - Frthy Coffee Crisp', 'Unique and original', 3, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (59, 86, 289, 'Wine - Red, Gallo, Merlot', 'Urban edge', 4, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (60, 3, 275, 'Wine - Jackson Triggs Okonagan', 'Celebrating diversity', 5, 0, 0);

#ShippingDetail
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (1, 37, '666 Morrow Junction', '2024-04-02 08:42:56', '2024-04-07 07:41:57', 26, 1, 31);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (2, 3, '3789 Warbler Junction', '2024-04-05 05:14:39', '2024-04-07 07:44:21', 24, 2, 9);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (3, 54, '584 Karstens Way', '2024-04-04 19:59:15', '2024-04-07 18:49:44', 2, 3, 52);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (4, 10, '032 Westend Junction', '2024-04-03 19:22:06', '2024-04-07 18:26:21', 28, 4, 20);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (5, 26, '6 Armistice Hill', '2024-04-02 18:45:04', '2024-04-07 11:10:08', 17, 5, 5);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (6, 8, '90 Clove Avenue', '2024-04-03 08:17:01', '2024-04-07 20:55:52', 26, 6, 14);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (7, 2, '4 Golf Course Plaza', '2024-04-01 00:47:16', '2024-04-07 01:09:25', 20, 7, 25);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (8, 8, '25625 Summit Circle', '2024-04-05 05:13:11', '2024-04-07 19:03:30', 20, 8, 23);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (9, 41, '3641 Oneill Center', '2024-04-05 09:02:39', '2024-04-07 23:56:44', 3, 9, 51);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (10, 22, '0 Vermont Alley', '2024-04-05 12:59:30', '2024-04-07 06:53:07', 9, 10, 47);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (11, 46, '53062 Gale Parkway', '2024-04-04 16:04:51', '2024-04-07 00:25:00', 14, 11, 44);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (12, 44, '463 Knutson Circle', '2024-04-01 22:49:48', '2024-04-07 20:38:40', 11, 12, 5);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (13, 43, '054 Ronald Regan Point', '2024-04-03 00:09:26', '2024-04-07 11:51:39', 1, 13, 21);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (14, 24, '4 Ruskin Center', '2024-04-05 02:11:53', '2024-04-07 02:51:32', 24, 14, 52);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (15, 27, '96759 Huxley Alley', '2024-04-05 21:27:18', '2024-04-07 10:35:49', 11, 15, 33);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (16, 41, '80520 Debs Parkway', '2024-04-02 20:53:04', '2024-04-07 00:51:17', 17, 16, 2);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (17, 43, '60 Eggendart Parkway', '2024-04-02 14:46:24', '2024-04-07 20:16:23', 15, 17, 6);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (18, 42, '535 2nd Court', '2024-04-02 22:53:32', '2024-04-07 05:01:30', 11, 18, 20);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (19, 1, '87114 Becker Hill', '2024-04-03 22:58:08', '2024-04-07 01:39:59', 7, 19, 34);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (20, 44, '7 Claremont Parkway', '2024-04-02 12:10:57', '2024-04-07 14:06:07', 4, 20, 50);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (21, 36, '25604 Orin Park', '2024-04-03 05:12:54', '2024-04-07 08:50:02', 11, 21, 49);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (22, 43, '1 Kennedy Plaza', '2024-04-04 07:13:17', '2024-04-07 20:55:51', 13, 22, 48);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (23, 32, '320 Summerview Way', '2024-04-03 03:08:02', '2024-04-07 06:11:46', 8, 23, 38);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (24, 40, '41 Shoshone Park', '2024-04-04 02:35:30', '2024-04-07 23:17:51', 23, 24, 53);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (25, 20, '72 Forster Circle', '2024-04-02 16:12:12', '2024-04-07 15:49:38', 17, 25, 7);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (26, 45, '308 Gerald Street', '2024-04-01 02:18:29', '2024-04-07 02:52:14', 8, 26, 10);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (27, 10, '4 Mayer Way', '2024-04-03 17:55:29', '2024-04-07 14:13:18', 20, 27, 52);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (28, 52, '74387 Banding Hill', '2024-04-05 18:38:36', '2024-04-07 20:06:02', 26, 28, 34);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (29, 19, '786 Mayfield Circle', '2024-04-03 07:35:56', '2024-04-07 14:18:44', 29, 29, 35);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (30, 18, '0 West Place', '2024-04-02 07:31:22', '2024-04-07 00:42:49', 16, 30, 55);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (31, 53, '47529 Spohn Center', '2024-04-01 18:34:24', '2024-04-07 13:05:05', 18, 31, 52);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (32, 54, '66 Pine View Junction', '2024-04-03 20:02:02', '2024-04-07 20:00:36', 24, 32, 52);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (33, 51, '58 Mitchell Point', '2024-04-05 13:35:10', '2024-04-07 20:03:41', 22, 33, 13);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (34, 39, '82583 Toban Street', '2024-04-04 09:39:29', '2024-04-07 23:11:43', 13, 34, 45);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (35, 2, '01 Express Place', '2024-04-01 15:02:36', '2024-04-07 07:24:07', 2, 35, 6);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (36, 46, '499 South Avenue', '2024-04-05 08:45:18', '2024-04-07 12:37:50', 28, 36, 25);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (37, 17, '260 Porter Plaza', '2024-04-01 22:00:16', '2024-04-07 17:02:46', 21, 37, 4);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (38, 45, '920 Farragut Pass', '2024-04-05 03:13:19', '2024-04-07 20:50:12', 4, 38, 29);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (39, 55, '707 Oakridge Circle', '2024-04-02 17:35:49', '2024-04-07 06:25:39', 22, 39, 37);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (40, 10, '85049 Coleman Trail', '2024-04-04 05:02:59', '2024-04-07 08:50:33', 7, 40, 1);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (41, 41, '33 Magdeline Trail', '2024-04-03 16:04:34', '2024-04-07 13:26:11', 12, 41, 5);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (42, 5, '3935 Lake View Crossing', '2024-04-01 01:46:06', '2024-04-07 06:06:56', 29, 42, 21);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (43, 20, '91 Menomonie Place', '2024-04-05 12:24:21', '2024-04-07 06:09:15', 30, 43, 38);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (44, 32, '6 Acker Parkway', '2024-04-02 21:17:58', '2024-04-07 04:58:46', 15, 44, 54);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (45, 44, '51513 Sugar Way', '2024-04-02 00:38:05', '2024-04-07 19:43:34', 8, 45, 12);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (46, 26, '14801 Lerdahl Avenue', '2024-04-03 02:51:19', '2024-04-07 04:45:19', 8, 46, 34);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (47, 16, '60 Center Road', '2024-04-02 03:08:42', '2024-04-07 01:15:22', 6, 47, 39);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (48, 23, '341 Boyd Trail', '2024-04-02 15:26:13', '2024-04-07 01:13:02', 27, 48, 55);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (49, 9, '96921 Nobel Point', '2024-04-02 09:51:04', '2024-04-07 18:08:26', 19, 49, 48);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (50, 31, '2137 Pleasure Place', '2024-04-03 06:13:51', '2024-04-07 08:31:38', 12, 50, 40);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (51, 42, '74906 Kensington Trail', '2024-04-04 03:39:06', '2024-04-07 03:31:38', 30, 51, 32);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (52, 53, '8970 Bonner Drive', '2024-04-04 17:57:09', '2024-04-07 16:45:37', 7, 52, 44);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (53, 27, '49 Cambridge Lane', '2024-04-03 07:48:13', '2024-04-07 16:59:18', 16, 53, 47);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (54, 47, '9451 Corscot Hill', '2024-04-01 01:41:57', '2024-04-07 06:38:27', 22, 54, 33);
INSERT INTO commerce.Shipping_Detail (TrackingNumber, DriverID, Destination, Estimated_Shipping_TIme, Actual_Shipping_Time, PackageSize, OrderID, CustomerID) VALUES (55, 48, '95286 Brickson Park Alley', '2024-04-01 07:24:26', '2024-04-07 00:32:46', 6, 55, 41);

#OrderDetail
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (1, 2, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (2, 9, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (2, 38, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (2, 52, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (3, 5, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (3, 10, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (3, 14, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (3, 18, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (4, 8, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (4, 42, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (4, 48, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (5, 20, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (5, 34, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (5, 38, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 1, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 8, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 17, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 27, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 41, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 46, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 54, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (7, 5, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (7, 9, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (7, 11, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (7, 26, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (7, 46, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (7, 53, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (8, 7, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (8, 48, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (9, 11, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (9, 32, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (10, 4, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (10, 20, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (10, 28, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (10, 36, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (11, 11, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (11, 47, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (12, 31, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (12, 39, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (12, 47, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (13, 14, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (13, 30, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (13, 34, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (14, 30, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (15, 33, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (15, 35, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 5, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 23, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 35, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 53, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (17, 29, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (17, 37, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (17, 40, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (18, 7, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (18, 10, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (19, 1, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (19, 10, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (19, 34, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (20, 13, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (20, 20, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (20, 43, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (21, 42, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (21, 45, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (22, 5, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (22, 8, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (22, 23, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (22, 37, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (23, 2, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (23, 10, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (23, 18, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (23, 55, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (24, 15, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (24, 51, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (25, 9, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (25, 35, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (25, 49, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (26, 14, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (26, 16, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (26, 44, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (27, 19, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (27, 22, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (27, 32, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (27, 40, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (28, 27, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (28, 41, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (29, 47, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (29, 49, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (30, 6, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (30, 53, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (31, 19, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (31, 30, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (31, 43, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (31, 49, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (31, 53, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (32, 12, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (32, 21, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (32, 25, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (32, 42, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (32, 48, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 3, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 4, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 5, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 6, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 16, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 43, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 51, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (34, 2, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (34, 23, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (34, 50, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (35, 5, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (35, 8, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (35, 16, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (35, 17, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (35, 19, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (35, 23, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (36, 9, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (36, 23, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (36, 31, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (36, 51, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (36, 52, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (36, 53, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (37, 8, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (38, 1, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (38, 10, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (38, 37, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (38, 39, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (38, 44, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (38, 49, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (39, 36, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (40, 12, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (40, 22, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (40, 50, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (40, 53, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (41, 2, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (41, 5, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (42, 9, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (42, 14, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (42, 32, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (42, 45, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (42, 48, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (43, 13, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (43, 28, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (43, 45, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (43, 55, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (44, 13, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (44, 32, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (44, 37, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (44, 46, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (44, 51, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (45, 13, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (45, 26, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (45, 27, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (46, 27, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (46, 43, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (46, 44, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (47, 26, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (47, 28, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (47, 39, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (48, 9, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (48, 10, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (48, 23, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (48, 28, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (48, 31, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (48, 50, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (48, 54, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (49, 33, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (49, 49, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (50, 5, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (50, 11, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (50, 15, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (50, 21, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (50, 42, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (51, 15, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (51, 27, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (51, 32, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (51, 35, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (51, 43, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (51, 55, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (52, 6, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (52, 7, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (52, 38, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (52, 53, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (53, 3, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (53, 4, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (53, 6, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (53, 31, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (54, 26, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (55, 1, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (55, 16, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (55, 20, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (55, 35, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (55, 40, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (56, 23, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (56, 27, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (56, 29, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (56, 51, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (56, 52, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 18, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 24, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 25, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 27, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 34, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 37, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 46, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (58, 7, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (58, 32, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (58, 39, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (58, 46, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (59, 6, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (59, 19, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (59, 22, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (60, 7, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (60, 36, 3);

INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (1, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (2, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (3, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (4, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (5, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (6, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (7, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (8, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (9, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (10, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (11, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (12, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (13, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (14, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (15, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (16, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (17, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (18, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (19, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (20, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (21, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (22, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (23, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (24, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (25, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (26, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (27, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (28, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (29, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (30, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (31, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (32, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (33, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (34, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (35, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (36, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (37, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (38, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (39, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (40, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (41, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (42, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (43, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (44, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (45, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (46, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (47, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (48, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (49, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (50, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (51, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (52, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (53, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (54, 0, 0);
INSERT INTO commerce.Cart (CustomerID, TotalItems, Total_Price) VALUES (55, 0, 0);

#Product_In_Cart
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (1, 19, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (1, 28, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (1, 55, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (2, 18, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (2, 44, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (2, 49, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (2, 50, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (3, 9, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (3, 11, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (3, 13, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (3, 14, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (3, 58, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (4, 14, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (4, 48, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (5, 2, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (5, 9, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (5, 46, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (6, 33, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (6, 43, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (7, 6, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (7, 16, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (7, 24, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (7, 36, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (8, 22, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (8, 29, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (8, 40, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (8, 60, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (9, 15, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (9, 17, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (9, 23, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (9, 54, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (10, 30, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (10, 31, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (11, 30, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (11, 47, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (11, 53, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 6, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 7, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 18, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 21, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 26, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 32, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 41, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (12, 60, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (13, 15, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (13, 18, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (13, 47, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (14, 46, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (14, 50, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (15, 2, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (15, 10, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (15, 29, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (15, 30, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (15, 33, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (15, 50, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (15, 59, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (16, 23, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (16, 33, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (16, 47, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 5, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 10, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 24, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 26, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 35, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 41, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 43, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (17, 56, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (18, 17, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (18, 32, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (18, 36, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (19, 5, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (19, 10, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (19, 21, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (19, 27, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (20, 2, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (20, 59, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (21, 12, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (21, 17, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (21, 20, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (21, 56, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (22, 11, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (22, 40, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (22, 46, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (22, 51, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (23, 25, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (24, 4, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (24, 9, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (24, 12, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (24, 19, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (24, 21, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (24, 34, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (24, 41, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (25, 1, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (25, 10, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (25, 15, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (25, 17, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (25, 34, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (25, 38, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (25, 50, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (26, 16, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (26, 22, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (27, 1, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (27, 2, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (27, 45, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (28, 14, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (28, 34, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (28, 35, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (28, 37, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (28, 45, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (28, 52, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (28, 56, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (29, 28, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (29, 40, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (29, 44, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (29, 45, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (29, 47, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (30, 4, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (30, 37, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (30, 53, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (30, 57, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (31, 5, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (31, 6, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (31, 20, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (31, 52, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (32, 3, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (32, 24, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (32, 25, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (32, 27, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (32, 37, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (33, 25, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (33, 32, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (33, 34, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (33, 43, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (33, 53, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (34, 3, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (34, 11, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (35, 7, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (35, 59, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (36, 13, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (36, 30, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (36, 55, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (37, 57, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (38, 5, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (38, 6, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (38, 14, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (38, 25, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (39, 29, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (39, 38, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (39, 39, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (40, 6, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (40, 7, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (40, 20, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (40, 35, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (40, 36, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (40, 48, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (41, 20, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (41, 30, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (41, 36, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (41, 57, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (42, 7, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (42, 9, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (42, 18, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (42, 28, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (43, 8, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (43, 10, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (43, 28, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (43, 45, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (44, 5, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (44, 27, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (45, 28, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (45, 38, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (45, 52, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (46, 12, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (46, 26, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (46, 37, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (47, 1, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (47, 58, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (48, 18, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (48, 24, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (48, 27, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (48, 31, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (48, 33, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (48, 56, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (49, 1, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (49, 49, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (49, 57, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (49, 58, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (49, 60, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (50, 2, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (50, 11, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (50, 58, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (50, 60, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (51, 1, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (51, 20, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (51, 50, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (51, 60, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (52, 5, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (52, 6, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (52, 46, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (52, 54, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (53, 2, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (53, 7, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (53, 10, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (53, 16, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (53, 32, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (53, 54, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (54, 31, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (54, 43, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (54, 44, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (54, 60, 1);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (55, 11, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (55, 21, 2);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (55, 31, 3);
INSERT INTO commerce.Product_In_Cart (CustomerID, ProductID, Quantity) VALUES (55, 56, 2);

#Service
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (1, 'Exchange', 24, '2024-04-03 04:01:18', '2024-04-07 01:41:24', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (2, 'Repair', 21, '2024-04-05 21:25:27', '2024-04-07 10:42:51', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (3, 'Other', 21, '2024-04-04 17:40:14', '2024-04-07 06:36:53', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (4, 'Other', 37, '2024-04-05 13:08:24', '2024-04-07 06:56:32', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (5, 'Return', 41, '2024-04-01 10:27:40', '2024-04-07 09:05:43', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (6, 'Exchange', 53, '2024-04-03 14:59:05', '2024-04-07 04:17:07', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (7, 'Repair', 13, '2024-04-05 03:40:09', '2024-04-07 00:41:08', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (8, 'Return', 50, '2024-04-02 03:40:02', '2024-04-07 02:25:32', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (9, 'Exchange', 55, '2024-04-04 04:58:57', '2024-04-07 16:55:37', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (10, 'Exchange', 12, '2024-04-04 00:25:51', '2024-04-07 18:57:42', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (11, 'Repair', 5, '2024-04-03 14:58:00', '2024-04-07 10:03:46', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (12, 'Repair', 3, '2024-04-04 10:58:56', '2024-04-07 23:09:12', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (13, 'Other', 9, '2024-04-01 20:54:01', '2024-04-07 08:22:29', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (14, 'Return', 20, '2024-04-04 03:39:00', '2024-04-07 13:31:59', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (15, 'Return', 45, '2024-04-01 09:27:02', '2024-04-07 21:59:32', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (16, 'Return', 38, '2024-04-04 09:16:16', '2024-04-07 11:55:33', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (17, 'Repair', 9, '2024-04-01 18:07:16', '2024-04-07 22:59:57', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (18, 'Other', 48, '2024-04-05 00:41:39', '2024-04-07 22:30:11', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (19, 'Repair', 5, '2024-04-03 02:22:19', '2024-04-07 06:38:14', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (20, 'Exchange', 39, '2024-04-01 06:30:33', '2024-04-07 02:05:33', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (21, 'Repair', 53, '2024-04-05 11:32:41', '2024-04-07 06:42:43', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (22, 'Return', 50, '2024-04-05 01:23:21', '2024-04-07 10:40:42', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (23, 'Exchange', 19, '2024-04-03 22:37:07', '2024-04-07 01:35:57', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (24, 'Return', 51, '2024-04-05 02:38:15', '2024-04-07 07:46:05', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (25, 'Other', 19, '2024-04-05 11:56:46', '2024-04-07 11:04:22', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (26, 'Return', 17, '2024-04-03 16:29:47', '2024-04-07 18:30:48', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (27, 'Exchange', 43, '2024-04-04 05:15:57', '2024-04-07 03:38:07', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (28, 'Repair', 32, '2024-04-03 15:03:45', '2024-04-07 22:30:34', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (29, 'Exchange', 24, '2024-04-04 11:36:36', '2024-04-07 02:32:39', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (30, 'Other', 45, '2024-04-05 09:06:18', '2024-04-07 10:55:25', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (31, 'Return', 17, '2024-04-03 14:17:44', '2024-04-07 15:20:41', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (32, 'Return', 42, '2024-04-01 07:25:12', '2024-04-07 19:14:40', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (33, 'Other', 14, '2024-04-02 00:43:54', '2024-04-07 12:59:22', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (34, 'Return', 32, '2024-04-05 20:31:39', '2024-04-07 04:57:57', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (35, 'Exchange', 22, '2024-04-03 13:09:17', '2024-04-07 23:17:57', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (36, 'Repair', 27, '2024-04-05 14:39:52', '2024-04-07 17:42:05', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (37, 'Other', 12, '2024-04-02 23:30:13', '2024-04-07 04:37:24', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (38, 'Repair', 20, '2024-04-05 05:42:01', '2024-04-07 23:01:19', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (39, 'Repair', 55, '2024-04-04 13:53:33', '2024-04-07 21:30:12', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (40, 'Repair', 44, '2024-04-05 12:38:41', '2024-04-07 02:02:38', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (41, 'Other', 7, '2024-04-04 18:41:56', '2024-04-07 03:05:47', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (42, 'Exchange', 53, '2024-04-01 01:42:15', '2024-04-07 18:41:40', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (43, 'Return', 29, '2024-04-03 18:58:55', '2024-04-07 11:42:15', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (44, 'Return', 1, '2024-04-05 11:59:25', '2024-04-07 15:33:24', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (45, 'Exchange', 35, '2024-04-03 13:39:37', '2024-04-07 13:50:10', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (46, 'Repair', 45, '2024-04-05 03:59:16', '2024-04-07 12:11:19', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (47, 'Other', 11, '2024-04-04 06:02:21', '2024-04-07 23:21:06', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (48, 'Repair', 24, '2024-04-02 15:33:24', '2024-04-07 16:51:11', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (49, 'Repair', 41, '2024-04-01 17:55:04', '2024-04-07 14:28:14', 'Electrical service request for custom-made lamp');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (50, 'Exchange', 21, '2024-04-04 21:11:08', '2024-04-07 02:24:44', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (51, 'Return', 6, '2024-04-05 07:36:45', '2024-04-07 20:14:18', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (52, 'Exchange', 51, '2024-04-04 12:03:15', '2024-04-07 11:16:08', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (53, 'Repair', 54, '2024-04-01 06:57:58', '2024-04-07 11:14:00', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (54, 'Other', 26, '2024-04-05 19:27:47', '2024-04-07 13:03:22', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (55, 'Other', 10, '2024-04-03 18:03:23', '2024-04-07 03:56:41', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (56, 'Return', 43, '2024-04-05 20:18:29', '2024-04-07 15:30:45', 'Plumbing service request for handmade sink');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (57, 'Exchange', 5, '2024-04-02 18:05:23', '2024-04-07 14:33:15', 'Carpentry service request for handcrafted furniture');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (58, 'Repair', 2, '2024-04-03 00:34:25', '2024-04-07 13:44:10', 'HVAC service request for artisanal air conditioning unit');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (59, 'Exchange', 17, '2024-04-03 13:36:58', '2024-04-07 05:21:09', 'Painting service request for unique mural');
INSERT INTO commerce.Service (ServiceID, Type, OrderID, StartTime, EndTime, Description) VALUES (60, 'Other', 36, '2024-04-03 01:51:22', '2024-04-07 05:32:21', 'Carpentry service request for handcrafted furniture');


#card
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (38, '201423831494126', '2023-04-16 02:05:55', '290 Wayridge Drive');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (14, '201510051624612', '2024-01-19 12:30:47', '8266 Sommers Hill');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (51, '201863666362338', '2024-04-05 15:53:54', '5372 Fair Oaks Point');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (50, '30034589073520', '2023-11-18 22:25:56', '661 Menomonie Road');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (1, '30123245664770', '2023-05-28 09:43:42', '65 Melvin Hill');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (37, '30393556810888', '2023-09-20 21:58:35', '2667 Golf Course Place');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (44, '30425225711129', '2023-09-16 06:40:25', '7637 Acker Hill');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (9, '347492076511162', '2023-04-09 17:59:20', '86 Sycamore Lane');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (17, '3528833091109638', '2023-11-06 17:49:14', '458 Grayhawk Parkway');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (55, '3532283554913742', '2023-10-03 00:46:05', '94 Coleman Way');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (49, '3532296630079197', '2023-07-31 14:03:05', '70 Jay Terrace');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (54, '3534133552422113', '2023-09-23 03:04:08', '071 Vidon Way');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (1, '3535822134805709', '2023-04-15 06:34:59', '48 Manley Crossing');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (35, '3537687454424565', '2023-10-13 05:14:56', '589 Farmco Lane');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (4, '3538085958878460', '2023-10-18 07:35:35', '60 Maywood Center');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (6, '3540419050231524', '2023-10-08 08:15:39', '82033 Vernon Junction');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (46, '3540606958138476', '2023-05-28 01:39:36', '415 Packers Park');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (42, '3544664675766760', '2023-12-28 04:00:48', '6067 Kings Court');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (8, '3546597581252350', '2023-11-01 10:28:57', '91 Thierer Trail');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (40, '3550397024124180', '2023-04-25 01:18:10', '98 Thompson Point');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (26, '3550850010965875', '2024-03-10 09:41:27', '7167 2nd Park');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (27, '3551696400047165', '2023-10-25 13:37:33', '2568 Carey Terrace');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (3, '3552201293923280', '2023-09-20 08:31:52', '0 Farwell Hill');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (48, '3556842650388371', '2023-10-10 08:23:13', '0 Amoth Center');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (43, '3557502811007513', '2023-07-07 18:01:21', '451 Charing Cross Circle');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (39, '3561012796396323', '2023-10-14 11:05:45', '5405 Center Lane');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (18, '3561909986062252', '2023-11-27 03:27:22', '924 Hallows Lane');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (45, '3562675448319577', '2023-07-25 13:47:58', '007 Anderson Center');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (52, '3563670603473912', '2023-04-19 08:36:54', '808 Pankratz Plaza');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (16, '3570576116996672', '2023-09-20 11:26:36', '524 Lakewood Avenue');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (33, '3571761694076878', '2023-11-22 19:55:19', '8679 Delladonna Junction');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (29, '3574146248351414', '2023-10-28 20:24:42', '57440 Fallview Center');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (34, '3576267577728119', '2023-08-13 03:44:23', '10465 Dwight Road');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (24, '3577107640393146', '2024-02-13 20:13:10', '8 Columbus Point');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (36, '3586892708226804', '2023-07-07 09:15:44', '3 Waxwing Plaza');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (22, '374622735496803', '2024-01-30 09:32:31', '2251 2nd Avenue');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (30, '4026937758648252', '2024-02-18 14:31:48', '61830 Dryden Court');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (15, '4041376345880592', '2023-09-28 08:32:55', '88 Transport Trail');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (41, '4405047407015464', '2023-10-21 21:29:45', '53 Menomonie Hill');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (11, '4405620925306449', '2023-05-16 22:27:52', '2 Birchwood Avenue');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (53, '4903272040925351', '2023-04-21 04:07:41', '441 Sunbrook Parkway');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (3, '490372844170035558', '2023-07-24 16:03:17', '6542 Anzinger Way');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (7, '4913324140132392', '2023-12-04 03:48:37', '7314 Bluestem Drive');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (2, '4936870211095507', '2023-11-10 02:17:23', '8 Hansons Road');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (23, '50381629800327702', '2023-05-03 07:38:30', '40861 Prentice Center');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (20, '5100131117946872', '2024-03-19 00:55:42', '5752 Almo Trail');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (13, '5487047974843924', '2023-12-23 13:18:08', '75977 Sutherland Pass');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (5, '5509163658305496', '2023-08-29 13:58:44', '15 Dahle Plaza');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (28, '5602235929928995', '2023-11-23 11:08:38', '103 Marquette Pass');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (19, '5602238004938558', '2023-05-10 16:41:25', '059 Ronald Regan Crossing');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (12, '5602254043031487', '2023-06-08 09:55:18', '0 High Crossing Pass');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (4, '633301560444762873', '2023-08-01 17:26:40', '4 Cordelia Court');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (10, '633371625063582749', '2023-08-23 02:59:40', '22 Glacier Hill Pass');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (31, '6384284097498458', '2023-10-01 20:16:41', '90 Farwell Junction');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (25, '6390582551040480', '2023-07-12 10:56:47', '37 Porter Hill');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (2, '6394501526456072', '2023-09-08 23:18:17', '2 Westend Pass');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (21, '670601199785144794', '2023-10-23 11:37:19', '9232 Lakeland Way');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (32, '6759112049778004256', '2023-11-20 21:43:29', '7 Kipling Drive');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (5, '67612420609111645', '2024-03-31 15:44:18', '403 Sutteridge Hill');
INSERT INTO commerce.Card (CustomerID, CardNumber, ExpirationDate, BillingAddress) VALUES (47, '676708796239156073', '2023-05-18 12:19:12', '249 Colorado Terrace');

#Response
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (1, 'Unclog drain in laundry room', 'Walkie Talkie', 1, 4);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (2, 'Unclog drain in laundry room', 'Phone', 2, 53);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (3, 'Unclog drain in laundry room', 'Walkie Talkie', 3, 30);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (4, 'Unclog drain in laundry room', 'Email', 4, 15);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (5, 'Paint living room walls', 'Carrier Pigeon', 5, 28);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (6, 'Unclog drain in laundry room', 'Carrier Pigeon', 6, 43);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (7, 'Install new ceiling fan in bedroom', 'Walkie Talkie', 7, 23);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (8, 'Fix leaky faucet in bathroom', 'Phone', 8, 16);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (9, 'Paint living room walls', 'Carrier Pigeon', 9, 50);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (10, 'Clean gutters on house', 'Walkie Talkie', 10, 26);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (11, 'Paint living room walls', 'Email', 11, 25);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (12, 'Unclog drain in laundry room', 'Talking', 12, 10);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (13, 'Paint living room walls', 'Email', 13, 22);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (14, 'Paint living room walls', 'Website', 14, 36);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (15, 'Install new ceiling fan in bedroom', 'Website', 15, 42);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (16, 'Trim trees in backyard', 'Carrier Pigeon', 16, 43);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (17, 'Trim trees in backyard', 'Website', 17, 8);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (18, 'Assemble furniture in guest room', 'Phone', 18, 23);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (19, 'Replace light bulb in kitchen', 'Carrier Pigeon', 19, 13);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (20, 'Mow lawn in front yard', 'Website', 20, 31);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (21, 'Fix leaky faucet in bathroom', 'Phone', 21, 28);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (22, 'Repair broken window in office', 'Carrier Pigeon', 22, 3);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (23, 'Replace light bulb in kitchen', 'Website', 23, 9);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (24, 'Assemble furniture in guest room', 'Walkie Talkie', 24, 42);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (25, 'Trim trees in backyard', 'Carrier Pigeon', 25, 13);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (26, 'Mow lawn in front yard', 'Talking', 26, 54);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (27, 'Install new ceiling fan in bedroom', 'Carrier Pigeon', 27, 36);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (28, 'Replace light bulb in kitchen', 'Email', 28, 20);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (29, 'Unclog drain in laundry room', 'Email', 29, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (30, 'Fix leaky faucet in bathroom', 'Phone', 30, 50);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (31, 'Assemble furniture in guest room', 'Website', 31, 4);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (32, 'Trim trees in backyard', 'Email', 32, 19);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (33, 'Fix leaky faucet in bathroom', 'Carrier Pigeon', 33, 17);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (34, 'Repair broken window in office', 'Email', 34, 31);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (35, 'Trim trees in backyard', 'Walkie Talkie', 35, 41);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (36, 'Clean gutters on house', 'Talking', 36, 37);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (37, 'Paint living room walls', 'Walkie Talkie', 37, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (38, 'Mow lawn in front yard', 'Carrier Pigeon', 38, 6);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (39, 'Clean gutters on house', 'Phone', 39, 4);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (40, 'Paint living room walls', 'Carrier Pigeon', 40, 55);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (41, 'Replace light bulb in kitchen', 'Walkie Talkie', 41, 15);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (42, 'Trim trees in backyard', 'Talking', 42, 43);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (43, 'Fix leaky faucet in bathroom', 'Email', 43, 8);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (44, 'Assemble furniture in guest room', 'Walkie Talkie', 44, 2);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (45, 'Assemble furniture in guest room', 'Email', 45, 54);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (46, 'Assemble furniture in guest room', 'Email', 46, 16);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (47, 'Repair broken window in office', 'Carrier Pigeon', 47, 21);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (48, 'Trim trees in backyard', 'Website', 48, 47);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (49, 'Paint living room walls', 'Walkie Talkie', 49, 45);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (50, 'Trim trees in backyard', 'Talking', 50, 20);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (51, 'Paint living room walls', 'Carrier Pigeon', 51, 28);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (52, 'Repair broken window in office', 'Walkie Talkie', 52, 8);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (53, 'Trim trees in backyard', 'Talking', 53, 55);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (54, 'Clean gutters on house', 'Website', 54, 47);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (55, 'Assemble furniture in guest room', 'Email', 55, 51);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (56, 'Unclog drain in laundry room', 'Email', 56, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (57, 'Install new ceiling fan in bedroom', 'Website', 57, 5);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (58, 'Unclog drain in laundry room', 'Phone', 58, 7);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (59, 'Paint living room walls', 'Talking', 59, 31);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (60, 'Paint living room walls', 'Website', 60, 38);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (61, 'Trim trees in backyard', 'Website', 1, 24);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (62, 'Clean gutters on house', 'Website', 2, 28);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (63, 'Trim trees in backyard', 'Email', 3, 36);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (64, 'Fix leaky faucet in bathroom', 'Email', 4, 51);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (65, 'Unclog drain in laundry room', 'Carrier Pigeon', 5, 32);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (66, 'Trim trees in backyard', 'Talking', 6, 25);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (67, 'Clean gutters on house', 'Walkie Talkie', 7, 50);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (68, 'Mow lawn in front yard', 'Email', 8, 24);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (69, 'Fix leaky faucet in bathroom', 'Talking', 9, 38);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (70, 'Fix leaky faucet in bathroom', 'Talking', 10, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (71, 'Trim trees in backyard', 'Walkie Talkie', 11, 3);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (72, 'Unclog drain in laundry room', 'Website', 12, 48);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (73, 'Mow lawn in front yard', 'Walkie Talkie', 13, 30);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (74, 'Install new ceiling fan in bedroom', 'Talking', 14, 7);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (75, 'Unclog drain in laundry room', 'Email', 15, 50);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (76, 'Unclog drain in laundry room', 'Website', 16, 32);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (77, 'Replace light bulb in kitchen', 'Walkie Talkie', 17, 51);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (78, 'Trim trees in backyard', 'Talking', 18, 22);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (79, 'Fix leaky faucet in bathroom', 'Phone', 19, 34);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (80, 'Trim trees in backyard', 'Email', 20, 33);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (81, 'Unclog drain in laundry room', 'Talking', 21, 52);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (82, 'Paint living room walls', 'Walkie Talkie', 22, 27);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (83, 'Fix leaky faucet in bathroom', 'Phone', 23, 53);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (84, 'Repair broken window in office', 'Carrier Pigeon', 24, 54);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (85, 'Clean gutters on house', 'Phone', 25, 26);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (86, 'Trim trees in backyard', 'Phone', 26, 18);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (87, 'Unclog drain in laundry room', 'Website', 27, 41);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (88, 'Install new ceiling fan in bedroom', 'Walkie Talkie', 28, 48);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (89, 'Install new ceiling fan in bedroom', 'Talking', 29, 24);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (90, 'Repair broken window in office', 'Carrier Pigeon', 30, 14);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (91, 'Unclog drain in laundry room', 'Talking', 31, 1);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (92, 'Assemble furniture in guest room', 'Carrier Pigeon', 32, 35);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (93, 'Assemble furniture in guest room', 'Walkie Talkie', 33, 33);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (94, 'Assemble furniture in guest room', 'Email', 34, 42);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (95, 'Replace light bulb in kitchen', 'Talking', 35, 19);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (96, 'Clean gutters on house', 'Carrier Pigeon', 36, 47);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (97, 'Trim trees in backyard', 'Carrier Pigeon', 37, 42);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (98, 'Unclog drain in laundry room', 'Email', 38, 31);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (99, 'Paint living room walls', 'Talking', 39, 4);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (100, 'Repair broken window in office', 'Talking', 40, 36);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (101, 'Mow lawn in front yard', 'Phone', 41, 5);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (102, 'Repair broken window in office', 'Talking', 42, 11);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (103, 'Install new ceiling fan in bedroom', 'Website', 43, 31);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (104, 'Trim trees in backyard', 'Talking', 44, 37);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (105, 'Replace light bulb in kitchen', 'Phone', 45, 44);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (106, 'Install new ceiling fan in bedroom', 'Talking', 46, 54);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (107, 'Replace light bulb in kitchen', 'Phone', 47, 16);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (108, 'Clean gutters on house', 'Talking', 48, 33);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (109, 'Mow lawn in front yard', 'Walkie Talkie', 49, 18);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (110, 'Clean gutters on house', 'Carrier Pigeon', 50, 25);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (111, 'Fix leaky faucet in bathroom', 'Phone', 51, 29);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (112, 'Install new ceiling fan in bedroom', 'Phone', 52, 45);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (113, 'Fix leaky faucet in bathroom', 'Website', 53, 36);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (114, 'Unclog drain in laundry room', 'Email', 54, 4);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (115, 'Install new ceiling fan in bedroom', 'Website', 55, 25);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (116, 'Install new ceiling fan in bedroom', 'Email', 56, 52);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (117, 'Repair broken window in office', 'Walkie Talkie', 57, 26);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (118, 'Fix leaky faucet in bathroom', 'Talking', 58, 3);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (119, 'Mow lawn in front yard', 'Walkie Talkie', 59, 20);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (120, 'Fix leaky faucet in bathroom', 'Carrier Pigeon', 60, 17);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (121, 'Fix leaky faucet in bathroom', 'Walkie Talkie', 1, 44);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (122, 'Install new ceiling fan in bedroom', 'Carrier Pigeon', 2, 47);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (123, 'Trim trees in backyard', 'Walkie Talkie', 3, 13);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (124, 'Paint living room walls', 'Talking', 4, 11);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (125, 'Trim trees in backyard', 'Website', 5, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (126, 'Fix leaky faucet in bathroom', 'Website', 6, 26);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (127, 'Clean gutters on house', 'Walkie Talkie', 7, 41);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (128, 'Replace light bulb in kitchen', 'Talking', 8, 21);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (129, 'Unclog drain in laundry room', 'Walkie Talkie', 9, 25);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (130, 'Install new ceiling fan in bedroom', 'Email', 10, 55);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (131, 'Fix leaky faucet in bathroom', 'Carrier Pigeon', 11, 32);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (132, 'Install new ceiling fan in bedroom', 'Carrier Pigeon', 12, 5);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (133, 'Assemble furniture in guest room', 'Walkie Talkie', 13, 52);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (134, 'Assemble furniture in guest room', 'Email', 14, 31);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (135, 'Clean gutters on house', 'Carrier Pigeon', 15, 19);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (136, 'Repair broken window in office', 'Email', 16, 40);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (137, 'Mow lawn in front yard', 'Phone', 17, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (138, 'Paint living room walls', 'Carrier Pigeon', 18, 14);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (139, 'Repair broken window in office', 'Email', 19, 18);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (140, 'Unclog drain in laundry room', 'Email', 20, 22);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (141, 'Repair broken window in office', 'Walkie Talkie', 21, 46);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (142, 'Fix leaky faucet in bathroom', 'Talking', 22, 11);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (143, 'Unclog drain in laundry room', 'Email', 23, 52);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (144, 'Clean gutters on house', 'Phone', 24, 6);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (145, 'Repair broken window in office', 'Email', 25, 52);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (146, 'Paint living room walls', 'Talking', 26, 21);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (147, 'Paint living room walls', 'Carrier Pigeon', 27, 39);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (148, 'Paint living room walls', 'Website', 28, 46);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (149, 'Assemble furniture in guest room', 'Carrier Pigeon', 29, 23);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (150, 'Replace light bulb in kitchen', 'Phone', 30, 33);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (151, 'Clean gutters on house', 'Email', 31, 53);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (152, 'Unclog drain in laundry room', 'Website', 32, 28);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (153, 'Replace light bulb in kitchen', 'Carrier Pigeon', 33, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (154, 'Trim trees in backyard', 'Walkie Talkie', 34, 38);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (155, 'Unclog drain in laundry room', 'Email', 35, 10);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (156, 'Replace light bulb in kitchen', 'Walkie Talkie', 36, 26);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (157, 'Repair broken window in office', 'Phone', 37, 2);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (158, 'Mow lawn in front yard', 'Phone', 38, 52);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (159, 'Trim trees in backyard', 'Carrier Pigeon', 39, 39);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (160, 'Replace light bulb in kitchen', 'Phone', 40, 40);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (161, 'Install new ceiling fan in bedroom', 'Talking', 41, 7);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (162, 'Mow lawn in front yard', 'Talking', 42, 6);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (163, 'Fix leaky faucet in bathroom', 'Walkie Talkie', 43, 6);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (164, 'Trim trees in backyard', 'Email', 44, 20);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (165, 'Paint living room walls', 'Email', 45, 25);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (166, 'Clean gutters on house', 'Carrier Pigeon', 46, 54);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (167, 'Install new ceiling fan in bedroom', 'Carrier Pigeon', 47, 26);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (168, 'Clean gutters on house', 'Talking', 48, 45);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (169, 'Install new ceiling fan in bedroom', 'Talking', 49, 18);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (170, 'Replace light bulb in kitchen', 'Walkie Talkie', 50, 20);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (171, 'Trim trees in backyard', 'Talking', 51, 2);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (172, 'Assemble furniture in guest room', 'Talking', 52, 52);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (173, 'Clean gutters on house', 'Email', 53, 48);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (174, 'Repair broken window in office', 'Talking', 54, 5);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (175, 'Install new ceiling fan in bedroom', 'Website', 55, 32);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (176, 'Paint living room walls', 'Website', 56, 17);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (177, 'Paint living room walls', 'Email', 57, 24);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (178, 'Unclog drain in laundry room', 'Talking', 58, 36);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (179, 'Clean gutters on house', 'Carrier Pigeon', 59, 33);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (180, 'Paint living room walls', 'Carrier Pigeon', 60, 22);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (181, 'Unclog drain in laundry room', 'Walkie Talkie', 1, 6);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (182, 'Repair broken window in office', 'Phone', 2, 2);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (183, 'Trim trees in backyard', 'Talking', 3, 46);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (184, 'Unclog drain in laundry room', 'Website', 4, 37);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (185, 'Trim trees in backyard', 'Talking', 5, 16);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (186, 'Mow lawn in front yard', 'Email', 6, 9);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (187, 'Repair broken window in office', 'Talking', 7, 46);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (188, 'Mow lawn in front yard', 'Carrier Pigeon', 8, 16);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (189, 'Trim trees in backyard', 'Website', 9, 4);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (190, 'Assemble furniture in guest room', 'Phone', 10, 29);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (191, 'Paint living room walls', 'Phone', 11, 50);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (192, 'Mow lawn in front yard', 'Phone', 12, 31);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (193, 'Trim trees in backyard', 'Carrier Pigeon', 13, 55);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (194, 'Replace light bulb in kitchen', 'Email', 14, 25);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (195, 'Paint living room walls', 'Talking', 15, 44);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (196, 'Paint living room walls', 'Email', 16, 40);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (197, 'Install new ceiling fan in bedroom', 'Walkie Talkie', 17, 30);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (198, 'Install new ceiling fan in bedroom', 'Email', 18, 49);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (199, 'Fix leaky faucet in bathroom', 'Phone', 19, 10);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (200, 'Assemble furniture in guest room', 'Talking', 20, 36);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (201, 'Mow lawn in front yard', 'Walkie Talkie', 21, 12);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (202, 'Mow lawn in front yard', 'Walkie Talkie', 22, 34);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (203, 'Install new ceiling fan in bedroom', 'Email', 23, 48);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (204, 'Clean gutters on house', 'Phone', 24, 45);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (205, 'Assemble furniture in guest room', 'Walkie Talkie', 25, 6);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (206, 'Install new ceiling fan in bedroom', 'Walkie Talkie', 26, 7);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (207, 'Repair broken window in office', 'Email', 27, 47);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (208, 'Repair broken window in office', 'Website', 28, 28);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (209, 'Repair broken window in office', 'Walkie Talkie', 29, 22);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (210, 'Install new ceiling fan in bedroom', 'Email', 30, 35);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (211, 'Fix leaky faucet in bathroom', 'Website', 31, 26);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (212, 'Repair broken window in office', 'Talking', 32, 9);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (213, 'Unclog drain in laundry room', 'Carrier Pigeon', 33, 27);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (214, 'Unclog drain in laundry room', 'Email', 34, 17);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (215, 'Repair broken window in office', 'Talking', 35, 20);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (216, 'Clean gutters on house', 'Walkie Talkie', 36, 24);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (217, 'Install new ceiling fan in bedroom', 'Talking', 37, 53);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (218, 'Repair broken window in office', 'Talking', 38, 41);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (219, 'Clean gutters on house', 'Phone', 39, 5);
INSERT INTO commerce.Response (ResponseID, Contents, Type, ServiceID, RepID) VALUES (220, 'Unclog drain in laundry room', 'Phone', 40, 43);

INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602210207745239', 'Silver Sagebrush', '1 Moose Way', 2);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602212864149440', 'Wireleaf Dropseed', '62 Fallview Crossing', 3);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602212871125797', 'Pauper\'s-tea', '0 Sachs Parkway', 29);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602212911415265', 'Reeves\' Meadowsweet', '93382 Harper Way', 5);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602214241743994', 'Bearded Prairie Clover', '956 Maywood Court', 17);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602215335455064', 'Whitehead', '82 Lukken Way', 13);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602215823788612', 'Veiny False Pennyroyal', '90527 Meadow Valley Crossing', 6);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602217886984880', 'Foxtail Clubmoss', '348 8th Pass', 6);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602218209113637', 'Berlandier\'s Wolfberry', '150 Vera Road', 30);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602219627558544', 'Naturita Milkvetch', '96740 Grover Center', 9);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602220389977054', 'Terrestrial Cowhorn Orchid', '64193 Harbort Crossing', 35);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602220668926319', 'Cahaba Prairie Clover', '4279 Packers Plaza', 26);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602223062271704', 'Arizona Poppy', '26 Katie Alley', 1);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602225095357509', 'Koolau Range Rollandia', '614 Sherman Place', 54);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602225233004377', 'Tender Lovegrass', '9268 Garrison Center', 28);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602226111355147', 'St. John\'s Melicope', '19361 Dahle Junction', 23);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602226862236470', 'Urn Lichen', '284 Bultman Court', 50);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602227476887229', 'Scouler\'s Valerian', '2445 Independence Alley', 19);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602228036821906', 'Hooker\'s Manzanita', '8511 Hoffman Place', 14);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602229882133768', 'Hoary Caper', '12596 Mifflin Pass', 8);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602229960637219', 'Jaffueliobryum Moss', '7938 Moulton Parkway', 1);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602231243738574', 'Smooth Northern-rockcress', '7091 Ramsey Road', 10);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602232121630057', 'Kaala Stenogyne', '24 Almo Crossing', 55);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602233866197492', 'Crown Of Thorns', '6 Lighthouse Bay Crossing', 16);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602235430719719', 'Sweetshoot Bamboo', '3486 Hovde Way', 2);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602235868560072', 'Yellow Rabbitbrush', '97 Lawn Center', 39);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602236561852667', 'Smallflower Nemophila', '9656 Butterfield Hill', 40);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602238616096035', 'Smotherweed', '9605 Westerfield Hill', 48);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602240669107040', 'Jelly Lichen', '22147 Arizona Pass', 27);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602243514345807', 'Halberdleaf Tearthumb', '901 Westend Street', 4);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602244469993906', 'Spiral Sorrel', '9 Prairie Rose Way', 33);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602245295330189', 'Scalloped Milkwort', '95 Columbus Place', 7);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602246766372890', 'Eastern Poison Ivy', '69798 Pankratz Circle', 34);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602247369491616', 'Miller\'s Rock Moss', '70833 Schmedeman Court', 4);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602248161353384', 'American Alumroot', '34183 Lighthouse Bay Street', 38);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602249084247497', 'Rauiella Moss', '29724 Fairfield Avenue', 31);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602250250095249', 'Wheat Sedge', '8511 Colorado Crossing', 47);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602251202757910', 'Riverswamp Nutrush', '5 Rockefeller Alley', 3);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602251745489013', 'Western False Rue Anemone', '0 Northfield Center', 24);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602252326528047', 'Trask\'s Milkvetch', '96915 Stuart Drive', 52);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602253088725235', 'Pinto Beardtongue', '09 Lotheville Drive', 21);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602253173247277', 'Globe Earth Lichen', '3055 Vera Pass', 36);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602253512598240', 'Oconee Bells', '64 Twin Pines Plaza', 20);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602253694262433', 'Dulichium', '3845 Graedel Alley', 49);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602254066570163', 'Antilles Fanpetals', '0563 Cottonwood Junction', 7);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602255146218897', 'Prairie Phacelia', '49 Cottonwood Place', 42);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602255753055624', 'Stiffstem Flax', '595 7th Way', 44);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602257490313910', 'Wild Garlic', '830 Jana Plaza', 8);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602258584117209', 'Scarlet Firethorn', '787 Green Ridge Trail', 53);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5602258792193430', 'Texas Sleepydaisy', '51791 Anhalt Plaza', 43);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610190525881884', 'Redbird Flower', '44692 Bartelt Terrace', 5);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610261421442780', 'Spiny Combretum', '06217 Union Avenue', 46);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610328325264139', 'Pickering\'s Dawnflower', '4616 Ronald Regan Street', 37);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610497386242290', 'Williams\' Buckwheat', '48 Vahlen Crossing', 45);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610506728878668', 'Wailua River Yellow Loosestrife', '7 Banding Terrace', 51);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610514069628171', 'Fumitory', '3980 Daystar Way', 25);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610747023356311', 'Schreber\'s Dicranella Moss', '6339 Walton Avenue', 22);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610797140056930', 'Kentucky Yellowwood', '178 Delaware Pass', 41);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610848685277546', 'Chiricahua Mountain Sandmat', '951 New Castle Street', 32);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610885163614568', 'Whorled Marshpennywort', '67 Lotheville Street', 18);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610900035046483', 'Robust Rhytidiopsis Moss', '83 Norway Maple Circle', 11);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610926144403232', 'Limahuli Cyrtandra', '176 Sherman Alley', 15);
INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID) VALUES ('5610999525757310', 'Parmotrema Lichen', '96 Shopko Point', 12);


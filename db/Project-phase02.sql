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

CREATE TABLE IF NOT EXISTS Orders
(
    OrderID         int          NOT NULL AUTO_INCREMENT,
    Cost            int          NOT NULL,
    PlacedTime      datetime     NOT NULL,
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

CREATE TRIGGER cost_update AFTER update on OrderDetails
    FOR EACH ROW
    BEGIN
        DECLARE total_cost int default 0;
        SELECT SUM(p.Price * od.Quantity) INTO total_cost
        FROM Orders o join OrderDetails OD on o.OrderID = OD.OrderID
        join Products P on P.ProductID = OD.ProductID
        WHERE od.OrderID = NEW.OrderID;
        UPDATE Orders
        SET Cost = total_cost
        WHERE OrderID = NEW.OrderID;
    end;

CREATE TRIGGER sold_update AFTER update on OrderDetails
    FOR EACH ROW
    BEGIN
        DECLARE total_sold int default 0;
        SELECT SUM(od.Quantity) INTO total_sold
        FROM Orders o join OrderDetails OD on o.OrderID = OD.OrderID
        join Products P on P.ProductID = OD.ProductID
        WHERE od.ProductID = NEW.ProductID;
        UPDATE Products
        SET  UnitsSold = total_sold
        WHERE ProductID = NEW.ProductID;
    end;

CREATE TRIGGER Check_Quantity_Before_Insert_Update BEFORE INSERT  ON OrderDetails
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
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (1, 0, '2024-01-29 10:35:01', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (2, 0, '2023-09-08 19:19:40', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (3, 0, '2023-05-24 01:06:58', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (4, 0, '2024-02-22 02:52:38', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (5, 0, '2023-03-19 22:43:46', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (6, 0, '2024-03-30 04:46:47', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (7, 0, '2023-03-08 15:19:11', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (8, 0, '2023-10-25 15:46:33', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (9, 0, '2023-11-28 23:05:54', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (10, 0, '2023-08-12 18:01:09', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (11, 0, '2023-08-24 00:01:18', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (12, 0, '2024-01-12 16:06:04', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (13, 0, '2023-03-02 19:55:17', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (14, 0, '2023-10-05 23:15:53', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (15, 0, '2024-02-29 22:56:43', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (16, 0, '2023-03-21 07:12:41', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (17, 0, '2023-06-24 16:41:43', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (18, 0, '2023-11-05 07:51:46', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (19, 0, '2023-12-28 16:49:34', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (20, 0, '2023-10-07 17:08:25', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (21, 0, '2023-10-18 10:35:39', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (22, 0, '2024-02-05 17:52:33', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (23, 0, '2023-09-20 02:46:01', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (24, 0, '2023-07-14 15:47:37', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (25, 0, '2024-01-30 11:19:18', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (26, 0, '2023-04-16 17:26:13', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (27, 0, '2023-11-23 16:09:21', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (28, 0, '2024-03-07 23:46:23', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (29, 0, '2023-11-30 04:15:48', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (30, 0, '2023-03-29 10:37:30', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (31, 0, '2023-04-26 13:31:08', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (32, 0, '2023-09-02 21:14:08', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (33, 0, '2023-05-11 07:16:22', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (34, 0, '2023-04-12 12:12:34', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (35, 0, '2023-10-28 21:40:40', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (36, 0, '2023-08-07 02:35:46', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (37, 0, '2024-02-23 22:27:42', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (38, 0, '2023-07-18 18:45:09', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (39, 0, '2024-03-11 07:08:08', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (40, 0, '2024-01-20 07:33:56', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (41, 0, '2023-07-10 19:02:29', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (42, 0, '2024-01-26 02:53:25', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (43, 0, '2023-12-20 20:40:28', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (44, 0, '2023-04-10 08:14:12', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (45, 0, '2024-02-03 05:58:23', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (46, 0, '2023-10-28 06:54:47', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (47, 0, '2023-09-26 16:12:40', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (48, 0, '2023-11-26 23:52:19', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (49, 0, '2023-05-09 07:11:44', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (50, 0, '2023-08-13 20:21:46', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (51, 0, '2023-07-12 12:35:12', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (52, 0, '2023-08-06 18:27:57', 1);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (53, 0, '2024-01-18 15:48:45', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (54, 0, '2023-10-20 11:50:33', 2);
INSERT INTO commerce.Orders (OrderID, Cost, PlacedTime, Status) VALUES (55, 0, '2023-08-06 17:09:03', 2);

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
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (1, 12, 54, 'Chicken - Bones', 'Limited edition', 1, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (2, 68, 21, 'Muffin Hinge - 211n', 'Botanical print', 2, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (3, 71, 69, 'Appetizer - Asian Shrimp Roll', 'Cozy and inviting', 3, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (4, 92, 65, 'Clam - Cherrystone', 'Cozy and inviting', 4, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (5, 70, 62, 'Cheese - Romano, Grated', 'Classic and refined', 5, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (6, 31, 9, 'Initation Crab Meat', 'Vintage-inspired', 6, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (7, 40, 98, 'Wine - White, French Cross', 'Playful and fun', 7, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (8, 30, 47, 'Cup - Translucent 7 Oz Clear', 'Feminine touch', 8, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (9, 92, 81, 'Shallots', 'Artisanal', 9, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (10, 3, 85, 'Table Cloth 81x81 White', 'Luxurious', 10, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (11, 45, 92, 'Broom Handle', 'Exquisite craftsmanship', 11, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (12, 55, 28, 'Cheese - Cheddar, Mild', 'Scandinavian design', 12, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (13, 87, 73, 'Mushroom - Morel Frozen', 'Playful and fun', 13, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (14, 70, 86, 'Bouillion - Fish', 'Inspired by nature', 14, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (15, 97, 55, 'Grand Marnier', 'Celebrating individuality', 15, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (16, 56, 22, 'Coconut - Creamed, Pure', 'Organic', 16, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (17, 82, 82, 'Pasta - Fettuccine, Dry', 'Versatile and practical', 17, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (18, 95, 75, 'Pepper - Chilli Seeds Mild', 'Playful and fun', 18, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (19, 81, 30, 'Pastry - Chocolate Chip Muffin', 'Timeless elegance', 19, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (20, 23, 70, 'Hipnotiq Liquor', 'Celebrating innovation', 20, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (21, 45, 52, 'Soup - Campbells Mushroom', 'Scandinavian design', 21, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (22, 8, 4, 'Muffin - Zero Transfat', 'Trendy and stylish', 22, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (23, 73, 91, 'Jam - Marmalade, Orange', 'Textured finish', 23, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (24, 5, 29, 'Fruit Salad Deluxe', 'Bohemian style', 24, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (25, 99, 94, 'Soap - Pine Sol Floor Cleaner', 'Industrial chic', 25, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (26, 21, 7, 'Grapes - Black', 'Industrial chic', 26, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (27, 69, 37, 'Water - Aquafina Vitamin', 'Minimalist', 27, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (28, 6, 53, 'Sauce - Cranberry', 'Premium quality', 28, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (29, 19, 15, 'Calvados - Boulard', 'Whimsical details', 29, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (30, 77, 93, 'Steampan Lid', 'Premium quality', 30, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (31, 59, 11, 'Otomegusa Dashi Konbu', 'Handcrafted', 31, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (32, 58, 94, 'Mangostein', 'Exquisite craftsmanship', 32, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (33, 60, 98, 'Nori Sea Weed', 'Feminine touch', 33, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (34, 73, 27, 'Dill Weed - Fresh', 'Limited edition', 34, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (35, 54, 97, 'Vacuum Bags 12x16', 'Celebrating heritage', 35, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (36, 100, 8, 'Fruit Salad Deluxe', 'Sustainable', 36, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (37, 52, 36, 'Bread - Sticks, Thin, Plain', 'Soft pastel tones', 37, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (38, 57, 22, 'Munchies Honey Sweet Trail Mix', 'Culturally inspired', 38, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (39, 89, 14, 'Guinea Fowl', 'Celebrating diversity', 39, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (40, 85, 6, 'Compound - Passion Fruit', 'Statement piece', 40, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (41, 63, 99, 'Sea Bass - Whole', 'Monochrome palette', 41, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (42, 97, 21, 'Cheese - Brie', 'Culturally inspired', 42, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (43, 68, 25, 'Bread Foccacia Whole', 'Feminine touch', 43, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (44, 86, 92, 'Initation Crab Meat', 'Organic', 44, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (45, 85, 52, 'Chicken Breast Halal', 'Statement piece', 45, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (46, 98, 32, 'Corn Shoots', 'Inspired by nature', 46, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (47, 37, 96, 'Cheese - Brick With Onion', 'Vintage-inspired', 47, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (48, 74, 10, 'Soup - Campbells, Creamy', 'Understated beauty', 48, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (49, 97, 99, 'Tofu - Soft', 'Modern design', 49, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (50, 22, 47, 'Steamers White', 'High-quality materials', 50, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (51, 94, 87, 'Pork - Sausage Casing', 'Minimalist', 51, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (52, 21, 36, 'Sprouts - Corn', 'Limited edition', 52, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (53, 77, 44, 'Muffin Batt - Blueberry Passion', 'Monochrome palette', 53, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (54, 9, 30, 'Cookie Dough - Chocolate Chip', 'Statement piece', 54, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (55, 100, 17, 'V8 - Vegetable Cocktail', 'Celebrating individuality', 55, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (56, 11, 39, 'Syrup - Monin, Irish Cream', 'Artisanal', 1, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (57, 38, 20, 'Bread - Corn Muffaletta', 'Artisanal', 2, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (58, 7, 97, 'Pail With Metal Handle 16l White', 'Eco-friendly', 3, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (59, 26, 3, 'Juice - Grape, White', 'Eco-friendly', 4, 0, 0);
INSERT INTO commerce.Products (ProductID, Price, UnitsInStock, ProductName, ProductionDescription, BusinessID, UnitsSold, OnSale) VALUES (60, 53, 73, 'Liners - Baking Cups', 'Monochrome palette', 5, 0, 0);

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
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (1, 18, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (1, 33, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (1, 36, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (3, 20, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (3, 35, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (3, 37, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (4, 25, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (5, 6, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (5, 38, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (5, 47, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (6, 30, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (9, 30, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (9, 51, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (9, 54, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (10, 55, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (11, 6, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (11, 17, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (11, 36, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (11, 47, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (12, 39, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (13, 21, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (13, 37, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (13, 40, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 1, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 9, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 45, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (16, 54, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (17, 53, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (18, 10, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (18, 46, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (18, 47, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (19, 3, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (19, 16, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (19, 25, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (20, 1, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (20, 51, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (21, 24, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (22, 7, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (22, 11, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (22, 24, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (23, 29, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (23, 38, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (25, 42, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (25, 46, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (26, 7, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (28, 2, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (28, 19, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (28, 41, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (28, 49, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (29, 3, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (31, 2, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (31, 37, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (32, 41, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (33, 11, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (34, 29, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (37, 50, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (39, 4, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (39, 50, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (39, 51, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (41, 15, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (41, 39, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (42, 5, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (42, 44, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (44, 43, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (49, 20, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (49, 33, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (50, 52, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (51, 15, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (54, 24, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (55, 9, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (55, 54, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (56, 6, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (56, 53, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 18, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 47, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (57, 52, 2);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (59, 31, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (60, 5, 1);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (60, 38, 3);
INSERT INTO commerce.OrderDetails (ProductID, OrderID, Quantity) VALUES (60, 50, 2);

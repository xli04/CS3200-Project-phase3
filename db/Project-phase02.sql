CREATE DATABASE IF NOT EXISTS 
USE 

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
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (1, 'mpiscot0', 'xY1>\'''8|T3}v+@+Y%', 'rbroomer0@merriam-webster.com', '30431 Daystar Alley');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (2, 'xbrookhouse1', 'lT8}gkX5<(a', 'eskelhorn1@cloudflare.com', '72 Eliot Point');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (3, 'cromanet2', 'vV8*J{emkQHLR', 'jbohje2@techcrunch.com', '62800 Northview Place');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (4, 'dportail3', 'cK2.R>7a!|}rt`', 'alimmer3@bizjournals.com', '220 Ilene Center');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (5, 'jcheccuzzi4', 'iX2~f\'Ydbhb', 'amichelet4@bluehost.com', '05316 Northridge Terrace');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (6, 'npeplay5', 'kX6$\\%gs"~TH', 'tterzi5@google.co.uk', '43016 Prentice Court');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (7, 'hdelorenzo6', 'pQ1+v}{/Q~&N', 'etrayton6@hubpages.com', '5 Waxwing Court');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (8, 'ddarlison7', 'xW3}Xsxn', 'cparlet7@cdc.gov', '69 Arkansas Plaza');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (9, 'mgregoraci8', 'dL4@33&61', 'wpiesold8@bizjournals.com', '913 Gina Court');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (10, 'rcalan9', 'bF1#nicXS', 'adidomenico9@europa.eu', '16587 Riverside Court');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (11, 'dbandea', 'wA5.Kktl5', 'rkennicotta@microsoft.com', '7766 Union Pass');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (12, 'zgreserb', 'mH6$.>zS(CGXRT#\\', 'uoldaleb@deviantart.com', '9 Michigan Way');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (13, 'vvasyukhnovc', 'aI0<$*d$JI4', 'mcuttenc@sphinn.com', '6 Messerschmidt Park');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (14, 'kleyninyed', 'sR5(Z!Jc', 'pdyned@rediff.com', '220 Manley Avenue');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (15, 'nbeauvaise', 'dR6%_Zs="', 'dbritlande@wordpress.org', '13947 Independence Court');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (16, 'afairpoolf', 'yR8=k~!c\\psRy@N\'', 'rhewlingsf@i2i.jp', '849 Burrows Circle');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (17, 'dwedong', 'tG8"y_55st=*)ak', 'ctyrwhittg@patch.com', '263 Spohn Park');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (18, 'sclarkinh', 'aE4@E#(}i+w%', 'ffaceyh@ning.com', '245 School Trail');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (19, 'okebelli', 'lR3|(P41jZ0h+xM', 'fpedleri@adobe.com', '820 Hermina Hill');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (20, 'breadmanj', 'kO8<L(Y7nTE2\'7_', 'mdunabiej@woothemes.com', '8853 Mesta Court');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (21, 'bsuccamorek', 'wW7%JWEyaK', 'clittlekitk@chron.com', '66 Ridgeview Alley');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (22, 'remmanuelil', 'mU2/%tjr<Ilhxy', 'sworgenl@marketwatch.com', '65 Drewry Drive');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (23, 'ewoodersonm', 'nH8=E~XUS', 'djirim@hugedomains.com', '5 Pleasure Plaza');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (24, 'bvoasen', 'uO4@WGBxc', 'akleynenn@xinhuanet.com', '55010 Hollow Ridge Park');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (25, 'prexo', 'cU8=zzX2kDvWFf,8', 'ncalveyo@theatlantic.com', '8110 Riverside Crossing');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (26, 'aargentp', 'gM1>(whJv', 'sflipsp@cbslocal.com', '597 Ludington Alley');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (27, 'qmalletrattq', 'lZ9,8@SxW_k', 'rtomasiq@plala.or.jp', '00374 Bluestem Hill');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (28, 'lcaveaur', 'pT1=`Z+)6R', 'ljakucewiczr@ovh.net', '59528 Trailsway Pass');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (29, 'eboyns', 'hH7%60E"', 'kstitsons@netlog.com', '4 Sauthoff Hill');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (30, 'rvanarsdallt', 'iU1%wyVqzH(o?*mT', 'tneaglet@booking.com', '619 Dawn Junction');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (31, 'rgrunbaumu', 'fK6<Wq%&', 'sdennesu@psu.edu', '729 Ridge Oak Way');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (32, 'eswansonv', 'tY3,Ih)2fDR', 'mgrahlv@utexas.edu', '89367 Eagan Place');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (33, 'lsenchenkow', 'zU0?cL(kP0tV9#(j', 'rbassamw@exblog.jp', '17408 Loftsgordon Alley');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (34, 'kalgorex', 'tA7|~b.=H', 'evanarsdalenx@wunderground.com', '10425 Orin Road');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (35, 'gmangeony', 'nF0|hRee5k"Ne', 'mpricketty@blogs.com', '82296 Fallview Plaza');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (36, 'cmatejicz', 'zO8<UABpn3', 'frousellz@trellian.com', '2 Vahlen Point');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (37, 'ccowdry10', 'cV9\\0qOcsz&BvF(', 'iludy10@wufoo.com', '05754 Milwaukee Crossing');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (38, 'vmaciver11', 'zH1}E\\d~f\\uagM', 'hewan11@vinaora.com', '3492 Truax Trail');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (39, 'agres12', 'mV6{.rNqH_', 'cdonnersberg12@techcrunch.com', '6 Heffernan Parkway');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (40, 'fmatteoni13', 'fT9/3=Lo', 'fdeclerc13@macromedia.com', '313 South Alley');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (41, 'dantonioni14', 'tZ7`2giK))b%u1!r', 'jleser14@clickbank.net', '1 Sundown Road');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (42, 'bgoroni15', 'tY4=|B(6dx+j1c@4', 'odury15@tripod.com', '084 Ramsey Street');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (43, 'ndy16', 'dY4=oslm\'%', 'gbennington16@virginia.edu', '03008 Bellgrove Road');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (44, 'jangliss17', 'wI3=14!7m', 'tcrab17@wikimedia.org', '52 Union Drive');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (45, 'kbarter18', 'nY4|FC$_Pt=2(2', 'acolombier18@bluehost.com', '93901 Blackbird Plaza');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (46, 'pfleckness19', 'gA6}h7xJUqR', 'severly19@theguardian.com', '7 Melvin Plaza');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (47, 'arosenshine1a', 'iX2<@uW=RTi@{', 'mgreenly1a@cyberchimps.com', '5 Dakota Center');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (48, 'lsabate1b', 'lO5)_?}d5~', 'ashemmans1b@weibo.com', '614 Ruskin Avenue');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (49, 'mmatthias1c', 'zV0@M12|(', 'tharpin1c@typepad.com', '4 Independence Circle');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (50, 'pternouth1d', 'zV6)Yb+>>LSjl=', 'mmonnelly1d@liveinternet.ru', '3981 Mitchell Road');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (51, 'wpenwell1e', 'hO2<|tw2Bq', 'bflintuff1e@techcrunch.com', '08447 Declaration Junction');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (52, 'aleech1f', 'iE3=@ELp@!1#l~', 'kbotfield1f@pen.io', '441 Menomonie Trail');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (53, 'rsoppit1g', 'wX8~LOhMu?_XJi', 'fllywarch1g@prnewswire.com', '4981 Macpherson Avenue');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (54, 'drayman1h', 'uT0+dGYpcrEs>Nr', 'astroband1h@utexas.edu', '0 Oriole Plaza');
INSERT INTO commerce.Customers (CustomerID, UserName, PassWord, Email, Address) VALUES (55, 'ajoan1i', 'oW3=73SfhNzhH', 'kcolvine1i@amazonaws.com', '1 Lyons Point');

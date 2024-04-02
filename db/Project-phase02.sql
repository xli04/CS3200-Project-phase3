CREATE DATABASE IF NOT EXISTS commerce;
USE commerce;

CREATE Table IF NOT EXISTS Small_Business_Seller
(
    BusinessID int          NOT NULL,
    UserName   varchar(100) NOT NULL UNIQUE,
    PassWord   int          Not NULL,
    Email      varchar(50)  NOT NULL,
    Profile    varchar(300) NOT NULL,
    PRIMARY KEY (BusinessID)
);

CREATE TABLE IF NOT EXISTS Orders
(
    OrderID         int          NOT NULL,
    Cost            int          NOT NULL,
    PlacedTime      datetime     NOT NULL,
    Status          int          NOT NULL,
    ShippingAddress varchar(100) NOT NULL,
    PRIMARY KEY (OrderID)
);


CREATE TABLE IF NOT EXISTS Products
(
    ProductID             int          NOT NULL,
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
    CustomerID int          NOT NULL,
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
    EmployeeID int NOT NULL,
    Phone      varchar(10),
    Name       varchar(50),
    PRIMARY KEY (EmployeeID)
);

CREATE TABLE IF NOT EXISTS OrderDetails
(
    ProductID int NOT NULL,
    OrderID   int NOT NULL,
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
    PRIMARY KEY (CustomerID),
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
    ServiceID  int                                         NOT NULL,
    Type       enum ('Return','Exchange','Repair','Other') NOT NULL,
    CustomerID int                                         NOT NULL,
    OrderID    int                                         NOT NULL,
    StartTime  datetime                                    NOT NULL,
    EndTime    datetime                                    NOT NULL,
    RepID      int                                         NOT NULL,
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
    DriverID                int          NOT NULL,
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
    TrackingNumber          int          NOT NULL,
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



-- I vote to not have this table - YuFeng
# CREATE TABLE IF NOT EXISTS Vehicles
# (
#     DriverID Int         NOT NULL,
#     Vehicle  varchar(30) NOT NULL,
#     PRIMARY KEY (DriverID, Vehicle),
#     CONSTRAINT fk_03
#         FOREIGN KEY (DriverID) REFERENCES Drivers (DriverID)
#             on update cascade on delete restrict
# );



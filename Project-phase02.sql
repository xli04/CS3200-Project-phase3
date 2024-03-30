CREATE DATABASE commerce;
USE commerce;

CREATE Table IF NOT EXISTS Small_Business_Seller(
    BusinessID Int NOT NULL,
    UserName varchar(100) NOT NULL UNIQUE,
    PassWord int Not NULL,
    Email varchar(50) NOT NULL,
    Profile varchar(300) NOT NULL,
    PRIMARY KEY (BusinessID)
    -- foreign key
);

CREATE TABLE IF NOT EXISTS Products(
    ProductID Int NOT NULL,
    Price Int Not NULL,
    Units_In_Stock INT NOT NULL,
    ProductName varchar(50) NOT NULL,
    Production_Description varchar(200) NOT NULL,
    PRIMARY KEY (ProductID)
    -- foreign key
);

CREATE TABLE if not exists Business_Orders(
    Seller_id int Not NUll,
    OrderID int not null,
    TotalRevenue int not null,
    PRIMARY KEY(Seller_id, OrderID)
    -- foreign key
);

CREATE TABLE IF NOT EXISTS Customers(
    CustomerID int NOT NULL,
    UserName varchar(50) NOT NULL,
    PassWord varchar(50) NOT NULL,
    Email varchar(50) NOT NULL,
    Address varchar(100) NOT NULL,
    PRIMARY KEY (CustomerID)
    -- foreign key
);

CREATE TABLE IF NOT EXISTS Service(
    ServiceID INT NOT NULL,
    Type INT NOT NULL,
    StartTime DATETIME not null,
    EndTime DATETIME not null,
    CustomerID int NOT NULL,
    PRIMARY KEY(ServiceID)
    -- foreign key
);

CREATE TABLE IF NOT EXISTS PaymentMethod(
    CustomerID int NOT NULL,
    Credit_Debit BOOLEAN NOT NULL,
    E_CHECK BOOLEAN NOT NULL,
    BillingAddress varchar(100) NOT NULL,
    PRIMARY KEY(CustomerID)
    -- foreign key
);

CREATE TABLE IF NOT EXISTS Orders(
    OrderID int NOT NULL,
    Cost int NOT NULL,
    Placed_Time DATETIME NOT NULL,
    Status int NOT NULL,
    Shipping_Address varchar(100) NOT NULL,
    PRIMARY KEY(OrderID)
    -- foreign key, bridge table to products,
);

CREATE TABLE IF NOT EXISTS Cart(
    CustomerID int NOT NULL,
    TotalItems int NOT NULL,
    Total_Price int NOT NULL,
    PRIMARY KEY(CustomerID)
    -- foreign key, multivalued product
);

CREATE TABLE IF NOT EXISTS Product_In_Cart(
    CustomerID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL,
    PRIMARY KEY (CustomerID, ProductID),
    CONSTRAINT fk_01
        FOREIGN KEY (CustomerID) REFERENCES Cart (CustomerID) on update cascade on delete restrict,
    CONSTRAINT fk_02
        FOREIGN KEY (ProductID) REFERENCES Products (ProductID) on update cascade on delete restrict
);

CREATE TABLE IF NOT EXISTS ServiceRepresentative(
    EmployeeID int NOT NULL,
    Phone varchar(10),
    Name varchar(50),
    ClientID int NOT NULL,
    PRIMARY KEY (EmployeeID)
);

CREATE TABLE IF NOT EXISTS Communication(
    ReferenceID int NOT NULL,
    EmployeeID int NOT NULL,
    ClientID int NOT NULL,
    Type enum('Phone','Website','Email','Carrier Pigeon','Walkie Talkie','Talking'),
    Response TEXT NOT NULL,
    PRIMARY KEY (ReferenceID)
);

CREATE TABLE IF NOT EXISTS Service(
    ServiceID int NOT NULL,
    Cost decimal(10,2) NOT NULL,
    Type enum('Return','Exchange','Repair','Other') NOT NULL ,
    CustomerID int NOT NULL,
    PRIMARY KEY (ServiceID)
);

CREATE TABLE IF NOT EXISTS Shippers(
    ShipperID Int NOT NULL,
    CompanyAddress varchar(100) NOT NULL,
    Rating INT NOT NULL,
    PRIMARY KEY (ShipperID)
    -- foreign key
);

CREATE TABLE IF NOT EXISTS Shipping_Detail(
    TrackingNumber int NOT NULL,
    DriverID int NOT NULL,
    ShipperID int NOT NULL,
    Destination varchar(100) NOT NULL,
    Estimated_Shipping_TIme DATETIME NOT NULL,
    Actual_Estimated_Time DATETIME NOT NULL,
    PackageSize Int NOT NULL,
    PRIMARY KEY (TrackingNumber)
    -- foreign key
);

CREATE TABLE IF NOT EXISTS Drivers(
    DriverID Int NOT NULL,
    Age int NOT NULL,
    YearsOfService INT NOT NULL,
    Driver_License_Expiration BOOLEAN NOT NULL,
    Phone varchar(20) NOT NULL,
    PRIMARY KEY (DriverID)
    -- foreign key, multivalued attribute vehicles
);

CREATE TABLE IF NOT EXISTS Vehicles(
    DriverID Int NOT NULL,
    Vehicle varchar(30) NOT NULL,
    PRIMARY KEY(DriverID, Vehicle),
    CONSTRAINT fk_03
        FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID) on update cascade on delete restrict
);



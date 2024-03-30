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

# this is just for test

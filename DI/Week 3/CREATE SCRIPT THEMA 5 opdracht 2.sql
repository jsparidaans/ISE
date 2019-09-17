CREATE DATABASE THEMA_5
USE THEMA_5

CREATE TABLE Customer (
	CustomerID		INT				NOT NULL,
	CustomerName	VARCHAR(40)		NOT NULL

	CONSTRAINT PK_Customer_CustomerID PRIMARY KEY (CustomerID)
)

CREATE TABLE Orders (
	OrderID			INT				IDENTITY,
	CustomerID		INT				NOT NULL,
	OrderDate		DATETIME		NOT NULL,
	OrderStatus VARCHAR(12)

	CONSTRAINT PK_Orders_OrderID PRIMARY KEY (OrderID)
	CONSTRAINT FK_Customer_Orders_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
		ON UPDATE CASCADE
)

CREATE TABLE Product (
	ProductCode		INT				IDENTITY,
	ProductName		VARCHAR(40)		NOT NULL,
	ProductPrice	MONEY			NOT NULL,
	ProductInStock	SMALLINT		NOT NULL
)

CREATE TABLE OrderDetail (
	OrderNr			INT				NOT NULL,
	ProductCode		INT				NOT NULL,
	DetailQuantity	SMALLINT		NOT NULL

	CONSTRAINT PK_OrderDetail_OrderNr_ProductCode PRIMARY KEY (OrderNr, ProductCode)
	CONSTRAINT FK_Orders_OrderDetail_OrderNr FOREIGN KEY (OrderNr) REFERENCES Orders(OrderID),
	CONSTRAINT FK_Product_OrderDetail_ProductCode FOREIGN KEY (ProductCode) REFERENCES Product(OrderCode)
		ON UPDATE CASCADE
)
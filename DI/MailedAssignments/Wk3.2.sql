--5.1	Oplossingen Opdracht stored procedures

USE MASTER
GO
DROP DATABASE IF EXISTS SP_OPGAVEN
GO
CREATE DATABASE SP_OPGAVEN
GO
USE SP_OPGAVEN
GO


--OPGAVEN WERKBOEK:
--1. Maken DB
CREATE TABLE Customer(
	CustomerID INT	NOT NULL,
	CustomerName VARCHAR(40) NOT NULL,
	CONSTRAINT PK_Customer PRIMARY KEY (CustomerID)
	)
GO

CREATE TABLE Orders(
	OrderNr INT	IDENTITY NOT NULL,
	CustomerID INT	NOT NULL,
	OrderDate DATETIME NOT NULL,
	OrderStatus VARCHAR(12) NOT NULL
	CONSTRAINT PK_Orders PRIMARY KEY (OrderNr)
	)
GO

CREATE TABLE Product(
	ProductCode INT	IDENTITY NOT NULL,
	ProductName VARCHAR(40) NOT NULL,
	ProductPrice MONEY NOT NULL,
	ProductsInStock SMALLINT NOT NULL,
	CONSTRAINT PKProduct PRIMARY KEY (ProductCode)
	)
GO

CREATE TABLE OrderDetail(
	OrderNr INT	NOT NULL,
	ProductCode INT	NOT NULL,
	DetailQuantity SMALLINT NOT NULL
	CONSTRAINT PK_OrderDetail PRIMARY KEY (OrderNr,ProductCode)
	)
GO

ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON UPDATE NO ACTION ON DELETE NO ACTION
ALTER TABLE OrderDetail ADD CONSTRAINT FK_OrderDetail_Orders FOREIGN KEY (OrderNr) REFERENCES Orders(OrderNr) ON UPDATE NO ACTION ON DELETE NO ACTION
ALTER TABLE OrderDetail ADD CONSTRAINT FK_OrderDetail_Product FOREIGN KEY (ProductCode) REFERENCES Product(ProductCode) ON UPDATE CASCADE ON DELETE NO ACTION

--2. Vullen DB

INSERT INTO Customer (CustomerID,CustomerName) 
VALUES (18, 'Harrie')

SET IDENTITY_INSERT Orders ON
INSERT INTO Orders (OrderNr,CustomerID, OrderDate, OrderStatus) 
VALUES (12, 18, GETDATE(),'Ready')	--Order 12 van Harrie met status Ready
SET IDENTITY_INSERT Orders OFF

SET IDENTITY_INSERT Product ON
INSERT INTO Product(ProductCode, ProductName, ProductPrice, ProductsInStock) 
VALUES (89, 'TV', 200, 50)
SET IDENTITY_INSERT Product OFF

INSERT INTO OrderDetail (OrderNr, ProductCode, DetailQuantity) 
VALUES (12, 89, 3)					--Order 12 van Harrie bevat een TV

INSERT INTO Product(ProductName, ProductPrice, ProductsInStock) 
VALUES ('Magnetron', 200, 50)

--SELECT * FROM Product

INSERT INTO Orders (CustomerID, OrderDate, OrderStatus) 
VALUES  (18, GETDATE(),'Ready')		--Nog een order voor van Harrie
INSERT INTO OrderDetail (OrderNr, ProductCode, DetailQuantity) 
VALUES (@@IDENTITY, 89, 3) --in @@IDENTITY zit het laatst toegekende IDENTITY waarde (hier Orders.Ordernr)

--3. Stored Procedure zonder parameters. 
-- Schrijf een stored procedure die voor alle records uit Orders die als OrderStatus Ready hebben de CustomerID, 
-- de CustomerName, het OrderNr en de OrderStatus geeft.
-- Test de procedure.
DROP PROCEDURE IF EXISTS SP_GetOrders_StatusReady
GO
CREATE PROCEDURE SP_GetOrders_StatusReady
AS
BEGIN
	--Toont alle records uit Orders die als OrderStatus Ready hebben de CustomerID, 
	--de CustomerName, het OrderNr en de OrderStatus geeft.
	SELECT	C.CustomerID , C.CustomerName, O.OrderNr, O.OrderStatus
	FROM	Orders O INNER JOIN Customer C 
			ON O.CustomerID = C.CustomerID
	WHERE	O.OrderStatus = 'Ready'
END
GO
--Testen
EXECUTE SP_GetOrders_StatusReady
EXEC SP_GetOrders_StatusReady

--4.	Stored Procedure met parameters. Schrijf een stored procedure die, gegeven een OrderStatus, 
-- alle records geeft uit Orders met die OrderStatus. Geef de CustomerID, de CustomerName, het OrderNr en de OrderStatus.
-- Test de procedure.
DROP PROCEDURE IF EXISTS SP_GetOrdersWithStatus
GO
CREATE PROCEDURE SP_GetOrdersWithStatus (
	@OrderStatus VARCHAR(12)
	)
AS
BEGIN
	--Toont alle records uit Orders die als OrderStatus Ready hebben de CustomerID, 
	--de CustomerName, het OrderNr en de OrderStatus geeft.
	SELECT	C.CustomerID , C.CustomerName, O.OrderNr, O.OrderStatus
	FROM	Orders O INNER JOIN Customer C 
			ON O.CustomerID = C.CustomerID
	WHERE	O.OrderStatus = @OrderStatus
END
GO

EXEC SP_GetOrdersWithStatus @OrderStatus = 'Ready'
EXEC SP_GetOrdersWithStatus @OrderStatus = 'New'

--5.	Stored Procedure met parameters en output parameters. 
-- Schrijf een stored procedure die gegeven een CustomerName en 
-- een OrderStatus het aantal orders teruggeeft dat die customer heeft met die OrderStatus. 
-- Test de procedure.
DROP PROCEDURE IF EXISTS SP_GetCountOrdersOfCustomer
GO
CREATE PROCEDURE SP_GetCountOrdersOfCustomer (
	@CustomerName VARCHAR(40),
	@OrderStatus VARCHAR(12),
	@Count		INT OUTPUT
	)
AS
BEGIN
	--Toont alle records uit Orders die als OrderStatus Ready hebben de CustomerID, 
	--de CustomerName, het OrderNr en de OrderStatus geeft.
	SELECT	@Count = COUNT(*)
	FROM	Orders O INNER JOIN Customer C 
			ON O.CustomerID = C.CustomerID
	WHERE	O.OrderStatus = @OrderStatus
	AND		C.CustomerName = @CustomerName
	--of zo:
	--SET @Count = (SELECT	COUNT(*)
	--			FROM	Orders O INNER JOIN Customer C 
	--					ON O.CustomerID = C.CustomerID
	--			WHERE	O.OrderStatus = @OrderStatus
	--			AND		C.CustomerName = @CustomerName)
END
GO
DECLARE @CountOrders INT 
EXEC SP_GetCountOrdersOfCustomer 
		@CustomerName='Harrie', 
		@OrderStatus = 'Ready', @Count = @CountOrders OUTPUT
SELECT @CountOrders

--6.	Maak een stored procedure die bij een insert checkt 
--		of een kolom wel een not null waarde heeft. 
--		Is dit een zinnige sp? Verklaar je antwoord.
DROP PROCEDURE IF EXISTS SP_InsertCustomer
GO
CREATE PROCEDURE SP_InsertCustomer(
	@CustomerID		INT,
	@CustomerName	VARCHAR(40)
)
AS
BEGIN
	
	IF @CustomerID IS NULL 
		RAISERROR ('Customer must be non-empty', 16, 1) --zinloos !!
	ELSE
		IF @CustomerName IS NULL
			RAISERROR ('Customername must be non-empty', 16, 1) --zinloos !!
		ELSE
			INSERT INTO Customer (CustomerID, CustomerName)
			VALUES (@CustomerID,@CustomerName)
END
GO

EXEC SP_InsertCustomer @CustomerID = 3, @CustomerName = 'Karel'
EXEC SP_InsertCustomer @CustomerID = 4, @CustomerName = NULL

--Mooier met errorhandling
DROP PROCEDURE IF EXISTS SP_InsertCustomer
GO
CREATE PROCEDURE SP_InsertCustomer(
	@CustomerID		INT,
	@CustomerName	VARCHAR(40)
)
AS
BEGIN
	BEGIN TRY
		IF @CustomerID IS NULL 
			RAISERROR ('Customer must be non-empty', 16, 1) --zinloos !!
		IF @CustomerName IS NULL
				RAISERROR ('Customername must be non-empty', 16, 1) --zinloos !!
		INSERT INTO Customer (CustomerID, CustomerName)
		VALUES (@CustomerID,@CustomerName)
	END TRY	
	BEGIN CATCH
		THROW
	END CATCH
END
GO





--7.	Maak een stored procedure met ��n parameter @sortParameter van type varchar die:
--a.	Als @sortParameter = �OrderDate� alle records uit Orders geeft gesorteerd op column �OrderDate�
--b.	Als @sortParameter = �OrderStatus� alle records uit Orders geeft gesorteerd op column �OrderStatus�
--c.	In alle andere gevallen een foutmelding geeft.


DROP PROCEDURE IF EXISTS SP_GetOrdersSorted
GO
CREATE PROCEDURE SP_GetOrdersSorted(
	@sortParameter VARCHAR(11)
	)
AS
BEGIN
	IF @sortParameter = 'OrderDate' --a
		SELECT *
		FROM Orders
		ORDER BY OrderDate
	ELSE
		IF @sortParameter = 'OrderStatus' --b
			SELECT *
			FROM Orders
			ORDER BY OrderStatus
		ELSE			--c
			RAISERROR ('Wrong sort argument: %s', 16, 1, @sortParameter)
END
GO


--TESTDATA
INSERT INTO Orders (CustomerID , OrderDate, OrderStatus )
VALUES (18, GETDATE() + 1, 'New'),  (18, GETDATE() + 5, 'New')

EXEC SP_GetOrdersSorted @sortParameter = 'OrderDate'
EXEC SP_GetOrdersSorted @sortParameter = 'OrderStatus'
EXEC SP_GetOrdersSorted @sortParameter = 'Dummy'

--OF


DROP PROC IF EXISTS SP_GetOrdersSorted
GO
CREATE PROC SP_GetOrdersSorted
	@sortParameter VARCHAR(40)
AS
BEGIN
	IF @sortParameter NOT IN ('OrderStatus','OrderDate')
	BEGIN
		RAISERROR('No valid column to order by given.',16,1)
		RETURN --lelijk...
	END

	SELECT * 
	FROM Orders 
	ORDER BY 
		CASE 	WHEN @sortParameter = 'OrderStatus' THEN OrderStatus
		END,
		CASE	WHEN @sortParameter = 'OrderDate' THEN OrderDate
		END
	ASC
END
GO
EXEC SP_GetOrdersSorted @sortParameter = 'OrderDate'
EXEC SP_GetOrdersSorted @sortParameter = 'OrderStatus'
EXEC SP_GetOrdersSorted @sortParameter = 'Dummy'

--

DROP PROC IF EXISTS SP_GetOrdersSorted
GO
CREATE PROC SP_GetOrdersSorted
	@sortParameter VARCHAR(40)
AS
BEGIN
	IF @sortParameter NOT IN ('OrderStatus','OrderDate')
	BEGIN
		RAISERROR('No valid column to order by given.',16,1)
		RETURN
	END

	SELECT * 
	FROM Orders 
	ORDER BY 
		CASE WHEN @sortParameter = 'OrderStatus' THEN OrderStatus
			WHEN @sortParameter = 'OrderDate' THEN CAST(OrderDate AS VARCHAR(30))
		END
	ASC
END
GO
EXEC SP_GetOrdersSorted @sortParameter = 'OrderDate'
EXEC SP_GetOrdersSorted @sortParameter = 'OrderStatus'
EXEC SP_GetOrdersSorted @sortParameter = 'Dummy'

--
--nog een fraaie uitwerking (MET NETTE FOUTAFHANDELING!):
DROP PROC IF EXISTS SP_GetOrdersSorted
GO
CREATE PROC SP_GetOrdersSorted
  @sortParameter  VARCHAR(40)
AS
	BEGIN TRY
		IF @sortParameter NOT IN ('ORDERDATE','ORDERSTATUS')
		  RAISERROR ('Ongeldige waarde %s voor @sortParameter', 16, 1, @sortParameter);
		ELSE  
			SELECT * 
			FROM Orders 
			ORDER BY CASE @sortParameter
			   WHEN 'ORDERDATE' THEN CAST(ORDERDATE AS VARCHAR(30))
			   WHEN 'ORDERSTATUS' THEN ORDERSTATUS
			  END
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
GO

--
DROP PROC IF EXISTS SP_GetOrdersSorted
GO
CREATE PROC SP_GetOrdersSorted
	@sortParameter VARCHAR(40)
AS
BEGIN
	BEGIN TRY
		SELECT * 
		FROM Orders 
		ORDER BY 
			CASE WHEN @sortParameter = 'OrderStatus' THEN OrderStatus
				WHEN @sortParameter = 'OrderDate' THEN CAST(OrderDate AS VARCHAR(30))
				ELSE CAST(1/0 AS VARCHAR(1))--erg lelijk !!
			END
		ASC
	END TRY
	BEGIN CATCH
		IF @@ERROR = 8134
			RAISERROR('No valid column to order by given.',16,1)
		ELSE
			THROW
	END CATCH
END
GO
EXEC SP_GetOrdersSorted @sortParameter = 'OrderDate'
EXEC SP_GetOrdersSorted @sortParameter = 'OrderStatus'
EXEC SP_GetOrdersSorted @sortParameter = 'Dummy'


--Aanvullend van student:

RAISERROR(15600,-1,-1,'SP_GetOrdersSorted') --> Maakt gebruik van bestaande system message : 
				--An invalid parameter or option was specified for procedure 'SP_GetOrdersSorted'.

--Welke messages zijn er allemaal?

SELECT *
FROM sysmessages m inner join syslanguages l ON m.msglangid = l.msglangid
WHERE name = 'nederlands'
and error = 15600

--'An invalid parameter or option was specified for procedure '%s'.
--'Er is voor procedure %1! een ongeldige parameter of optie opgegeven.'

set language Dutch
RAISERROR(15600,-1,-1,'SP_GetOrdersSorted') 


RAISERROR ('Ongeldige waarde %s voor %s', 16, 1, 'A', 'B')



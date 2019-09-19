/*
Checken wie uitwerkingen extra Set opdrachten StudentInKlas gemaakt heeft.

Mijn globale planning voor de komende lessen:
•	Woensdag 11-09; wil ik Constraints en T-SQL afronden. 
•	Donderdag 12-09; bezoek belastingdienst (geen les dus…)
•	Maandag 16-09; thema Stored Procedures behandelen
•	Woensdag 18-09; SP huiswerkopdrachten bespreken en Oefentoets 1 maken + bespreken. 
•	Donderdag 19-09: Toets 1, daarna pas verder met lesweek 3 stof (tSQLt testen en Triggers).
*/ 
DROP DATABASE IF EXISTS THEMA_CONSTRAINTS
GO

CREATE DATABASE THEMA_CONSTRAINTS
GO
USE THEMA_CONSTRAINTS
GO
-------------------------------------------------------------
--Opdracht 1:
-------------------------------------------------------------
CREATE TABLE Product(
	ProductCode INT NOT NULL,
	ProductName VARCHAR(40) NOT NULL,
	ProductPrice MONEY NOT NULL,
	ProductsInStock SMALLINT NOT NULL,
	CONSTRAINT PK_Product PRIMARY KEY (ProductCode)
)
GO

--Als de waarde van ProductName gelijk is aan TELEVISION 
--dan moet de waarde van ProductPrice minstens 200 zijn.


ALTER TABLE Product WITH CHECK 
ADD CONSTRAINT CHK_ProductNameTelevisionPriceMoreThan200
CHECK (
	(PRODUCTNAME = 'TELEVISION' AND  ProductPrice >= 200)
	OR
	(PRODUCTNAME != 'TELEVISION')
	)










--Poging 1: alle toegestane combinatie benoemen
ALTER TABLE Product
DROP CONSTRAINT IF EXISTS CH_PRODUCT_IS_TELEVISION_THEN_PRICE_MIN_200 

ALTER TABLE Product
ADD CONSTRAINT CH_PRODUCT_IS_TELEVISION_THEN_PRICE_MIN_200 
CHECK (
		(ProductName != 'Television' AND ProductPrice < 200) OR
		(ProductName != 'Television' AND ProductPrice >= 200) OR 
		(ProductName = 'Television' AND ProductPrice >= 200) 
	)	


--Poging 2: wat compacter maken, prijs is niet relevant als het geen Television is
ALTER TABLE Product
DROP CONSTRAINT IF EXISTS CH_PRODUCT_IS_TELEVISION_THEN_PRICE_MIN_200 

ALTER TABLE Product
ADD CONSTRAINT CH_PRODUCT_IS_TELEVISION_THEN_PRICE_MIN_200 
CHECK (
		(ProductName != 'Television') OR 
		(ProductName = 'Television' AND ProductPrice >= 200) 
	)	

--Testen
SELECT * FROM Product

DELETE FROM Product
		
INSERT INTO Product (ProductCode ,ProductName,ProductPrice,ProductsInStock)
VALUES	(1, 'MAGNETRON', 150, 1)		--> 1. moet goed gaan
INSERT INTO Product (ProductCode ,ProductName,ProductPrice,ProductsInStock)
VALUES	(2, 'MAGNETRON', 250, 1)	--> 2. moet goed gaan
INSERT INTO Product (ProductCode ,ProductName,ProductPrice,ProductsInStock)
VALUES	(3, 'TELEVISION', 250, 1)	--> 3. moet goed gaan
INSERT INTO Product (ProductCode ,ProductName,ProductPrice,ProductsInStock)
VALUES	(4, 'TELEVISION', 150, 1)	--> 4. moet FOUT gaan !

--Poging 3: zie wetten van De Morgan uit [WIEGERINK] blz 129
--ALS A DAN B
--(NOT A) OR B
--Als "de waarde van ProductName gelijk is aan TELEVISION"
		-- A => ProductName = 'TELEVISION' --
--DAN "moet de waarde van ProductPrice minstens 200 zijn"
		-- B => ProductPrice >= 200

ALTER TABLE Product
DROP CONSTRAINT IF EXISTS CH_PRODUCT_IS_TELEVISION_THEN_PRICE_MIN_200 

ALTER TABLE Product
ADD CONSTRAINT CH_PRODUCT_IS_TELEVISION_THEN_PRICE_MIN_200 
CHECK (
	NOT  (ProductName = 'TELEVISION') OR ProductPrice >= 200
)

-------------------------------------------------------------
--Opdracht 2:
-------------------------------------------------------------
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Person' AND TABLE_TYPE = 'BASE TABLE')
DROP TABLE Person
GO
CREATE TABLE Person
(ID		INT IDENTITY 	NOT NULL,
 Name		VARCHAR(30) 	NOT NULL,
 Prefix		VARCHAR(10) 	NULL,
 NamePartner	VARCHAR(30) 	NULL,
 PrefixPartner	VARCHAR(10) 	NULL,
 Presentation	INT 		NOT NULL,-- 1 = Name, 2 = Name + Partner, 3 = Partner  + Name, 4 = Partner
 Sex		CHAR(1) NOT NULL,	-- M = Male, F = Female
 Initials		VARCHAR(10) NOT NULL,
 CONSTRAINT PK_Person PRIMARY KEY (ID)
)

GO
/*
Voeg na het aanmaken van de tabel een CHECK-constraint toe die de volgende business 
rule bewaakt: 
Als de waarde van Presentation ongelijk is aan 1 
dan moet de waarde van NamePartner bekend zijn.
Voeg dan de volgende records toe: 
*/
--testen met
INSERT INTO dbo.Person 
		(Name,			Prefix,	NamePartner,	PrefixPartner,	Presentation,Sex,Initials) 
VALUES	('LastName1',	NULL,	NULL,			NULL,			1,			'M','AB') 	--moet goed gaan
INSERT INTO dbo.Person 
		(Name,			Prefix,	NamePartner,	PrefixPartner,	Presentation,Sex,Initials) 
VALUES	('LastName2',	NULL,	'Partner2',		NULL,			2,			'M','CD') 	--moet goed gaan

INSERT INTO dbo.Person 
		(Name,			Prefix,		NamePartner,PrefixPartner,	Presentation,Sex,Initials) 
VALUES	('LastName3',	'van der',	'Partner5',	NULL,			1,			'F','GH') 	--moet goed gaan
INSERT INTO dbo.Person
		(Name,			Prefix,		NamePartner,PrefixPartner,	Presentation,Sex,Initials) 
VALUES	('LastName4',	'van der',	NULL,		NULL,			2,			'F','GH') 	--moet fout gaan

--ALS A DAN B
-- A:  waarde van Presentation ongelijk is aan 1   >> Presentation != 1
-- B:  moet de waarde van NamePartner bekend zijn. >> NamePartner IS NOT NULL
--implementeren als:
--(NOT A) OR B
ALTER TABLE Person
ADD CONSTRAINT CHK_Pres_Name CHECK (
										(NOT (Presentation != 1)) OR 
										NamePartner IS NOT NULL
									)

--of nog fraaier:

ALTER TABLE Person
ADD CONSTRAINT CHK_Pres_Name CHECK (
										(Presentation = 1) OR 
										NamePartner IS NOT NULL
									)
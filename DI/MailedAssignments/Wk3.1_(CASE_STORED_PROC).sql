
-------------------------------------------------------------
--Huiswerk opgave Thema T-SQL
--Opdracht 2:
-------------------------------------------------------------

-- Opgave CASE statement huidige dag in het nederlands, nog niet als functie

-- Syntax for SQL Server and Azure SQL Database  
  
--Simple CASE expression:
-- CASE input_expression
--      WHEN when_expression THEN result_expression [ ...n ]   
--      [ ELSE else_result_expression ]   
-- END   
--Searched CASE expression:  
-- CASE  
--      WHEN Boolean_expression THEN result_expression [ ...n ]   
--      [ ELSE else_result_expression ]   
-- END


DECLARE @date datetime
SET @date = '20190916'
SELECT CASE DATEPART(WEEKDAY, @date) --Let op: afhankelijk van taalinstelling
	       		WHEN 1 THEN 'zondag'
	       		WHEN 2 THEN 'maandag'
	       		WHEN 3 THEN 'dinsdag'
	       		WHEN 4 THEN 'woensdag'
	       		WHEN 5 THEN 'donderdag'
	       		WHEN 6 THEN 'vrijdag'
	       		WHEN 7 THEN 'zaterdag'
	       	 END
--Of

SELECT CASE DATEPART(WEEKDAY, GETDATE()) --Let op: afhankelijk van taalinstelling
	       		WHEN 1 THEN 'zondag'
	       		WHEN 2 THEN 'maandag'
	       		WHEN 3 THEN 'dinsdag'
	       		WHEN 4 THEN 'woensdag'
	       		WHEN 5 THEN 'donderdag'
	       		WHEN 6 THEN 'vrijdag'
	       		WHEN 7 THEN 'zaterdag'
	       	 END

SELECT CASE DATENAME(WEEKDAY, GETDATE()) --Let op: afhankelijk van taalinstelling
	       	WHEN 'sunday' THEN 'zondag'
	       	WHEN 'monday' THEN 'maandag'
	       	WHEN 'tuesday' THEN 'dinsdag'
	       	WHEN 'wednesday' THEN 'woensdag'
	       	WHEN 'thursday' THEN 'donderdag'
	       	WHEN 'friday' THEN 'vrijdag'
	       	WHEN 'saterday' THEN 'zaterdag'
	       	END

--We kunnen taal ook instellen
--Werkt zolang de connectie actief is

--cheat:
SET LANGUAGE DUTCH
SELECT DATENAME(WEEKDAY, GETDATE())

SELECT @@language --Huidige taal opvragen

SELECT * --alle talen 
FROM syslanguages


/*
--Permanent wijzigen van de default taal:
EXEC sp_configure 'default language', 7 ; --7 komt overeen met Dutch
GO
RECONFIGURE ;
GO

*/

--Ander voorbeeld met een CASE expressie

SELECT CASE WHEN genrenaam = 'jazz' OR genrenaam = 'klassiek' THEN 'mooi'
			WHEN genrenaam = 'pop' THEN 'nog mooier'
			ELSE 'niks an'
		END
FROM Stuk

--Thema Stored Procedures:
--Zie sheet 7
BEGIN TRY
	--Experimenteer met 1..10
	--RAISERROR ('custom error', 6, 1) 
	--RAISERROR ('custom error', 10, 1) 
	--Experimenteer met 11...18 (19 kun je niet gebruiken, is gereserveerd voor systeem)
	--RAISERROR ('custom error', 16, 1) --16 is veel gebruikt severity level bij user defined errors
	--RAISERROR ('custom error', 17, 1) 
	PRINT '1. kom ik hier?'
END TRY
BEGIN CATCH
	PRINT '2. kom ik hier?'
	;THROW
END CATCH

--THROW versus RAISERROR
go
THROW 50000, 'foutje', 1	--Severity level is standaard 16
	/*
	Msg 50000, Level 16, State 1, Line 102
	foutje
	*/
--is vergelijkbaar met
RAISERROR ('foutje', 16, 1)	--Error number is default 50000
	/*
	Msg 50000, Level 16, State 1, Line 108
	foutje
	*/

--Sheet 10
USE AdventureWorks2014
GO
--Definition
--Aanmaken van SP
CREATE PROCEDURE spEmployee
AS
BEGIN
   SELECT * FROM HumanResources.Employee
END

--Uitvoeren met
EXEC spEmployee
--of
EXECUTE spEmployee
go

--Wijzigen van bestaande SP
ALTER PROCEDURE spEmployee
AS
BEGIN
   SELECT * FROM HumanResources.Employee
END
GO
--Droppen van SP
DROP PROCEDURE spEmployee

----------------------------------------------------------------------------
--Wat EXTRA SP oefenopgaven:
----------------------------------------------------------------------------
USE MuziekdatabaseUitgebreid 
GO
--Maak een SP dat van een gegeven Genre alle stukken van dat genre
--retourneert. Noem de SP spGeefStukkenVanGenre

ALTER PROC spGeefStukkenVanGenre
	@genrenaam VARCHAR(10)
AS
BEGIN

	SELECT *
	FROM Stuk 
	WHERE genrenaam LIKE @genrenaam
			

END
GO

select * from genre

--testen
EXEC spGeefStukkenVanGenre @genrenaam = 'jazzzzzzzz'

--Geef vervolgens een nette foutmelding wanneer je geen records 
--vindt van dit genre. Gebruik oa: @@ROWCOUNT, TRY CATCH, THROW/RAISERROR

--Oplossing:
go
ALTER PROC spGeefStukkenVanGenre
	@genrenaam VARCHAR(10)
AS
BEGIN
	BEGIN TRY
		SELECT *
		FROM Stuk 
		WHERE genrenaam LIKE @genrenaam
		IF @@ROWCOUNT = 0
			THROW 50000, 'Geen records gevonden',1
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--of zo:
ALTER PROC spGeefStukkenVanGenre
	@genrenaam VARCHAR(10)
AS
BEGIN
	BEGIN TRY
		IF (SELECT COUNT(*) 
			FROM Stuk 
			WHERE genrenaam LIKE @genrenaam) = 0
			--THROW 50000, 'Geen records gevonden',1
			--of zo:
			RAISERROR ('Geen records gevonden', 16, 1)
		ELSE
			SELECT *
			FROM Stuk 
			WHERE genrenaam LIKE @genrenaam
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--Gegeven de volgende constraint:
--Er mogen maximaal 5 genres vastgelegd worden:
--Maak een INSERT stored procedure die controleert en
--alleen het genre vastlegt wanneer dat maximum nog niet bereikt is

CREATE PROC spInsertGenre
	@genrenaam VARCHAR(10)
AS 
BEGIN
	BEGIN TRY
		--hier komt de logica
		IF (SELECT COUNT(*) FROM Genre) >= 5
			THROW 50000, 'Er mogen maximaal 5 genres vastegeldg worden', 1
		ELSE
			INSERT INTO Genre VALUES (@genrenaam)
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--Testen
BEGIN TRAN
SELECT COUNT(*) FROM Genre --nu 4

EXEC spInsertGenre @genrenaam = 'hiphop' --moet goed gaan

SELECT COUNT(*) FROM Genre --nu 5
EXEC spInsertGenre @genrenaam = 'house' --moet fout gaan

EXEC spInsertGenre @genrenaam = 'jazz' --moet fout gaan

ROLLBACK TRAN


----------------------------------------------------------------------------
-- Systeem Stored Procedures
----------------------------------------------------------------------------
--Een voorbeeld is de sp_Help (zie master database)

EXEC sp_help 'Stuk' --geeft definitie (meta data) van de Stuk tabel

--Script tSQLt

===================================================================================================================================
--USE [vul hier de database naam in]

USE [UnitTesting COURSE] --in mijn geval

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
===================================================================================================================================
--DEMO 1
===================================================================================================================================
--Unit testing van constraint code – demo docent + oefening student  

--HEEL BELANGRIJK: de testomgeving tSQLt zorgt ervoor dat al je tests in een zogenaamde transactie
--draaien. Dat betekent dat alles wat er in een test wordt gedaan, aan het eind van de test ongedaan wordt gemaakt.
--Dus als je een tabelletje aanmaakt en deze vult met data, en een bestaande tabel leeggooit in een test,
--dan wordt na je testrun als laatste actie alles weer volledig hersteld!!! 

--Heel handig, en wel zo veilig.

--Laten we eens de anatomie van een test procedure (hetgeen een gewone stored procedure is geschreven in T-SQL, maar wel een die moet beginnen met
--het keyword test!!!) bekijken

--Test SPROC Template
--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [test schema naam waar je een set tests logisch in wilt clusteren].[test = verplicht keyword, maar
daarna staat het vrij om een semantische beschrijving van de test als naam te gebruiken, zie voorbeeld hieronder]
AS
BEGIN
  --Assemble
	--  This section is for code that sets up the environment. It often
	--  contains calls to methods such as tSQLt.FakeTable and tSQLt.SpyProcedure
	--  along with INSERTs of relevant data.
	--  For more information, see http://tsqlt.org/user-guide/isolating-dependencies/

	--	Aanvulling: hier definieer je je testomgeving, maakt bijvoorbeeld benodigde tabellen aan 
	--	en creëer je de testdata

	--	Een in deze sectie zeer veelgebruikte framework procedure is tSQLt.FakeTable. Deze procedure maakt een tabel aan met
	--	de naam van een originele tabel maar sloopt daar alle constraints vanaf. Voordeel daarvan is dat de tabel
	--	dan acties op de tabel dan niet gehinderd worden door andere constraints (dependencies in testen willen we niet,
	--	test van louter een stukje code in isolatie, dat willen we graag). Later zien we meer sprocs toepassingen in de assemble
	--	sectie  
  
  --Act
	-- Execute the code under test like a stored procedure, function, view, trigger or constraint
	-- and capture the results in variables or tables.

  --Assert
	--  Compare the expected and actual values, or call tSQLt.Fail in an IF statement.  
	--  Available Asserts: tSQLt.AssertEquals, tSQLt.AssertEqualsString, tSQLt.AssertEqualsTable and a lot more
	--  For a complete list, see: http://tsqlt.org/user-guide/assertions/
	EXEC tSQLt.Fail 'TODO:Implement this test.' 
	--	Standaard aanwezig met het oog op test driven development
	--	Je maakt immers een test voor je gaat coderen als je aan TD development doet
	--	Je test moet dan in eerste instantie falen! 
END;
GO
--Ok daar gaan we dan. Denk in het voorbeeld van de casus aan het testen van een check constraint
--op de tabel employee (er zijn al 6 chk constraints geïmplementeerd). We nemen als voorbeeld de constraint die de 
--check op de jobtypes doet. 

--Zie script constraints: ALTER TABLE [dbo].[emp]  WITH CHECK ADD  CONSTRAINT [emp_chk_job] CHECK  (([job]='ADMIN' OR [job]='TRAINER' OR [job]='SALESREP' OR [job]='MANAGER' OR [job]='PRESIDENT'))

--De code bestaat al dus van testdriven design is geen sprake. We gaan de bestaande code checken op correctheid.

--Laten we als test eens proberen een employee met jop type PROF toe te voegen. Dat zou dus niet mogen!

--We beginnen met het aanmaken van een klasse (dat wordt een schema, zeg maar een namespace in SQL Server)
--waarin we de tests logisch bundelen onder een logische naam

EXEC tSQLt.NewTestClass 'testEmployeeCheckConstraints';

--Hiermee wordt een schema object aangemaakt waarin we alle te creëren tests (en andere daarbij benodigde objecten) kunnen clusteren 
--Zoek het net aangemaakte schema object even op in de folder Security/Schemas
GO

--Dan maken we een test procedure aan die we later gaan runnen.

--Eerst zonder iets gedefinieerd te hebben dus zo maar eens het kale template even gebruiken voor aanmaken.
--Ik strip hem van alles wat nu niet nodig is


CREATE PROCEDURE [testEmployeeCheckConstraints].[test op blokkeren van een niet voorkomend functietype]
AS
BEGIN
  --Assemble 
  --Act
  --Assert
  EXEC tSQLt.Fail 'TODO:Implement this test.'  
END;

GO
--Executeer dit of een dergelijk (andere naam mag natuurlijk) create statement.

--Voer vervolgens de test eens uit.

EXEC [tSQLt].[RunAll] 
--tSQLt is de schemanaam van het test framework zelf, RunAll is een stored procedure in dat schema die
--die doet wat de naam eigenlijk als zegt, voer alle tests uit, hetgeen nu nog slechts één test betreft.
GO
EXEC [tSQLt].[Run] 'testEmployeeCheckConstraints.[test op blokkeren van een niet voorkomend functietype]'
--Excuteert alleen de genoemde test 
go

--Het resultaat van het uitvoeren van de test, te vinden op de messages tabpage in SSMS, tref je ingeplakt 
--hieronder aan.

/*

(1 row affected)
[testEmployeeCheckConstraints].[test op blokkeren van een niet voorkomend functietype] failed: (Failure) TODO:Implement this test.
 
+----------------------+
|Test Execution Summary|
+----------------------+
 
|No|Test Case Name                                                                        |Dur(ms)|Result |
+--+--------------------------------------------------------------------------------------+-------+-------+
|1 |[testEmployeeCheckConstraints].[test op blokkeren van een niet voorkomend functietype]|      3|Failure|
-----------------------------------------------------------------------------
Msg 50000, Level 16, State 10, Line 108
Test Case Summary: 1 test case(s) executed, 0 succeeded, 1 failed, 0 errored.
-----------------------------------------------------------------------------

*/

--Wat is het dat we eigenlijk willen?

--Ik wil een maximaal geïsoleerde testomgeving, in dit geval een kopie van de oorspronkelijke tabel
--zonder inhoud, met alleen de te testen constraint erop. Daarin wil ik een insert trachten te doen
--met "foute" data. Dat mag vervolgens niet lukken om de test te laten slagen.

--Eerste poging:
ALTER /*we wijzigen de reeds bestaande template gebaseeerde SPROC */ PROCEDURE 
[testEmployeeCheckConstraints].[test op blokkeren van een niet voorkomend functietype]
AS
BEGIN
	DECLARE @OEPSIE bit = 0; 
	--nu faken van de tabel, strippen van alle constraints, lege tabel
	EXEC tSQLt.FakeTable 'dbo', 'emp'; --dbo is het default schema igv create table 
	--nu de te testen constraint er weer opzetten, deze bestaat namelijk al
	EXEC tSQLt.ApplyConstraint @SchemaName= 'dbo', @Tablename = 'emp', @ConstraintName = 'emp_chk_job';
	BEGIN TRY
		--we gaan een foute rij data in tabel emp proberen te zetten, een foute rij zou een level 16 error vd check
		--constraint violation moeten opleveren hetgeen een jump naar catch ten gevolge heeft
		insert into emp(empno,ename,job,born,hired,sgrade,msal,username,deptno)
		values(null,null,'PROF',null,null,null,null,null,null); 
		--alle constraints zijn verwijderd en slechts de check constraint is er weer opgezet
		--vandaar een insert statement met alleen een foute job waarde, isoleren van
		--mogelijke andere fout veroorzakende code!!!
	END TRY
	BEGIN CATCH
		SET @OEPSIE = 1  
		-- dan is de test geslaagd want door de insert in de tabel met slechts 1 constraint erop
		-- kan eigenlijk alleen via de chck violation in het catch block gekomen worden (maar 100% zeker 
		-- is dat ook weer niet niet; er kunnen ook nog andere exceptions opgegooid worden b.v. als er geen opslagruimte
		-- meer beschikbaar is of de datafile is corrupt)
	END CATCH
	IF (@OEPSIE = 0)
    BEGIN
        EXEC tSQLt.Fail 'Jobtype ingevoerd dat niet in tabel geplaatst mag worden';
    END
END
GO

EXEC [tSQLt].[Run] 'testEmployeeCheckConstraints.test op blokkeren van een niet voorkomend functietype'
GO

/*

(1 row affected)
 
+----------------------+
|Test Execution Summary|
+----------------------+
 
|No|Test Case Name                                                                        |Dur(ms)|Result |
+--+--------------------------------------------------------------------------------------+-------+-------+
|1 |[testEmployeeCheckConstraints].[test op blokkeren van een niet voorkomend functietype]|    914|Success|
-----------------------------------------------------------------------------
Test Case Summary: 1 test case(s) executed, 1 succeeded, 0 failed, 0 errored.
-----------------------------------------------------------------------------

*/
--Ter controle!!

SELECT * FROM dbo.EMP 
--De tabel is na de test weer beschikbaar met zijn oude inhoud, en de constraints er allemaal 
--weer opgezet; de transactie is inderdaad ongedaan gemaakt
GO

--Ok, dit werkt, maar is niet bijster fraai. Eigenlijk ben je nog steeds zelf de meeste logica aan het uitprogrammeren
--Kan dit niet fraaier, meer gebruikmakend van functionaliteit voorhanden in het tSQLt framework?

--Tweede poging, maar nu iets meer gebruikmakend van functionaliteiten in het tSQLt framework voorhanden

--Er bestaat een stored procedure ExpectException

ALTER PROCEDURE [testEmployeeCheckConstraints].[test op blokkeren van een niet voorkomend functietype]
AS
BEGIN
	--voorbereiden
		--faken van de tabel, strippen van alle constraints, lege tabel
	EXEC tSQLt.FakeTable 'dbo', 'emp'; --dbo is het default schema igv create table 
	--nu de te testen constraint er weer opzetten, deze bestaat namelijk al
	EXEC tSQLt.ApplyConstraint @SchemaName= 'dbo', @Tablename = 'emp', @ConstraintName = 'emp_chk_job';

	EXEC tSQLt.ExpectException 
	--actie
	insert into emp(empno,ename,job,born,hired,sgrade,msal,username,deptno)
	values(null,null,'PROF',null,null,null,null,null,null); 
END
GO

EXEC [tSQLt].[Run] 'testEmployeeCheckConstraints.test op blokkeren van een niet voorkomend functietype'

--Bijna dezelfde test maar nu met een toegestaan jobtype! kortom de test moet dan dus falen want er
--wordt een exception verwacht, maar die komt er dan hopelijk niet omdat toevoegen van een MANAGER 
--vlgs de constraint mag!!! 
GO

ALTER PROCEDURE [testEmployeeCheckConstraints].[test op blokkeren van een niet voorkomend functietype]
AS
BEGIN
	--voorbereiden
		--faken van de tabel, strippen van alle constraints, lege tabel
	EXEC tSQLt.FakeTable 'dbo', 'emp'; --dbo is het default schema igv create table 
	--nu de te testen constraint er weer opzetten, deze bestaat namelijk al
	EXEC tSQLt.ApplyConstraint @SchemaName= 'dbo', @Tablename = 'emp', @ConstraintName = 'emp_chk_job';

	EXEC tSQLt.ExpectException
	--actie
	insert into emp(empno,ename,job,born,hired,sgrade,msal,username,deptno)
	values(null,null,'MANAGER',null,null,null,null,null,null); 
END
GO

EXEC [tSQLt].[Run] 'testEmployeeCheckConstraints.test op blokkeren van een niet voorkomend functietype'
GO

--Oefeningen:

--Aan jullie de eer om enkele tests te schrijven die als test de invoer van een correcte waarde controleert (er bestaat 
--ook een tSQLt procedure ExpectNoException :-) ) en verkeerde (lowercase) job waarde blokkeren, etc. 

--Schrijf tests voor de emp_chk_msal constraint die controleert dat alleen salarissen boven de 0 
--euro ingevoerd mogen worden.  

--Je kunt nu ook proberen de casusopdrachten die betrekking hebben op check constraints test driven 
--te gaan aanpakken. mocht je nog niet begonnen zijn. 
--Heb je al wel constraints geïmplementeerd kan je deze alsnog gaan testen op correctheid als je niet 
--met het handje al allerlei testjes hebt geschreven.

===================================================================================================================================
--DEMO 2
===================================================================================================================================
--Unit testing van stored procedure  code – demo docent + oefening student

--Stel dat we een stored procedure willen ontwikkelen die de volgende requirement moet afdwingen:
	--Het moet mogelijk zijn een nieuwe employee te inserten, maar,
	--er mag te allen tijde maar maximaal één werknemer de president van het bedrijf in kwestie zijn.

--We starten als we test driven design gebaseerd willen gaan ontwikkelen met het neerzetten van een testklasse 
--en een template voor de in eerste instantie nog lege test.

--Maak een schema aan waarin we alle tests mbt deze requirement gaan clusteren.

EXEC tSQLt.NewTestClass 'testMaxPresidents1';
GO

CREATE PROCEDURE [testMaxPresidents1].[test die controleert dat een eerste werknemer van type president opgenomen kan worden]
AS
BEGIN
  --Assemble 
  --Act
  --Assert
  --  For a complete list, see: http://tsqlt.org/user-guide/assertions/
  EXEC tSQLt.Fail 'TODO:Implement this test.'  
END;

GO

EXEC  tSQLt.[Run] 'testMaxPresidents1.test die controleert dat een eerste werknemer van type president opgenomen kan worden';

--We beginnen met een eerste test te bouwen 

--De testopzet zou als volgt kunnen zijn:
--maak een constraintloze lege kopie van de emp tabel en maak een dummy tabel met exact dezelfde structuur aan
--insert in de dummy een werknemer met job president
--bouw de insert procedure en gebruik deze vervolgens om een rij in de lege constraintloze emp tabel te zetten
--vergelijk de tabellen: als de inhoud gelijk is dan is deze test geslaagd!  

--Nu deze opzet nader uitwerken
GO

ALTER PROCEDURE [testMaxPresidents1].[test die controleert dat een eerste werknemer van type president opgenomen kan worden]
AS
BEGIN
	--Assemble 
	--We maken slim een tabelletje aan waar we het verwachte resultaat in
	--gaan aangeven in termen van data rijen door deze er daadwerkelijk in te inserten

	DROP TABLE IF EXISTS [testMaxPresidents1].[verwacht]  --is de tabel er al/nog mik hem dan weg, kan eigenlijk niet bestaan

	SELECT TOP 0 * 
	INTO [testMaxPresidents1].[verwacht] --snelle manier om een structuur te "kopiëren"
	FROM dbo.emp;

	--zet een gegarandeerd goede rij in de verwachtresultaat tabel
	--uit het dml script vd casus geplukt
	INSERT INTO [testMaxPresidents1].[verwacht](empno,ename,job,born,hired,sgrade,msal,username,deptno)
	VALUES(1000,'Hans','PRESIDENT','1957-12-22','1992-01-01',11,15500,'HANS',10);

	/*
	kan ook in één keer zo:
	SELECT * 
	INTO [testMaxPresidents1].[verwacht]
	FROM (VALUES(1000,'Hans','PRESIDENT','1957-12-22','1992-01-01',11,15500,'HANS',10))
		  AS emp (empno,ename,job,born,hired,sgrade,msal,username,deptno)
	*/

  --Dan maken we de kale lege emp kopie aan
	EXEC tSQLt.FakeTable 'dbo', 'emp';
		
  --We bouwen of hebben dat al gedaan onze stored procedure die de insert van employees regelt, 
  --maar eveneens controleert dat er maar één president mag zijn.
  --Een eerste versie van de mogelijke code tref je hieronder al aan. 
  --Executeer deze, maar beter, bouw zelf de sproc (zie oefeningen werkboek sprocs; had je eigenlijk 
  --al moeten doen als huiswerk!!)
  --We gebruiken die stored procedure om die gegarandeerd goede nieuwe werknemer van type president 
  --toe te voegen aan de kale, constraintloze (gefake-te) emp tabel

	  /* de sproc code 
	 ALTER PROCEDURE dbo.sp_InsertNewPresident
	(@empno numeric(4),
	 @ename varchar(8),
	 @job varchar(9),
	 @born date,
	 @hired date,
	 @sgrade numeric(2,0),
	 @msal numeric(7,2),
	 @username varchar(15),
	 @deptno numeric(2,0)
	)
	AS
	BEGIN
	BEGIN TRY
		--testen of er al een president bestaat
		IF EXISTS (SELECT '' FROM emp where @job = 'PRESIDENT')
		THROW 50001, 'No more than one president allowed', 1
		INSERT INTO emp(empno,ename,job,born,hired,sgrade,msal,username,deptno)
		VALUES (@empno, @ename, @job, @born, @hired, @sgrade, @msal, @username, @deptno);
	END TRY
	BEGIN CATCH
		;THROW
	END CATCH
	END
	*/
  --Act
	EXEC  dbo.sp_InsertNewPresident @empno=1000, @ename = 'Hans', @job ='PRESIDENT', @born = '1957-12-22',
	@hired = '1992-01-01', @sgrade = 11, @msal = 15500,@username = 'HANS', @deptno = 10;
  --Assert
	EXEC tSQLt.[AssertEqualsTable] '[testMaxPresidents1].[verwacht]', 'dbo.emp', 'Tables do not match, insert of employee failed'
END;
GO

--Verwacht resultaat is dat de test slaagt, want de tabelletjes verwacht en dbo.emp bevatten als het (de code) goed is inderdaad dezelfde inhoud
EXEC tSQLt.Run 'testMaxPresidents1.test die controleert dat een eerste werknemer van type president opgenomen kan worden'
--Zie hieronder het verwachte resultaat van de test
/*
(1 row(s) affected)
 
+----------------------+
|Test Execution Summary|
+----------------------+
 
|No|Test Case Name                                                                                              |Dur(ms)|Result |
+--+------------------------------------------------------------------------------------------------------------+-------+-------+
|1 |[testMaxPresidents1].[test die controleert dat een eerste werknemer van type president opgenomen kan worden]|    616|Success|
-----------------------------------------------------------------------------
Test Case Summary: 1 test case(s) executed, 1 succeeded, 0 failed, 0 errored.
-----------------------------------------------------------------------------
*/

--We moeten op zijn minst één tweede test maken we die gaat controleren dat er inderdaad maar één president in de database 
--kan voorkomen

CREATE PROCEDURE [testMaxPresidents1].[test die controleert dat een nieuwe president niet opgenomen kan worden als er al een is]
AS
BEGIN
	--Assemble 
	--Maak een kale constraintloze versie van dbo.emp aan
	EXEC tSQLt.FakeTable 'dbo', 'emp';
	--Zet een gegarandeerd goede eerste president rij in dbo. emp
	INSERT INTO dbo.emp(empno,ename,job,born,hired,sgrade,msal,username,deptno)
	VALUES(1000,'Hans','PRESIDENT','1957-12-22','1992-01-01',11,15500,'HANS',10);

	--Act
	--Omdat ik volledige controle heb over te verwachten boodschap, die heb ik immers zelf zo gecodeerd,
	--test ik specifiek op het raisen van deze boodschap! 
	EXEC [tSQLt].[ExpectException] @ExpectedMessage = 'No more than one president allowed', @ExpectedSeverity = 16, @ExpectedErrorNumber = 50001 
	EXEC  dbo.sp_InsertNewPresident @empno=2000, @ename = 'Hans', @job ='PRESIDENT', @born = '1957-12-22',
	@hired = '1992-01-01', @sgrade = 11, @msal = 15500,@username = 'HANS', @deptno = 10;
END;
go

--Verwacht resultaat is dat ook deze test slaagt, want de boodschap komt er uit als de sproc code ok is
EXEC tSQLt.Run 'testMaxPresidents1.test die controleert dat een nieuwe president niet opgenomen kan worden als er al een is'

EXEC tSQLt.RunAll
/*
(1 row(s) affected)
 
+----------------------+
|Test Execution Summary|
+----------------------+
 
|No|Test Case Name                                                                                                 |Dur(ms)|Result |
+--+---------------------------------------------------------------------------------------------------------------+-------+-------+
|1 |[testMaxPresidents1].[test die controleert dat een nieuwe president niet opgenomen kan worden als er al een is]|    166|Success|
-----------------------------------------------------------------------------
Test Case Summary: 1 test case(s) executed, 1 succeeded, 0 failed, 0 errored.
-----------------------------------------------------------------------------
*/

--Oefeningen testen stored procedures:
--Schrijf tests voor andere stored procedures uit het werkboek die je afgelopen week al hebt gemaakt.
--Je kunt de extra oefeningen stored procedures die op de casus gebaseerd zijn gaan maken en testen.

TOT HIER

===================================================================================================================================
--DEMO 3
===================================================================================================================================
--Unit testing van trigger  code – demo docent + oefening student

--De nadruk ligt in deze workshop op het testen van code objecten waarmee we de integriteit van onze data 
--willen bewaken. We hebben inmiddels gezien hoe declaratie constraints en stored procedures getest kunnen worden, 
--nu richten we de aandacht op database triggers

--Stel we willen dezelfde integriteitregel die we ook in de sectie stored procedure testen hebben mbv een stored procedure hebben
--geïmplementeerd testen. DE trigger zou er als volgt uit kunnen zien:

/*
CREATE TRIGGER insupdEmpMaxOnePresident
ON Emp
AFTER INSERT, UPDATE
AS
BEGIN
	BEGIN TRY
		IF @@ROWCOUNT = 0
			RETURN
		IF EXISTS (SELECT '' FROM emp where job = 'PRESIDENT' GROUP BY job HAVING COUNT(*) > 1)
			THROW 50002, 'Maximaal een werknemer kan president zijn.', 1
	END TRY
	BEGIN CATCH
		THROW
	END CATCH	  	 
END
GO 
*/
--Test 1
--We bouwen als eerste een test die controleert of een insert van een de eerste werknemer met jobtype PRESIDENT inderdaad toegestaan is
--In de test maken we een lege tabel zonder constraints (en triggers) aan, plaatsen vervolgens de trigger op de gefake-te tabel

CREATE PROCEDURE [testMaxPresidents1].[test die controleert dat een nieuwe president opgenomen kan worden ondanks de trigger]
AS
BEGIN
	--Assemble 
	--maak een kale constraintloze versie van dbo.emp aan
	EXEC tSQLt.FakeTable 'dbo', 'emp';
	EXEC [tSQLt].[ApplyTrigger] @tablename = 'dbo.emp', @triggername = 'insupdEmpMaxOnePresident'
	--we hebben nu een kale tabel, met daarop op dit moment slechts één trigger gespecificeerd (waren er meer geweest
	--hadden we nu deze andere triggers buitenspel gezet ==> isoleren
	--ik verwacht dat een insert slaagt, dus geen exception raised, dus daar zou ik op kunnen testen
	--maar het kan ook anders. dat laat ik zo ook nog zien
	--Act
	EXEC [tSQLt].[ExpectNoException] --als er geen exceptioN geraised wordt slaagt dus de test
	INSERT INTO dbo.emp(empno,ename,job,born,hired,sgrade,msal,username,deptno)
	VALUES(1000,'Hans','PRESIDENT','1957-12-22','1992-01-01',11,15500,'HANS',10);
END;
GO

EXEC tSQLt.Run 'testMaxPresidents1.test die controleert dat een nieuwe president opgenomen kan worden ondanks de trigger'

--Resultaat
/*
(1 row(s) affected)
 
+----------------------+
|Test Execution Summary|
+----------------------+
 
|No|Test Case Name                                                                                              |Dur(ms)|Result |
+--+------------------------------------------------------------------------------------------------------------+-------+-------+
|1 |[testMaxPresidents1].[test die controleert dat een nieuwe president opgenomen kan worden ondanks de trigger]|  60710|Success|
-----------------------------------------------------------------------------
Test Case Summary: 1 test case(s) executed, 1 succeeded, 0 failed, 0 errored.
-----------------------------------------------------------------------------
*/
--nb: de test nam om de een of andere reden een minuut!! 

--Nu een wat andere aanpak die echt op het voorkomen van identieke data vergelijkt ipv op de de afwezigheid van een exception test

CREATE PROCEDURE [testMaxPresidents1].[test die controleert dat een nieuwe president opgenomen kan worden ondanks de trigger versie equals tables]
AS
BEGIN
	--Assemble 
	IF OBJECT_ID('[testMaxPresidents1].[verwacht]','Table') IS NOT NULL
	DROP TABLE [testMaxPresidents1].[verwacht]

	--maak een tabel aan met dezelfde structuur als dbo.emp
	SELECT TOP 0 * 
	INTO testMaxPresidents1.verwacht --snelle manier om een structuur te "kopiëren"
	FROM dbo.emp;
	--zet er een correcte rij aan data in, een president
	INSERT INTO testMaxPresidents1.verwacht(empno,ename,job,born,hired,sgrade,msal,username,deptno)
	VALUES(1000,'Hans','PRESIDENT','1957-12-22','1992-01-01',11,15500,'HANS',10);
	--maak een kale emp kopie aan zonder iets erop gedefinieerd, ook geen constraint
	EXEC tSQLt.FakeTable 'dbo', 'emp';
	--zet de trigger nu op deze tabel
	EXEC [tSQLt].[ApplyTrigger] @tablename = 'dbo.emp', @triggername = 'insupdEmpMaxOnePresident'
	--Act
	--voeg nu de president rij toe aan de kale nog lege tabel emp
	INSERT INTO dbo.emp(empno,ename,job,born,hired,sgrade,msal,username,deptno)
	VALUES(1000,'Hans','PRESIDENT','1957-12-22','1992-01-01',11,15500,'HANS',10);
	--Assert
	--check nu dat beide tabellen dezelfde inhoud hebben 
	EXEC [tSQLt].[AssertEqualsTable] 'testMaxPresidents1.verwacht', 'dbo.emp'
END;
go

EXEC tSQLt.Run 'testMaxPresidents1.test die controleert dat een nieuwe president opgenomen kan worden ondanks de trigger versie equals tables'

/*
(1 row(s) affected)
 
+----------------------+
|Test Execution Summary|
+----------------------+
 
|No|Test Case Name                                                                                                                   |Dur(ms)|Result |
+--+---------------------------------------------------------------------------------------------------------------------------------+-------+-------+
|1 |[testMaxPresidents1].[test die controleert dat een nieuwe president opgenomen kan worden ondanks de trigger versie equals tables]|  61013|Success|
-----------------------------------------------------------------------------
Test Case Summary: 1 test case(s) executed, 1 succeeded, 0 failed, 0 errored.
-----------------------------------------------------------------------------
*/
--iets sneller maar nog steeds erg traag

--Maak nu zelf een test die de trigger daadwerkelijk test op zijn hoedanigheid om een tweede PRESIDENT te voorkomen. Let op de acties die 
--een schending kunnen veroorzaken. Je hebt meerdere tests nodig

--Schrijf nu zelf een trigger en test deze: to be done... 

EXEC tSQLt.RunAll
/************************************************************************************
We maken vandaag 2 databases:

1. Maak [COURSE] Database
Deze database gebruiken jullie voor het maken van de casus

2. Maak [UnitTesting COURSE] Database 
Deze database gebruiken we vandaag als demonstratiedatabase voor het maken van enkele unit testen
gebruik makend van het tSQLt framework. We gebruiken ook hier de [COURSE] database. 
We maken hierin dus: de COURSE database + het tSQLt framework + tSQLt Unit test scripts

Na afloop:
Voor de casus moeten jullie vervolgens de [COURSE] database 
uitbreiden met het tSQLt framework + o.a. alle constraints uit de casus + uit eigen gemaakt tests voor deze constraints
************************************************************************************/


USE MASTER
GO
DROP DATABASE IF EXISTS  [UnitTesting COURSE]
GO
CREATE DATABASE [UnitTesting COURSE]
GO

PRINT 'Run in deze test database nu de scripts om de COURSE database aan te maken (voor deze demo) inclusief testdata en constraints zoals meegeleverd.'
/************************************************************************************
Maak Course database
Run:
1. a basic create table script (COURSE_cretab.sql)
2. an insert script (COURSE_database_state.sql) and 
3. a constraints creation script (COURSE_constraints.sql). 
Run these scripts in the order as listed above and study these scripts.
************************************************************************************/

/************************************************************************************
Zet de tSQLt test omgeving op, zie: https://tsqlt.org/user-guide/quick-start/

1. Download tSQLt from SourceForge						>> Staat bij ons op Onderwijs Online.
2. Unzip the file to a location on your hard drive.
3. Make sure CLRs are enabled on your development server by running the following sql:

Wil je meer weten over tSQLt kijk dan eens op https://app.pluralsight.com/library/courses/unit-testing-t-sql-tsqlt/table-of-contents

************************************************************************************/

EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;

/************************************************************************************
4. Execute the Example.sql file from the zip file to create an example database 
(tSQLt_Example) with tSQLt and test cases.				>> Slaan wij in de les over, maar doe dat in je eigen tijd
5. See below for installing tSQLt into your own development database >> Zie de website, o.a. :

1. Your database must be set to trustworthy for tSQLt to run. 
Execute the following script in your development database:

************************************************************************************/

DECLARE @cmd NVARCHAR(MAX);
SET @cmd='ALTER DATABASE ' + QUOTENAME(DB_NAME()) + ' SET TRUSTWORTHY ON;';
EXEC(@cmd);

/************************************************************************************
2. Execute the tSQLt.class.sql script (included in the zip file) in your development database.
 >> Resultaat:
 +-----------------------------------------+
|                                         |
| Thank you for using tSQLt.              |
|                                         |
| tSQLt Version: 1.0.5873.27393           |
|                                         |
+-----------------------------------------+
************************************************************************************/

PRINT 'Voer nu het script tSQLt.class.sql uit op deze database ! '

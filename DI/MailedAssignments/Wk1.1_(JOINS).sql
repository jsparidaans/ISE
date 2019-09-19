--Geef een SQL SELECT statement voor elk van de onderstaande informatiebehoeften.
--1.	Geef voor elk klassiek stuk het stuknr, de titel en de naam van de componist. 

SELECT S.stuknr, S.titel , C.naam
FROM Stuk S 
	INNER JOIN Componist C ON S.componistId = C.componistId
WHERE S.genrenaam = 'klassiek'

SELECT S.stuknr, S.titel , C.naam
FROM Stuk S 
	LEFT JOIN Componist C ON S.componistId = C.componistId
WHERE S.genrenaam = 'klassiek'

SELECT S.stuknr, S.titel , C.naam
FROM Stuk S 
	JOIN Componist C ON S.componistId = C.componistId
WHERE S.genrenaam = 'klassiek'

SELECT S.stuknr, S.titel , C.naam
FROM Stuk S 
	JOIN Componist C ON S.componistId = C.componistId
WHERE S.genrenaam LIKE '%klassiek%'

SELECT S.stuknr, S.titel , C.naam
FROM Stuk S 
	JOIN Componist C ON S.componistId = C.componistId
WHERE S.genrenaam LIKE 'klassiek'


--2.	Welke stukken zijn gecomponeerd door een muziekschooldocent? 
--Geef van de betreffende stukken het stuknr, de titel, de naam van de 
--componist en de naam van de muziekschool.

--muziekschooldocent: docent die gekoppeld is aan een muziekschool (schoolid is not null)

SELECT S.stuknr, S.titel , C.naam, M.naam 
FROM Stuk S 
	INNER JOIN Componist C ON S.componistId = C.componistId
	INNER JOIN Muziekschool M ON C.schoolId = M.schoolId 

--minder fraai, maar levert wel de juiste gegevens op:
SELECT S.stuknr, S.titel , C.naam, M.naam 
FROM Stuk S 
	INNER JOIN Componist C ON S.componistId = C.componistId
	LEFT JOIN Muziekschool M ON C.schoolId = M.schoolId 
WHERE C.schoolId IS NOT NULL



--3.	Bij welke stukken (geef stuknr en titel) bestaat de bezetting uit 
--ondermeer een saxofoon? 
--Opmerking: Gebruik een subquery.

SELECT S.stuknr , S.titel
FROM Stuk S 
WHERE S.Stuknr IN  (
		SELECT stuknr
		FROM Bezettingsregel 
		WHERE instrumentnaam = 'saxofoon')

SELECT DISTINCT S.stuknr , S.titel
FROM Stuk S INNER JOIN Bezettingsregel B ON S.stuknr = B.stuknr 
WHERE instrumentnaam = 'saxofoon'


--4.	Bij welke stukken wordt de saxofoon niet gebruikt?
--niet goed is:
SELECT S.stuknr , S.titel
FROM Stuk S 
WHERE S.Stuknr IN  (
		SELECT stuknr
		FROM Bezettingsregel 
		WHERE instrumentnaam != 'saxofoon')

--wel goed:
SELECT S.stuknr , S.titel
FROM Stuk S 
WHERE S.Stuknr NOT IN  (
		SELECT stuknr
		FROM Bezettingsregel 
		WHERE instrumentnaam = 'saxofoon')

--niet goed:
SELECT DISTINCT S.stuknr , S.titel
FROM Stuk S INNER JOIN Bezettingsregel B ON S.stuknr = B.stuknr 
WHERE instrumentnaam != 'saxofoon'

--5.	Bij welke jazzstukken worden twee of meer verschillende instrumenten gebruikt?


SELECT stuknr, titel
FROM Stuk s
WHERE   genrenaam = 'jazz' AND
        stuknr IN ( SELECT stuknr 
					FROM Bezettingsregel
                    GROUP BY stuknr
                    HAVING COUNT(stuknr)>1)

select s.stuknr, s.titel--, S.genrenaam, B.instrumentnaam , B.toonhoogte , B.aantal 
from stuk s
inner join Bezettingsregel b on s.stuknr = b.stuknr
where genrenaam = 'jazz'
group by s.stuknr, s.titel
having count(*) > 1

select s.stuknr, s.titel, S.genrenaam, B.instrumentnaam , B.toonhoogte , B.aantal 
from stuk s
inner join Bezettingsregel b on s.stuknr = b.stuknr
where genrenaam = 'jazz'
group by s.stuknr, s.titel
having count(instrumentnaam) > 1





SELECT Stuk.titel, Bezettingsregel.stuknr, count(Bezettingsregel.stuknr) as Aantal_instrumenten
FROM Stuk inner join Bezettingsregel on Stuk.stuknr = Bezettingsregel.stuknr
WHERE Stuk.genrenaam like 'jazz'
GROUP BY Bezettingsregel.stuknr, Stuk.titel
HAVING count(Bezettingsregel.stuknr) >= 2

select s.titel, count(m.stuknr) 'aantal', s.genrenaam
from stuk s join Bezettingsregel m
    on s.stuknr = m.stuknr
group by titel, s.genrenaam
having count(m.stuknr) >= 2 
    and s.genrenaam = 'jazz'
    


--6.	Geef het aantal originele muziekstukken per componist. 
--Ook componisten met nul originele stukken dienen te worden getoond.

SELECT C.componistId, COUNT(Stuknr)
FROM Componist C 
	LEFT JOIN Stuk S ON C.componistId = S.componistId
				AND S.stuknrOrigineel IS NULL --wordt uitgevoerd vóór de left join
GROUP BY C.componistId 

--testdata
INSERT INTO Componist VALUES (99,'Misja',getdate(),null)


--7.	Geef voor elk niveau de niveaucode, 
--de omschrijving en het aantal klassieke speelstukken. 
--Opmerking: Dus ook als er voor een niveau geen 
--klassieke speelstukken zijn.

SELECT N.niveaucode, N.omschrijving , COUNT(stuknr) AS Aantal
FROM Niveau N 
	LEFT JOIN Stuk S ON N.niveaucode = S.niveaucode 
			AND genrenaam = 'klassiek'
GROUP BY N.niveaucode, N.omschrijving  

SELECT N.niveaucode, N.omschrijving , COUNT(stuknr) AS Aantal
FROM Niveau N 
	LEFT JOIN (SELECT *
			FROM Stuk S 
			WHERE genrenaam = 'klassiek') AS K
			ON N.niveaucode = K.niveaucode 
GROUP BY N.niveaucode, N.omschrijving  

SELECT N.niveaucode, N.omschrijving , COUNT(stuknr) AS Aantal
FROM Niveau N 
	LEFT JOIN Stuk S ON N.niveaucode = S.niveaucode 
WHERE genrenaam = 'klassiek' OR stuknr is null -- of genrenaam IS NULL
GROUP BY N.niveaucode, N.omschrijving  

SELECT *
FROM Niveau N 
	LEFT JOIN Stuk S ON N.niveaucode = S.niveaucode 
--8.	Geef het nummer en de naam van de muziekscholen 
--waarvoor meer dan drie speelstukken bestaan die gecomponeerd 
--zijn door docenten van de betreffende school.

SELECT M.schoolId , M.naam , COUNT(S.stuknr)
FROM Componist C INNER JOIN Stuk S ON C.componistId = S.componistId
	INNER JOIN Muziekschool M ON C.schoolId = M.schoolId
GROUP BY M.schoolId , M.naam 
HAVING COUNT(*) > 3

--9.	Voorspel uit hoeveel rijen het resultaat van de 
--volgende query bestaat:

	SELECT	*
	FROM	Componist, Muziekschool;
	--8 comp * 3 muz = 24
	--

--	Ga vervolgens na of je voorspelling correct is.
--	Opmerking: Deze query heeft hetzelfde effect als 
--	SELECT	*
--	FROM	Componist CROSS JOIN Muziekschool;


--10.	Stel de tabel Componist is gedefinieerd zonder een 
--UNIQUE-constraint op de kolom naam. 
--Als je deze constraint toevoegt m.b.v. een ALTER TABLE statement, 
--dan lukt dat niet als er dubbele waarden voorkomen in de kolom naam.
--Geef een SELECT-statement waarmee je de rijen met een 
--niet-unieke componistnaam kunt opsporen.

SELECT *
FROM Componist 
WHERE naam IN(
	SELECT naam -- COUNT(*) 
	FROM Componist 
	GROUP BY naam
	HAVING COUNT(*) > 1	)
						 


--11.	Geef twee UPDATE-statements waarmee alle stukken 
--van docenten van Muziekschool Sonsbeek op niveaucode C gezet worden, als de niveaucode not null was: 
--gebruik Ms SQL Server’s multiple tables UPDATE optie beschreven in 
--the SQL Bible op pagina’s 302 tm 305 en scrhijf een ANSI SQL subquery variant.  

BEGIN TRANSACTION 

UPDATE Stuk
SET niveaucode = 'C'
FROM Muziekschool M INNER JOIN Componist C ON M.schoolId = C.schoolId  --geen ansi
	INNER JOIN Stuk S ON C.componistId = S.componistId 
WHERE M.naam = 'Muziekschool Amsterdam'


UPDATE Stuk --ansi variant 
SET niveaucode = 'C'
WHERE Stuknr IN (
	SELECT S.stuknr
	FROM Muziekschool M INNER JOIN Componist C ON M.schoolId = C.schoolId 
		INNER JOIN Stuk S ON C.componistId = S.componistId 
	WHERE M.naam = 'Muziekschool Amsterdam'
	)

UPDATE Stuk	--ansi variant 
SET niveaucode = 'C'
WHERE  componistId IN (
	SELECT  C.componistId
	FROM Muziekschool M INNER JOIN Componist C ON M.schoolId = C.schoolId  
	WHERE M.naam = 'Muziekschool Amsterdam'
	)

	
UPDATE Stuk
SET niveaucode = 'C'
FROM Stuk INNER JOIN Componist C  ON Stuk.componistId = C.componistId --geen ansi
WHERE  C.schoolid IN (
	SELECT  C.componistId
	FROM Muziekschool M  
	WHERE M.naam = 'Muziekschool Amsterdam'
	)

SELECT * FROM Stuk
ROLLBACK TRANSACTION
SELECT * FROM Stuk

--Plaats je statements tussen een BEGIN TRANSACTION - ROLLBACK TRANSACTION statement combinatie. Daarmee worden wijzigingen aan de data uiteindelijk weer ongedaan gemaakt terwijl resultaten tijdelijk wel beschikbaar zijn voor controle op correctheid. 

--BEGIN TRANSACTION 
--		<jouw UPDATE/DELETE statement>
--		<jouw SQL SELECT controle statement>
--	          ROLLBACK TRANSACTION

--12.	Geef twee DELETE-statements waarmee alle bezettingsregels 
--van stukken van docenten van Muziekschool Sonsbeek verwijderd worden: 
--gebruik Ms SQL Server’s multiple tables DELETE optie beschreven 
--in the SQL Bible op pagina’s 310 tm 312 en scrhijf een ANSI SQL subquery variant.  

--Gebruik weer onderstaande transactie statements.

--BEGIN TRANSACTION 
--		<jouw UPDATE/DELETE statement>
--		<jouw SQL SELECT controle statement>
--ROLLBACK TRANSACTION

--Meer over transacties volgt in in het thema Concurrency.

DELETE
FROM Bezettingsregel --wel ansi
WHERE stuknr IN (--stukken van docenten van Sonsbeek
		SELECT S.stuknr 
		FROM Muziekschool M 
			INNER JOIN Componist C ON M.schoolId = C.schoolId  --geen ansi
			INNER JOIN Stuk S ON C.componistId = S.componistId 
		WHERE M.naam = 'Muziekschool Sonsbeek' 
		)

DELETE Bezettingsregel 
FROM Muziekschool M 
			INNER JOIN Componist C ON M.schoolId = C.schoolId  --geen ansi
			INNER JOIN Stuk S ON C.componistId = S.componistId 
			INNER JOIN Bezettingsregel B ON B.stuknr = S.stuknr 
WHERE M.naam = 'Muziekschool Sonsbeek' 

	
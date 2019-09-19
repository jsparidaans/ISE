-- Thema Advanced SQL:
-- Sheet 23
-- Geef de componisten die zowel voor fluit 
-- als voor saxofoon speelstukken (stukken met een niveauaanduiding) hebben
/*
SELECT componistid, naam
FROM componist c
WHERE 	   er bestaat voor die componist een speelstuk met fluit
		       AND
		    er bestaat voor die componist een speelstuk met saxofoon
*/
SELECT componistid, naam
FROM componist c
WHERE EXISTS (SELECT 1
              FROM stuk s
				 INNER JOIN bezettingsregel b
				 ON s.stuknr = b.stuknr
			   WHERE b.instrumentnaam = 'fluit'
				 AND s.niveaucode IS NOT NULL
			     AND componistid = c.componistid)
		  AND 
		  EXISTS (SELECT 1
              FROM stuk s
				 INNER JOIN bezettingsregel b
				 ON s.stuknr = b.stuknr
			   WHERE b.instrumentnaam = 'saxofoon'
				 AND s.niveaucode IS NOT NULL
			     AND componistid = c.componistid)

--Extra opgaven:
-- Geef de componisten die voor fluit 
-- en/of voor saxofoon speelstukken (stukken met een niveauaanduiding) hebben
SELECT componistid, naam
FROM componist c
WHERE EXISTS (SELECT 1
              FROM stuk s
				 INNER JOIN bezettingsregel b
				 ON s.stuknr = b.stuknr
			   WHERE 
			     (b.instrumentnaam = 'fluit' OR b.instrumentnaam = 'saxofoon')
			     AND componistid = c.componistid)
--Extra opgaven:
-- Geef de componisten die een stuk hebben gecomponeerd waar zowel een fluit 
-- als een saxofoon in zit (dus in hetzelfde stuk!)
SELECT *
FROM Componist C
WHERE EXISTS 
	--er bestaat voor deze componist een stuk 
	(SELECT *
	FROM Stuk S
	WHERE S.componistId = C.componistId
	--en er bestaat voor dat stuk een bezettingsregel met een fluit
		AND EXISTS (
					SELECT *
					FROM Bezettingsregel B
					WHERE B.stuknr = S.stuknr
					AND B.instrumentnaam = 'fluit'
					)
	--en er bestaat voor dat stuk een bezettingsregel met een saxofoon
		AND EXISTS (
					SELECT *
					FROM Bezettingsregel B
					WHERE B.stuknr = S.stuknr
					AND B.instrumentnaam = 'saxofoon'
					)
	)

--Extra opgaven:
-- Geef de componisten die een stuk hebben gecomponeerd waar een fluit 
-- maar geen saxofoon in zit (dus in hetzelfde stuk!)

SELECT *
FROM Componist C
WHERE EXISTS 
	--er bestaat voor deze componist een stuk 
	(SELECT *
	FROM Stuk S
	WHERE S.componistId = C.componistId
	--en er bestaat voor dat stuk een bezettingsregel met een fluit
		AND EXISTS (
					SELECT *
					FROM Bezettingsregel B
					WHERE B.stuknr = S.stuknr
					AND B.instrumentnaam = 'fluit'
					)
	--en er bestaat voor dat stuk geen bezettingsregel met een saxofoon
		AND NOT EXISTS (
					SELECT *
					FROM Bezettingsregel B
					WHERE B.stuknr = S.stuknr
					AND B.instrumentnaam = 'saxofoon'
					)
	)

--Sheet 26:
--Geef alle instrumenten (naam en toonhoogte) die NIET gebruikt worden in stukken
	SELECT instrumentnaam, toonhoogte
	FROM instrument i
	WHERE NOT EXISTS	  
		(SELECT 1	   
		FROM	bezettingsregel	   
		WHERE	i.instrumentnaam = instrumentnaam	    --correlatie met de hoofdquery
		AND		i.toonhoogte = toonhoogte)				--correlatie met de hoofdquery

--kan niet op deze manier: (we moeten controleren op de combinatie instrumentnaam en toonhoogte)
	SELECT instrumentnaam, toonhoogte
	FROM instrument i
	WHERE i.instrumentnaam NOT IN	  
		(SELECT instrumentnaam	   
		FROM	bezettingsregel)
	AND  i.toonhoogte NOT IN	  
		(SELECT toonhoogte	   
		FROM	bezettingsregel)
--kan ook niet op deze alternatieve (en lelijke) manier:
SELECT instrumentnaam, toonhoogte
	FROM instrument i
	WHERE i.instrumentnaam + i.toonhoogte NOT IN	  
		(SELECT instrumentnaam + toonhoogte	   
		FROM	bezettingsregel)
	

USE MuziekdatabaseUitgebreid
GO
--Huiswerk opgaven:
--2.1	Opdrachten EXISTS operator en gecorreleerde subquery’s
--		Gebruik in de volgende opdrachten de EXISTS-operator.
--1.	Geef stuknr en titel van elk stuk waar een piano in meespeelt.
SELECT stuknr, titel
FROM Stuk s
WHERE EXISTS (
    SELECT *
    FROM Bezettingsregel b
    WHERE s.stuknr = b.stuknr
    AND b.instrumentnaam = 'piano')

--2.	Geef stuknr en titel voor elk stuk waar géén piano in meespeelt.
SELECT stuknr, titel
FROM Stuk s
WHERE NOT EXISTS (
    SELECT *
    FROM Bezettingsregel b
    WHERE s.stuknr = b.stuknr
    AND b.instrumentnaam = 'piano')
--Stukken met alleen maar piano's
SELECT stuknr, titel
FROM Stuk s
WHERE EXISTS (
    SELECT *
    FROM Bezettingsregel b
    WHERE s.stuknr = b.stuknr
    AND b.instrumentnaam = 'piano')
AND NOT EXISTS (
    SELECT *
    FROM Bezettingsregel b
    WHERE s.stuknr = b.stuknr
    AND b.instrumentnaam != 'piano')

--3.	Geef instrumenten (instrumentnaam + toonhoogte) die niet worden gebruikt (in bezettingsregel en in ??).
SELECT *
FROM Instrument I
WHERE NOT EXISTS(
	--komt niet voor in bezettingsregel
	SELECT *
	FROM Bezettingsregel B
	WHERE B.instrumentnaam = I.instrumentnaam 
	AND B.toonhoogte = I.toonhoogte 
	)
	--en komt ook niet voor in StudentInstrument
	AND NOT EXISTS(
	SELECT *
	FROM StudentInstrument SI
	WHERE SI.instrumentnaam = I.instrumentnaam 
	AND SI.toonhoogte = I.toonhoogte 
	)


--4.	Geef componistId en naam van iedere componist die meer dan 1 stuk heeft gecomponeerd.

SELECT	componistId, naam
FROM	Componist c
WHERE EXISTS(
    SELECT *
	FROM	Stuk S 
	WHERE	s.componistId = c.componistId
	GROUP BY s.componistId
	HAVING	COUNT(*) > 1
	)

SELECT S.componistId, C.naam
FROM Stuk S INNER JOIN Componist C
	ON C.componistId = S.componistId
GROUP BY S.componistId, C.naam
HAVING COUNT(S.stuknr) >= 2

SELECT C.componistId, C.naam 
FROM Componist C
WHERE (	SELECT COUNT(*) 
		FROM Stuk 
		WHERE componistId = C.componistId) > 1

--Sheet 31:
-- Geef de verschillende componisten die geen stukken geschreven hebben (EXCEPT)
-- Dus ALLE componisten EXCEPT Componisten die stukken hebben gecomponeerd

SELECT	componistId, naam
FROM	Componist 
EXCEPT
SELECT	Componist.componistId, naam
FROM	Stuk INNER JOIN Componist ON Stuk.componistId = Componist.componistId  

SELECT * --als we meer van de componist willen zien
FROM Componist 
WHERE componistId IN (
	SELECT	componistId
	FROM	Componist 
	EXCEPT
	SELECT	componistId
	FROM	Stuk )


--voor testen
INSERT INTO Componist VALUES(99, 'Jan', GETDATE(), NULL)
DELETE FROM Componist WHERE componistId = 99

--Huiswerk opgaven:
--2.1	Opdrachten EXISTS operator en gecorreleerde subquery’s
--		Gebruik in de volgende opdrachten de EXISTS-operator

--5.	Geef alle originele stukken (STUKNRORIGINEEL IS NULL) 
	--waar geen bewerkingen van zijn. (NOT EXISTS EEN Bewerking, Stuknr =? Stuknrorigineel)
	

--6.	Geef de drie oudste stukken (zonder top te gebruiken). LASTIG !
		--IETS MET PER STUK TELLEN HOEVEEL STUKKEN OUDER ZIJN DAN DIT STUK
		--Goed testen!

--7.	Is er een stuk waarin alle instrumenten meespelen?

stukken waarvoor geen instrument bestaat dan niet in bezettingsregel zit
of 
per stuk tellen hoeveel instrumenten erin zitten en dat moet gelijk zijn aan het totaal aantal
instrumenten

--8.	(Geen EXISTS) Maak een lijst van stukken, gesorteerd op lengte, en zorg voor een rangnummer 
--		(waarbij stukken van gelijke lengte hetzelfde rangnummer krijgen).














--9.	Geef een query voor de volgende informatiebehoefte:
--		Geef geordende paren van stukken die precies dezelfde bezetting hebben. 
--		Ook als beide stukken geen bezettingsregels hebben. 
--		Voorbeeldoutput van de gevraagde query bij de oorspronkelijke populatie van de Muziekdatabase:

--stuknr                 stuknr
----------------------------------------- ----------------------
--1                    8
--1                    10
--8                    10
--Er zijn namelijk in de oorspronkelijk gegeven populatie geen stukken met bestaande bezettingsregels 
--die precies hetzelfde zijn. Daarom moeten er bij de oorspronkelijke populatie die stukken uitkomen die 
--helemaal geen bezettingsregels hebben: stukken 1, 8 en 10.

--Maar stel dat we een stuk toevoegen met stuknr 16 , en met dezelfde bezettingsregels als stuknr 12, 
--door het uitvoeren van de volgende inserts:

--INSERT INTO Stuk VALUES (16, 10, 'Blue blue', 1,  'jazz',   'A', 4,  1998)
--INSERT INTO Bezettingsregel VALUES (16, 'piano',  '',   1)
--INSERT INTO Bezettingsregel VALUES (16, 'fluit',  '',   2)

--Dan moet de gevraagde query als resultset geven:
--stuknr                 stuknr
----------------------------------------- ----------------------
--1                    8
--1                    10
--8                    10
--12                   16

USE MASTER
GO
--See http://www.iaafbeijing2015.com/special/iaaf_sch_en/
--Source: http://loc.en.beijing2015.aws.iaaf.org/download/competition?filename=AT-200-W-f----.RS6.pdf&path=%5Cpdf%5C4875%5C&urlslug=200-metres-Official%20Results&updatedOn=08%2F28%2F2015%2013%3A03%3A32

--2.3 en 2.4
SELECT *
FROM Stuk
ORDER BY ISNULL(speelduur,(SELECT MAX(speelduur) + 1 FROM Stuk)) 

SELECT 'speelduur is :' + CAST(speelduur AS VARCHAR(10)),
		CONVERT(VARCHAR, speelduur) 
FROM Stuk

--2.5
DROP DATABASE BEIJNG2015
GO
CREATE DATABASE BEIJNG2015
GO
USE BEIJNG2015
GO
CREATE TABLE ALL_TIME_OUTDOOR_TOP_LIST(
	RESULT VARCHAR(5), 
	NAME VARCHAR(50) PRIMARY KEY)
GO
INSERT INTO ALL_TIME_OUTDOOR_TOP_LIST
VALUES	('21.34','Florence GRIFFITH-JOYNER (USA)'	),
		('21.62','Marion JONES (USA)'				),
		('21.63','Dafne SCHIPPERS (NED)'			),
		('21.64','Merlene OTTEY (JAM)'				),
		('21.66','Elaine THOMPSON (JAM)'			),
		('21.69','Allyson FELIX (USA)'				),
		('21.71','Marita KOCH (GDR)'				),
		('21.71','Heike DRECHSLER (GDR)'			),
		('21.72','Grace JACKSON (JAM)'				),
		('21.72','Gwen TORRENCE (USA)'				)

CREATE TABLE SEASON_OUTDOOR_TOP_LIST(
	RESULT VARCHAR(5), 
	NAME VARCHAR(50)  PRIMARY KEY)
GO
INSERT INTO SEASON_OUTDOOR_TOP_LIST
VALUES	('21.63','Dafne SCHIPPERS (NED)'			),
		('21.66','Elaine THOMPSON (JAM)'			),
		('21.97','Veronica CAMPBELL-BROWN (JAM)'	),
		('21.98','Allyson FELIX (USA)'				),
		('22.01','Candyce MCGRONE (USA)'			),
		('22.07','Dina ASHER-SMITH (GBR)'			),
		('22.14','Shaunae MILLER (BAH)'				),
		('22.18','Dezerea BRYANT (USA)'				),
		('22.20','Jenna PRANDINI (USA)'				),
		('22.23','Tori BOWIE (USA)'					),
		('22.23','Jeneba TARMOH (USA)'				)

--A. Geef een lijst met alle bekende hardloopsters.
--A UNION B ?
SELECT NAME FROM ALL_TIME_OUTDOOR_TOP_LIST
UNION ALL
SELECT NAME FROM SEASON_OUTDOOR_TOP_LIST

--B. Welke hardloopsters staan in de ALL-TIME highscore maar hebben die tijd niet dit seizoen gelopen?
--A EXCEPT B ?
SELECT NAME, RESULT FROM ALL_TIME_OUTDOOR_TOP_LIST
EXCEPT
SELECT NAME, RESULT FROM SEASON_OUTDOOR_TOP_LIST

--C. Welke hardloopsters hebben dit seizoen een tijd gelopen waardoor ze in de 
--ALL-TIME highscore lijst zijn gekomen? 
--(veronderstel dat ze deze tijd maar 1 keer hebben gelopen).
--A INTERSECT B ?
SELECT NAME, RESULT FROM ALL_TIME_OUTDOOR_TOP_LIST
INTERSECT
SELECT NAME, RESULT FROM SEASON_OUTDOOR_TOP_LIST

--D. Welke hardloopsters staan maar in 1 van beide lijsten?
--A DIFFERENCE B ?
--is (A EXCEPT B) UNION (B EXCEPT A) >>Let op prioriteit!!
--is (A UNION B) EXCEPT (A INTERSECT B) >>Let op prioriteit!!

(SELECT NAME FROM SEASON_OUTDOOR_TOP_LIST
EXCEPT
SELECT NAME FROM ALL_TIME_OUTDOOR_TOP_LIST)
UNION
(SELECT NAME FROM ALL_TIME_OUTDOOR_TOP_LIST
EXCEPT
SELECT NAME FROM SEASON_OUTDOOR_TOP_LIST)

--of

(SELECT NAME FROM SEASON_OUTDOOR_TOP_LIST
UNION
SELECT NAME FROM ALL_TIME_OUTDOOR_TOP_LIST)
EXCEPT
(SELECT NAME FROM ALL_TIME_OUTDOOR_TOP_LIST
INTERSECT
SELECT NAME FROM SEASON_OUTDOOR_TOP_LIST)


--ook leuk met dit soort lijstjes...
--geef de top 3 snelste uit de ALL_TIME_OUTDOOR_TOP_LIST

SELECT * 
FROM ( 
	SELECT NAME, RESULT, 
		   RANK() OVER						--Rank() is een 'window' function
			 (ORDER BY RESULT ASC) AS RANKING_NR
	FROM ALL_TIME_OUTDOOR_TOP_LIST ) A
WHERE A.RANKING_NR <= 3


SELECT TOP 7 NAME, RESULT
FROM ALL_TIME_OUTDOOR_TOP_LIST
ORDER BY RESULT ASC

SELECT TOP 7 WITH TIES NAME, RESULT
FROM ALL_TIME_OUTDOOR_TOP_LIST
ORDER BY RESULT ASC

--Meer 'window' functions, bv ROW_NUMBER(), zie https://msdn.microsoft.com/en-us/library/ms189461.aspx 
SELECT NAME, RESULT, 
		ROW_NUMBER() OVER 
			(ORDER BY RESULT ASC) AS ROWNR
FROM ALL_TIME_OUTDOOR_TOP_LIST


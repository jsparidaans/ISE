
/*1.1	Herhalingsopdrachten SQL
De volgende opdrachten hebben betrekking op de Muziekdatabase. Scripts om de database aan te maken kun je op Onderwijs Online vinden.
Geef een SQL SELECT statement voor elk van de onderstaande informatiebehoeften.*/


/*=======================================================================================================*/
/*1.	Geef voor elk klassiek stuk het stuknr, de titel en de naam van de componist. */
/*=======================================================================================================*/

select stuknr, c.naam, titel
from Stuk s
    inner join Componist c on c.componistId = s.componistId
where genrenaam like '%klassiek%'

/*=======================================================================================================*/
/*2.	Welke stukken zijn gecomponeerd door een muziekschooldocent? Geef van de betreffende stukken 
het stuknr, de titel, de naam van de componist en de naam van de muziekschool.*/
/*=======================================================================================================*/

select stuknr, titel, c.naam, m.naam
from Stuk s
    inner join Componist c on c.componistId = s.componistId
    inner join Muziekschool m on m.schoolId = c.schoolId
where genrenaam like '%klassiek%';

/*=======================================================================================================*/
--3.	Bij welke stukken (geef stuknr en titel) bestaat de bezetting uit ondermeer een saxofoon? 
--Opmerking: Gebruik een subquery.
/*=======================================================================================================*/

select s.stuknr, s.titel, b.instrumentnaam, b.toonhoogte
from Stuk s, Bezettingsregel b
where b.instrumentnaam like '%saxofoon%'


select s.stuknr, s.titel
from Stuk s
where s.stuknr in(
    select stuknr
from Bezettingsregel
where instrumentnaam = 'saxofoon'
)

/*=======================================================================================================*/
--4.	Bij welke stukken wordt de saxofoon niet gebruikt?
/*=======================================================================================================*/

/* WRONG:*/
select s.stuknr, s.titel
from Stuk s
where s.stuknr in(
    select stuknr
from Bezettingsregel
where instrumentnaam != 'saxofoon'
)

/* CORRECT: */

select s.stuknr, s.titel
from Stuk s
where s.stuknr not in(
    select stuknr
from Bezettingsregel
where instrumentnaam = 'saxofoon'
)

/*=======================================================================================================*/
/*5.	Bij welke jazzstukken worden twee of meer verschillende instrumenten gebruikt?*/
/*=======================================================================================================*/

select distinct s.stuknr, s.titel, s.genrenaam, b.aantal
from Stuk s
    inner join Bezettingsregel b on b.stuknr=s.stuknr
where s.genrenaam like '%jazz%' and b.aantal > 1


/*=======================================================================================================*/
/*6.	Geef het aantal originele muziekstukken per componist. Ook componisten met nul originele stukken 
dienen te worden getoond.*/
/*=======================================================================================================*/

select c.componistId, count(s.stuknr)
from Componist c
    left join Stuk s on c.componistId = s.componistId
        and s.stuknrOrigineel is null
group by c.componistId

/*=======================================================================================================*/
/*7.	Geef voor elk niveau de niveaucode, de omschrijving en het aantal klassieke speelstukken. 
Opmerking: Dus ook als er voor een niveau geen klassieke speelstukken zijn.*/
/*=======================================================================================================*/

select n.niveaucode, n.omschrijving, count(stuknr)
from Niveau n
    left join Stuk s on n.niveaucode = s.niveaucode
        and genrenaam = 'klassiek'
group by n.niveaucode, n.omschrijving

/*=======================================================================================================*/
/*8.	Geef het nummer en de naam van de muziekscholen waarvoor meer dan drie speelstukken bestaan die 
gecomponeerd zijn door docenten van de betreffende school.*/
/*=======================================================================================================*/

select m.schoolId, m.naam, count(s.stuknr)
from Componist c
    inner join Stuk s on c.componistId = s.componistId
    inner join Muziekschool m on c.schoolId = m.schoolId
group by m.schoolId, m.naam
having count(*) >3

/*=======================================================================================================*/
/*9.	Voorspel uit hoeveel rijen het resultaat van de volgende query bestaat:

	SELECT	*
	FROM	Componist, Muziekschool;
	Ga vervolgens na of je voorspelling correct is.
	Opmerking: Deze query heeft hetzelfde effect als 
	SELECT	*
	FROM	Componist CROSS JOIN Muziekschool;*/
/*=======================================================================================================*/

--24

/*=======================================================================================================*/
/*10.	Stel de tabel Componist is gedefinieerd zonder een UNIQUE-constraint op de kolom naam. 
Als je deze constraint toevoegt m.b.v. een ALTER TABLE statement, 
dan lukt dat niet als er dubbele waarden voorkomen in de kolom naam.
Geef een SELECT-statement waarmee je de rijen met een niet-unieke componistnaam kunt opsporen.*/
/*=======================================================================================================*/

select *
from Componist
where naam in(
    select naam
from Componist
group by naam
HAVING count(naam) > 1
)

/*=======================================================================================================*/
/*11.	Geef twee UPDATE-statements waarmee alle stukken van docenten van Muziekschool Sonsbeek 
op niveaucode C gezet worden, als de niveaucode not null was: 
gebruik Ms SQL Server’s multiple tables UPDATE optie beschreven in 
the SQL Bible op pagina’s 302 tm 305 en scrhijf een ANSI SQL subquery variant.  

Plaats je statements tussen een BEGIN TRANSACTION - ROLLBACK TRANSACTION statement combinatie. 
Daarmee worden wijzigingen aan de data uiteindelijk weer ongedaan gemaakt terwijl resultaten 
tijdelijk wel beschikbaar zijn voor controle op correctheid. 

BEGIN TRANSACTION 
		<jouw UPDATE/DELETE statement>
		<jouw SQL SELECT controle statement>
	          ROLLBACK TRANSACTION*/
/*=======================================================================================================*/

begin transaction

update Stuk
set niveaucode = 'C'
from Muziekschool m inner join Componist c on m.schoolId=c.schoolId
    inner join Stuk s on c.componistId=s.componistId
where m.naam='Muziekschool Sonsbeek'

update Stuk 
set niveaucode = 'C'
where stuknr in(
    select s.stuknr
from Muziekschool m
    inner join Componist c on m.schoolId=c.schoolId
    inner join Stuk s on c.componistId=s.componistId
where m.naam='Muziekschool Amsterdam'
)

rollback transaction

/*=======================================================================================================*/
/*12.	Geef twee DELETE-statements waarmee alle bezettingsregels van stukken van docenten van Muziekschool 
Sonsbeek verwijderd worden: gebruik Ms SQL Server’s multiple tables DELETE optie beschreven in 
the SQL Bible op pagina’s 310 tm 312 en scrhijf een ANSI SQL subquery variant.  

Gebruik weer onderstaande transactie statements.

BEGIN TRANSACTION 
		<jouw UPDATE/DELETE statement>
		<jouw SQL SELECT controle statement>
ROLLBACK TRANSACTION

Meer over transacties volgt in in het thema Concurrency.
*/
/*=======================================================================================================*/

begin transaction

delete 
from Bezettingsregel
where stuknr in (
    select s.stuknr
from Muziekschool m
    inner join Componist c on m.schoolId=c.schoolId
    inner join Stuk s on c.componistId=s.componistId
where m.naam='Muziekschool Sonsbeek'

)

rollback transaction 
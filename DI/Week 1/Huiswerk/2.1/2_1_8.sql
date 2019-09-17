select count(*) as Nummer, s1.stuknr, s1.titel, s1.speelduur
from stuk s1, stuk s2
where s1.speelduur >= s2.speelduur
group by s1.stuknr, s1.titel, s1.speelduur
order by s1.speelduur 

select s.stuknr, s.titel, s.speelduur, rank() over (order by speelduur asc)
from stuk s
where s.speelduur is not null
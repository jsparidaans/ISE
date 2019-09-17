select stuknr, titel, jaartal
from Stuk s
where exists(
    select *
    from Stuk s2
    where s.jaartal > s2.jaartal
    having count(s2.stuknr) < 3
    )
order by jaartal, titel asc


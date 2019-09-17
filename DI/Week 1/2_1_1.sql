select stuknr, titel
from Stuk s
where exists(
    select *
    from Bezettingsregel b 
    where instrumentnaam = 'piano'
    and b.stuknr = s.stuknr
)
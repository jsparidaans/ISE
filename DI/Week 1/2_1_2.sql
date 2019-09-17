select stuknr, titel
from Stuk s
where not exists(
    select *
from Bezettingsregel b
where b.instrumentnaam = 'piano'
and b.stuknr = s.stuknr
)
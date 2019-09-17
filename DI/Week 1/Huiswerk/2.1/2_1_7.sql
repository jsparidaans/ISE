select stuknr, titel
from stuk s
where not exists(
    select *
    from instrument i
    where not exists(
        select *
        from Bezettingsregel b
        where stuknr = s.stuknr 
        and instrumentnaam = i.instrumentnaam 
        and toonhoogte = i.toonhoogte
    )
)
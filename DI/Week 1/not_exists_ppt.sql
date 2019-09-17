select instrumentnaam, toonhoogte
from Instrument i
where not exists(
    select *
    from Bezettingsregel b
    where
        i.instrumentnaam = instrumentnaam
        and
        i.toonhoogte = toonhoogte
)
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
and not exists(
    select *
    from StudentInstrument si
    where si.instrumentnaam = i.instrumentnaam
        and si.toonhoogte = i.toonhoogte
)
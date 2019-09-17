select s1.stuknr, s2.stuknr
from stuk s1, stuk s2
where s1.stuknr < s2.stuknr
    and not exists (
        (
        select instrumentnaam, toonhoogte
        from Bezettingsregel b1
        where b1.stuknr = s1.stuknr
    UNION
        select instrumentnaam, toonhoogte
        from Bezettingsregel b1
        where b1.stuknr = s2.stuknr
    )
    except
    (
        select instrumentnaam, toonhoogte
        from Bezettingsregel b1
        where b1.stuknr = s1.stuknr
    INTERSECT
        select instrumentnaam, toonhoogte
        from Bezettingsregel b1
        where b1.stuknr = s2.stuknr
    )
)
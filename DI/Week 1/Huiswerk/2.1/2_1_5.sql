select stuknr, titel
from Stuk s
where not exists(
    select *
    from Stuk
    where s.stuknr = stuknrOrigineel
)
    and not exists(
    select *
    from Stuk
    where stuknr = s.stuknrOrigineel
)



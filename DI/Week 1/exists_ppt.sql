select componistId, naam
from componist c
where exists (
    select 1
from Stuk s
    inner join Bezettingsregel b
    on s.stuknr = b.stuknr
where
    b.instrumentnaam = 'fluit'
    and niveaucode is not null
    and componistId = c.componistId
    and exists(
    select 1
    from Stuk s
        inner join Bezettingsregel b
        on s.stuknr = b.stuknr
    where
        b.instrumentnaam = 'saxofoon'
        and niveaucode is not null
        and componistId = c.componistId
    )

)

select c.componistId, s.titel
from Componist c
    inner join Stuk s on c.componistId=s.componistId
where exists(
    select s.titel
from Stuk s
where s.componistId = c.componistId
    and exists(
        select *
    from Bezettingsregel b
    where b.stuknr = s.stuknr
        and b.instrumentnaam = 'fluit'
    )
    and exists(
        select *
    from Bezettingsregel b
    where b.stuknr = s.stuknr
        and b.instrumentnaam = 'saxofoon'
    )
)

select c.componistId, s.titel
from Componist c
    inner join Stuk s on c.componistId=s.componistId
where exists(
    select s.titel
from Stuk s
where s.componistId = c.componistId
    and exists(
        select *
    from Bezettingsregel b
    where b.stuknr = s.stuknr
        and b.instrumentnaam = 'fluit'
    )
    and not exists(
        select *
    from Bezettingsregel b
    where b.stuknr = s.stuknr
        and b.instrumentnaam = 'saxofoon'
    )
    
)
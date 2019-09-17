select componistId, naam
from Componist c
where exists(
    select *
from Stuk s
where c.componistId=s.componistId
group by s.componistId
having count(s.componistId) > 1
)
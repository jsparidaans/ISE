declare @composerName varchar(20) -- declaratie

select @composerName = naam from Componist  --initialisatie
order by naam
select @composerName                        

select naam from Componist
--1
    select i.instrumentnaam, i.toonhoogte, count(b.stuknr)
    from instrument i inner join bezettingsregel b
        on i.instrumentnaam = b.instrumentnaam
    group by i.instrumentnaam, i.toonhoogte
union
    select i.instrumentnaam, i.toonhoogte, 0
    from instrument i
    where not exists(
	select 1
    from bezettingsregel b
    where i.instrumentnaam = b.instrumentnaam
        and i.toonhoogte = b.toonhoogte
)

--2

select g.genrenaam
from Genre g
where exists(
	select *
    from stuk s
        inner join bezettingsregel b
        on s.stuknr = b.stuknr
    where g.genrenaam = s.genrenaam
        and b.instrumentnaam = 'fluit'
	
)
    and not exists(
	select *
    from stuk s
        inner join bezettingsregel b
        on s.stuknr = b.stuknr
    where g.genrenaam = s.genrenaam
        and b.instrumentnaam = 'saxofoon'
)
go

--3
alter proc sp_TitelVerplicht
    @stuknr numeric(5),
    @componistId numeric(4),
    @titel varchar(20),
    @stuknrOrigineel numeric(5),
    @genrenaam varchar(10),
    @niveaucode char(1),
    @speelduur numeric(3,1),
    @jaartal numeric(4)
as
begin
    begin try
		declare @nieuwe_titel varchar(20) = @titel
		if @stuknrOrigineel is null and @nieuwe_titel is null
			raiserror('Registreren van een nieuw origineel stuk zonder titel is niet toegestaan',16,1)
		if @stuknrOrigineel is not null and @nieuwe_titel is null
			select @nieuwe_titel = titel
    from stuk
    where stuknrOrigineel = @stuknrOrigineel
		insert into stuk
        (stuknr, componistId, titel, stuknrOrigineel,
        genrenaam, niveaucode, speelduur, jaartal)
    values(@stuknr, @componistId, @nieuwe_titel, @stuknrOrigineel,
            @genrenaam, @niveaucode, @speelduur, @jaartal)
	end try
	begin catch
		throw
	end catch
end
begin tran
exec sp_TitelVerplicht 99,99,null,1,'jazz','A',15.35,2019
rollback tran
go
--4

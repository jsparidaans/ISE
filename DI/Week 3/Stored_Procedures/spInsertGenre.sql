use MuziekdatabaseUitgebreid
go
alter proc spInsertGenre
@GenreNaam varchar(20)
as

begin 
	begin try
		declare @GenreCount int
		set @GenreCount = (select count(*) from Genre)
		if @GenreCount > 5
			raiserror('Too many genres',16,1)
		else
			insert into Genre values (@GenreNaam)
	end try
	begin catch
		;throw
	end catch

end

exec spInsertGenre @GenreNaam = 'metal'
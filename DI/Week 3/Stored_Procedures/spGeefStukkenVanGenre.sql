use MuziekdatabaseUitgebreid
go
create proc spGeefStukkenVanGenre
@StukGenre varchar(10)
as

begin
	begin try
		declare @ErrorMessage varchar(255) = 'Genre ' + @StukGenre + ' bestaat niet'
		select Stuk.titel, Stuk.genrenaam 
		from Stuk 
		where Stuk.genrenaam = @StukGenre
		if @@ROWCOUNT = 0
			raiserror(@ErrorMessage, 16,1)
	end try
	begin catch
		
		;throw
	end catch
end

exec spGeefStukkenVanGenre 'asdfghj'
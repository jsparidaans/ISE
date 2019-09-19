/*
	S_Toets 1 2019 P1 - Antwoorden Joey Sparidaans 583792
*/

/*
	Vraag 1:
	HULPCODE
*/
	USE MuziekdatabaseUitgebreid
	GO

	--Extra records in StudentInstrument tbv testen
	INSERT INTO Student (studentId, schoolId, voornaam, achternaam, inschrijfdatum, uitschrijfdatum)
	VALUES	 (101,1,'Martijn','Driessen', GETDATE(),NULL)
	INSERT INTO StudentInstrument (instrumentnaam,toonhoogte,studentId,niveaucode)
	VALUES	 --,('saxofoon', 'alt',7,'A') zit al in de tabel
			 ('saxofoon', 'tenor',7,'B')
			,('fluit', '',7,'B')
			,('saxofoon', 'alt',101,'A')
			,('saxofoon', 'tenor',101,'C')
			,('fluit', '',101,'B')

	--Huidige populatie van StudentInstrument
	SELECT *
	FROM StudentInstrument
	ORDER BY StudentID, instrumentnaam, toonhoogte

	select s.studentId, achternaam
	from Student s
	inner join StudentInstrument si
	on s.studentId = si.studentId
	
	intersect

	select si.studentId, instrumentnaam
	from StudentInstrument si
	inner join Student s
	on si.studentId = s.studentId
	
	
	



/*
	Vraag 2:
	GEEN HULPCODE
*/

	select studentId, achternaam
	from Student s
	where exists(
		select *
		from StudentInstrument si
		where s.studentId = si.studentId
		and instrumentnaam = 'saxofoon'
		and toonhoogte = 'tenor'
	)
	and exists(
		select *
		from StudentInstrument si
		where s.studentId = si.studentId
		and instrumentnaam = 'saxofoon'
		and toonhoogte = 'alt'
	)


/*
	Vraag 3:
	HULPCODE
*/
	--Heading van stored procedure
	go
	alter PROC procInsertStudentInstrumentUitvoeringStuk
		@instrumentnaam			varchar(14),
		@toonhoogte				varchar(7),
		@studentId				numeric(10),
		@stuknr					numeric(5),
		@datumtijdUitvoering	datetime
	AS
	begin
		begin try
	-- student mag alleen aan een uitvoering meedoen als hij het instrument kan bespelen 
			if (select instrumentnaam from StudentInstrument where studentId = @studentId and instrumentnaam = @instrumentnaam) is null
				raiserror('De student kan het instrument niet bespelen', 16, 1)
	-- student mag alleen aan een uitvoering meedoen als hij niet op hetzelfde moment een andere uitvoering van een ander stuk heeft 
			if (select studentId from StudentInstrumentUitvoeringStuk where datumtijdUitvoering = @datumtijdUitvoering and studentId = @studentId and stuknr != @stuknr) is not null
				raiserror('De student speelt op hetzelfde moment in een ander stuk', 16, 1)

			insert into StudentInstrumentUitvoeringStuk(instrumentnaam,toonhoogte,studentId,stuknr,datumtijdUitvoering)
			values(@instrumentnaam,@toonhoogte,@studentId,@stuknr,@datumtijdUitvoering)
		end try
		begin catch
			;throw
		end catch
	end

	--Hulpcode voor te testen
	-- mag niet slagen, want student bespeelt het instrument niet
	begin tran
	EXEC procInsertStudentInstrumentUitvoeringStuk
			@instrumentnaam = 'saxofoon',
			@toonhoogte	= 'alt',
			@studentId = 3,
			@stuknr	= 15,
			@datumTijdUitvoering = '2016-01-01'
	rollback tran

	-- hulpcode voor test hieronder
	INSERT INTO UitvoeringStuk(stuknr, datumtijdUitvoering) VALUES (15, '2014-12-24')

	-- mag niet slagen, want student bespeelt als een ander stuk op dit moment
	begin tran
	EXEC procInsertStudentInstrumentUitvoeringStuk
			@instrumentnaam = 'saxofoon',
			@toonhoogte	= 'tenor',
			@studentId = 10,
			@stuknr	= 15,
			@datumTijdUitvoering = '2014-12-24'
	rollback tran
		
/*
	Vraag 4:
	HULPCODE
*/
	--Heading van stored procedure
	go
	alter PROC procInsertComponist 
  		@componistId NUMERIC(4,0), 
		@naam VARCHAR(20), 
		@geboortedatum DATETIME, 
		@schoolId NUMERIC(2,0)
	AS
	begin
		begin try
			--er mogen maximaal 2 componisten werkzaam zijn voor dezelfde muziekschool 
			--hoeveel componisten heeft een muziekschool?
			if (select count(componistId) from Componist where schoolId = @schoolId) = 2
				raiserror('De muziekschool heeft reeds twee componisten', 16, 1)

			insert into Componist(componistId, naam, geboortedatum, schoolId)
			values(@componistId, @naam, @geboortedatum, @schoolId)

		end try
		begin catch
			;throw
		end catch

	end


	--mag niet slagen, deze muziekschool heeft reeds twee componisten
	begin tran
	EXEC procInsertComponist 
  		@componistId = 11, 
		@naam = 'John Adams', 
		@geboortedatum = '1947-02-15', 
		@schoolId = 1
	rollback tran

	--mag wel slagen, deze muziekschool heeft nog geen componisten
	begin tran
	EXEC procInsertComponist 
  		@componistId = 11, 
		@naam = 'John Adams', 
		@geboortedatum = '1947-02-15', 
		@schoolId = 3
	rollback tran

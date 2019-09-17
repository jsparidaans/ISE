declare @banknummer INT 
set @banknummer = 153537485

declare @curNum INT


declare @curMultiplier int
set @curMultiplier = 9

declare @done BIT
set @done = 0



while(@done != 1)
    BEGIN
        if @banknummer != 0
        BEGIN
            set @curNum = @nummer % 10
            
        END

        ELSE
        BEGIN
            RAISERROR ('That is not a banknumber', 16, 1, @banknummer)
            set @done = 1
        END

    end

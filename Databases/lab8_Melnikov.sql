--ЛАБА 8
USE lab_6
GO

--Создать хранимую процедуру, производящую выборку
--из некоторой таблицы и возвращающую результат
--выборки в виде курсора.
DROP PROCEDURE IF EXISTS selection_player1
GO
CREATE PROCEDURE dbo.selection_player1 @currently_cursor CURSOR VARYING OUTPUT AS
    SET @currently_cursor = CURSOR
    FORWARD_ONLY STATIC FOR
    SELECT surname, country FROM Player
    OPEN @currently_cursor
    -- fetch next

GO
DECLARE @temp_cursor CURSOR
EXECUTE dbo.selection_player1 @currently_cursor = @temp_cursor OUTPUT

FETCH NEXT FROM @temp_cursor
WHILE (@@FETCH_STATUS = 0)
BEGIN
	FETCH NEXT FROM @temp_cursor
END
CLOSE @temp_cursor
DEALLOCATE @temp_cursor
GO
--Модифицировать хранимую процедуру п.1. таким
--образом, чтобы выборка осуществлялась с
--формированием столбца, значение которого
--формируется пользовательской функцией.

DROP FUNCTION IF EXISTS rebrend_position

GO

CREATE FUNCTION rebrend_position(@position NVARCHAR(50))
	RETURNS NVARCHAR(50)
	AS
		BEGIN
            RETURN (CASE
                WHEN @position = 'forward' THEN 'striker'
                ELSE 'halfback'
            END
        );
		END
GO
DROP PROCEDURE IF EXISTS dbo.selection_player2
GO
CREATE PROCEDURE dbo.selection_player2  @cur_cursor CURSOR VARYING OUTPUT AS
    SET @cur_cursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT surname, country, dbo.rebrend_position(position) as rebranded_position
    FROM Player
    OPEN @cur_cursor
GO
DECLARE @temp_cursor1 CURSOR
EXECUTE dbo.selection_player2 @cur_cursor=@temp_cursor1 OUTPUT
FETCH NEXT FROM @temp_cursor1
WHILE (@@FETCH_STATUS = 0)
	BEGIN
		FETCH NEXT FROM @temp_cursor1
	END

CLOSE @temp_cursor1
DEALLOCATE @temp_cursor1
GO
--Создать хранимую процедуру, вызывающую процедуру
--п.1., осуществляющую прокрутку возвращаемого
--курсора и выводящую сообщения, сформированные из
--записей при выполнении условия, заданного еще одной
--пользовательской функцией.

DROP FUNCTION IF EXISTS check_country

GO
CREATE FUNCTION check_country(@country VARCHAR(2))
    RETURNS BIT
    AS
        BEGIN
            RETURN (CASE
                WHEN @country='EG' THEN 1
                ELSE 0
            END
        );
        END

GO
DROP PROCEDURE IF EXISTS dbo.improved_selection_player1
GO

CREATE PROCEDURE dbo.improved_selection_player1 AS
    DECLARE @j CURSOR
    DECLARE @surname NVARCHAR(50)
    DECLARE @country VARCHAR(2)

    EXECUTE dbo.selection_player1 @currently_cursor = @j OUTPUT

    FETCH NEXT FROM @j INTO @surname, @country

    WHILE (@@FETCH_STATUS=0)
    BEGIN
        IF (dbo.check_country(@country)>0)
            PRINT @surname + ' EG'
        ELSE
            PRINT @surname + ' NOT EG'
        FETCH NEXT FROM @j INTO @surname, @country
    END

    CLOSE @j
    DEALLOCATE @j
GO

EXECUTE dbo.improved_selection_player1

GO
--Модифицировать хранимую процедуру п.2. таким
--образом, чтобы выборка формировалась с помощью
--табличной функции.
DROP FUNCTION IF EXISTS dbo.table_function
GO
-- CREATE FUNCTION table_function()
-- RETURNS @result TABLE (
--     surname NVARCHAR(50) NOT NULL,
--     country VARCHAR(2) NOT NULL,
--     rebranded_position NVARCHAR(50) NOT NULL
-- )
-- AS
--     BEGIN
--         INSERT @result
--         SELECT surname, country, dbo.rebrend_position(position) as rebranded_position
--         FROM Player
--         WHERE dbo.check_country(country)=1
--         RETURN
--     END
-- GO

CREATE FUNCTION table_function()
RETURNS TABLE AS RETURN(
    SELECT surname, country, dbo.rebrend_position(position) as rebranded_position
        FROM Player
        WHERE dbo.check_country(country)=1
)
GO

ALTER PROCEDURE dbo.selection_player2 @cursor CURSOR VARYING OUTPUT
AS
    SET @cursor = CURSOR
	FORWARD_ONLY STATIC FOR
	SELECT * FROM dbo.table_function()
	OPEN @cursor
GO

DECLARE @table_cursor CURSOR
EXECUTE dbo.selection_player2 @cursor = @table_cursor OUTPUT

DECLARE @surname NVARCHAR(50)
DECLARE @country VARCHAR(2)
DECLARE @rebranded_position NVARCHAR(50)

FETCH NEXT FROM @table_cursor INTO @surname, @country, @rebranded_position

WHILE (@@FETCH_STATUS = 0)
	BEGIN
		FETCH NEXT FROM @table_cursor INTO @surname, @country, @rebranded_position
        PRINT @surname + ' ' + @country + ' ' + @rebranded_position
	END
CLOSE @table_cursor
DEALLOCATE @table_cursor
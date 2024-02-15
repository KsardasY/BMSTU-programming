--ЛАБА 14
-- Создать в базах данных пункта 1 задания 13 таблицы, содержащие вертикально фрагментированные данные.

USE [first]
GO

DROP TABLE IF EXISTS Player;
GO

CREATE TABLE Player(
    id INT PRIMARY KEY NOT NULL,
	name NVARCHAR(50) NOT NULL CHECK (LEN(name) > 1),
	surname NVARCHAR(50) NOT NULL CHECK (LEN(surname) > 1),
)
GO

USE [second]
GO

DROP TABLE IF EXISTS Player;
GO

CREATE TABLE Player (
	id INT PRIMARY KEY NOT NULL,
	country VARCHAR(2) NOT NULL CHECK (country = UPPER(country)),
	position NVARCHAR(50) NOT NULL CHECK (LEN(position) > 1),
	injury BIT NOT NULL DEFAULT 0
);
GO

-- Создать необходимые элементы базы данных (представления, триггеры), обеспечивающие работу с данными вертикально фрагментированных таблиц (выборку, вставку, изменение, удаление).

DROP VIEW IF EXISTS PlayerSectionView
GO

CREATE VIEW PlayerSectionView AS
	SELECT first.id, first.name, first.surname, second.country, second.position, second.injury
	FROM first.dbo.Player first, second.dbo.Player second
	WHERE first.id = second.id
GO

DROP TRIGGER IF EXISTS PlayerViewOnInsert
DROP TRIGGER IF EXISTS PlayerViewOnUpdate
DROP TRIGGER IF EXISTS PlayerViewOnDelete
GO

CREATE TRIGGER PlayerViewOnInsert ON PlayerSectionView
INSTEAD OF INSERT
AS
	INSERT INTO first.dbo.Player(id, name, surname)
		SELECT inserted.id, inserted.name, inserted.surname
		FROM inserted
	INSERT INTO second.dbo.Player(id, country, position, injury)
		SELECT inserted.id, inserted.country, inserted.position, inserted.injury
		FROM inserted
GO

INSERT INTO PlayerSectionView(id, name, surname, country, position, injury) VALUES
(1, 'Mohamed',' Salah','EG','forward', 0),
(2, 'Darwin',' Nunez','PT','forward', 0),
(10, 'Jack', 'Grealish', 'EN', 'midfielder', 0)
GO

SELECT * from PlayerSectionView


-- INSERT INTO PlayerSectionView(name, surname, country, position, injury) VALUES
-- ('Jack', 'Messi', 'eN', 'm', 0)

-- INSERT INTO PlayerSectionView(name, surname, country, position, injury) VALUES
-- ('Mohamed',' Saleh','EG','forward', 0)

-- SELECT * from PlayerSectionView
-- GO

SELECT * FROM first.dbo.Player
SELECT * FROM second.dbo.Player

GO

CREATE TRIGGER PlayerViewOnUpdate ON PlayerSectionView
INSTEAD OF UPDATE
AS
	IF UPDATE(id)
			RAISERROR('[UPDATE ERROR]: YOU CANNOT TO CHANGE id', 16, 1)
	ELSE
		BEGIN
			UPDATE first.dbo.Player
				SET name = inserted.name, surname = inserted.surname
					FROM inserted, first.dbo.Player AS first
					WHERE first.id = inserted.id
			UPDATE second.dbo.Player
				SET country = inserted.country, position = inserted.position, injury = inserted.injury
					FROM inserted, second.dbo.Player AS second
					WHERE second.id = inserted.id
		END
GO

UPDATE PlayerSectionView SET position = 'striker' WHERE id = 2;

SELECT * FROM first.dbo.Player
SELECT * FROM second.dbo.Player
GO

CREATE TRIGGER PlayerViewOnDelete ON PlayerSectionView
INSTEAD OF DELETE
AS
	DELETE first FROM first.dbo.Player AS first
		INNER JOIN deleted AS del ON
		first.id = del.id
	DELETE second FROM second.dbo.Player AS second
		INNER JOIN deleted AS del ON
		second.id = del.id
GO

-- UPDATE PlayerSectionView SET position = 'halfback', id = 3 WHERE position = 'midfielder'

SELECT * FROM first.dbo.Player
SELECT * FROM second.dbo.Player
GO
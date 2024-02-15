-- Создать две базы данных на одном экземпляре СУБД SQL Server
USE master;
GO

ALTER DATABASE first
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE
DROP DATABASE first
GO

ALTER DATABASE second
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE
DROP DATABASE second;
GO

CREATE DATABASE first
GO

CREATE DATABASE second
GO

-- Создать в базах данных п.1. горизонтально фрагментированные таблицы.
USE first
GO

DROP TABLE IF EXISTS Player;
GO

CREATE TABLE Player(
	id INT CHECK (id <= 5) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL,
	surname NVARCHAR(50) NOT NULL,
	country VARCHAR(2) NOT NULL,
	position NVARCHAR(50) NOT NULL,
	injury BIT NOT NULL
)
GO

USE second
GO

DROP TABLE IF EXISTS Player;
GO

CREATE TABLE Player(
	id INT CHECK (id > 5) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL,
	surname NVARCHAR(50) NOT NULL,
	country VARCHAR(2) NOT NULL,
	position NVARCHAR(50) NOT NULL,
	injury BIT NOT NULL
)
GO

-- Создать секционированные представления, обеспечивающие работу с данными таблиц (выборку, вставку, изменение, удаление).

DROP VIEW IF EXISTS PlayerSectionView
GO

CREATE VIEW PlayerSectionView AS
	SELECT * FROM first.dbo.Player
	UNION ALL
	SELECT * FROM second.dbo.Player
GO

INSERT INTO PlayerSectionView (id, name, surname, country, position, injury) VALUES
(1, 'Mohamed',' Salah','EG','forward', 0),
(2, 'Darwin',' Nunez','PT','forward', 0),
(10, 'Jack', 'Grealish', 'EN', 'midfielder', 0)
GO

SELECT * FROM PlayerSectionView
SELECT * FROM first.dbo.Player
SELECT * FROM second.dbo.Player

UPDATE PlayerSectionView SET [position] =  'striker' WHERE [position] = 'forward'
GO

DELETE PlayerSectionView WHERE position = 'striker'

SELECT * FROM first.dbo.Player
SELECT * FROM second.dbo.Player

UPDATE PlayerSectionView SET id = 1 WHERE id = 10

SELECT * FROM first.dbo.Player
SELECT * FROM second.dbo.Player
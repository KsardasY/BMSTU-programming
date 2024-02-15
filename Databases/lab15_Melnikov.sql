--ЛАБА 15
USE [first]
GO

DROP TABLE IF EXISTS Team
GO

CREATE TABLE Team(
    id INT PRIMARY KEY NOT NULL,
    title NVARCHAR(100) NOT NULL CHECK (LEN(title) > 0),
    country VARCHAR(2) NOT NULL CHECK (country = UPPER(country)),
    location NVARCHAR(200) NOT NULL CHECK (LEN(location) > 0),
    president NVARCHAR(100) NOT NULL CHECK (LEN(president) > 0)
)
GO



use [second]
GO
DROP TABLE IF EXISTS Player
CREATE TABLE Player(
    id INT PRIMARY KEY NOT NULL,
	name NVARCHAR(50) NOT NULL CHECK (LEN(name) > 0),
	surname NVARCHAR(50) NOT NULL CHECK (LEN(surname) > 0),
	country VARCHAR(2) NOT NULL CHECK (country = UPPER(country)),
	position NVARCHAR(50) NOT NULL CHECK (LEN(position) > 1),
    team_id INT NOT NULL,
	injury BIT NOT NULL DEFAULT 0
);
GO

DROP VIEW IF EXISTS PlayerTeamView
GO

CREATE VIEW PlayerTeamView AS
	SELECT first.id AS player_id, first.name, first.surname, first.country, first.position, second.id AS team_id, second.title, second.president
	FROM second.dbo.Player first, first.dbo.Team second
	WHERE first.team_id = second.id
GO

USE [first]
GO

DROP TRIGGER IF EXISTS TeamOnUpdate
DROP TRIGGER IF EXISTS TeamOnDelete
GO

CREATE TRIGGER TeamOnUpdate ON Team
FOR UPDATE
AS
	IF UPDATE(id)
		BEGIN
			RAISERROR('Cannot to update id', 16, 1)
			ROLLBACK
		END
GO

CREATE TRIGGER TeamOnDelete ON Team
FOR DELETE
AS
	DELETE p FROM second.dbo.Player AS p
		JOIN deleted AS d ON
		p.team_id = d.id
GO

USE [second]

DROP TRIGGER IF EXISTS PlayerOnInsert
DROP TRIGGER IF EXISTS PlayerOnUpdate
GO

CREATE TRIGGER PlayerOnInsert ON Player
FOR INSERT
AS
	IF EXISTS (SELECT team_id FROM inserted WHERE team_id NOT IN (SELECT id FROM first.dbo.Team))
				BEGIN
					RAISERROR('Team does not exist', 16, 1)
					ROLLBACK
				END

	ELSE
		PRINT('Team insertion accepted')
GO

CREATE TRIGGER PlayerOnUpdate ON Player
FOR UPDATE
AS
	IF UPDATE(id)
		BEGIN
			RAISERROR('Cannot to update id', 16, 1)
			ROLLBACK
		END
	IF UPDATE(team_id) AND NOT EXISTS (
			SELECT t.id
			FROM first.dbo.Team as t RIGHT JOIN inserted
			ON t.id = inserted.id
			WHERE t.id IS NULL
			)
		BEGIN
			RAISERROR('Team does not exists or cannot to update team_id', 16, 1)
			ROLLBACK
		END
GO

INSERT INTO first.dbo.Team(id, title, country, location, president) VALUES
(1, 'Liverpool', 'EN', 'Merseyside', 'Tom Werner'),
(2, 'Manchester City', 'EN', 'Manchester', 'Mansour bin Zayed Al Nahyan'),
(3, 'Real Madrid', 'ES', 'Madrid', 'Florentino Perez'),
(4, 'Barcelona', 'ES', 'Barcelona', 'Joan Laporta')
GO

INSERT INTO Player(id, name, surname, country, position, team_id) VALUES
(1, 'Mohamed', 'Salah', 'EG', 'forward', 1),
(2, 'Darwin', 'Nunez', 'PT', 'forward', 1),
(3, 'Jack', 'Grealish', 'EN', 'midfield', 2),
(4, 'Jude', 'Bellingham', 'EN', 'midfield', 3),
(5, 'Virgil', 'Van Dijk', 'NL', 'back', 1),
(6, 'Ederson', 'Moraes', 'BR', 'goalkeeper', 2),
(7, 'Erling', 'Haaland', 'NO', 'forward', 2)

SELECT * FROM PlayerTeamView ORDER BY surname
GO

UPDATE first.dbo.Team SET president = 'Melnikov Andrei' WHERE id = 5;
UPDATE Player SET team_id = 1 WHERE id = 4;

SELECT * FROM PlayerTeamView ORDER BY surname
GO

DELETE FROM first.dbo.Team WHERE id = 2

SELECT * FROM PlayerTeamView ORDER BY surname
GO
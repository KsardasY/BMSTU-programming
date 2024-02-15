--ЛАБА 11
USE master;
GO

ALTER DATABASE lab_11
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
DROP DATABASE lab_11
GO

CREATE DATABASE lab_11
ON
(
	NAME = lab_11,
	FILENAME = '/var/opt/mssql/lab_11/lab_11.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5%
)
LOG ON
(
	NAME = lab_11_Log,
	FILENAME = '/var/opt/mssql/lab_11/lab_11_log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5%
)
GO

USE lab_11
GO

DROP FUNCTION IF EXISTS dbo.check_position;
GO

CREATE FUNCTION dbo.check_position (@position NVARCHAR(50))
RETURNS BIT AS
BEGIN
    IF @position = 'forward' OR @position = 'midfield' OR @position = 'goalkeeper' OR @position = 'back'
		RETURN 1
	RETURN 0
END;
GO

DROP FUNCTION IF EXISTS dbo.check_country;
GO

CREATE FUNCTION dbo.check_country (@country VARCHAR(2))
RETURNS BIT AS
BEGIN
    IF LEN(@country) = 2 AND @country = UPPER(@country)
		RETURN 1
	RETURN 0
END;
GO

DROP TABLE IF EXISTS Tournament;
DROP TABLE IF EXISTS Match;
DROP TABLE IF EXISTS Team;
DROP TABLE IF EXISTS Coach;
DROP TABLE IF EXISTS Player;
DROP TABLE IF EXISTS Participation;
GO

CREATE TABLE Player(
    id INT IDENTITY(1, 1) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL CHECK (LEN(name) > 0),
	surname NVARCHAR(50) NOT NULL CHECK (LEN(surname) > 0),
	country VARCHAR(2) NOT NULL CHECK (dbo.check_country(country) = 1),
	position NVARCHAR(50) NOT NULL CHECK (dbo.check_position(position) = 1),
	injury BIT NOT NULL DEFAULT 0
);
GO

DROP INDEX IF EXISTS PlayerNameIndex ON Player;
GO
CREATE INDEX PlayerNameIndex
	ON Player (surname, name)
	INCLUDE (position, country)
GO

CREATE TABLE Coach(
    id INT IDENTITY(1, 1) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL CHECK (LEN(name) > 0),
	surname NVARCHAR(50) NOT NULL CHECK (LEN(surname) > 0),
	country VARCHAR(2) NOT NULL CHECK (dbo.check_country(country) = 1)
);
GO

CREATE TABLE Team(
    id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(100) NOT NULL CHECK (LEN(title) > 0),
    country VARCHAR(2) NOT NULL CHECK (dbo.check_country(country) = 1),
    location NVARCHAR(200) NOT NULL CHECK (LEN(location) > 0),
    president NVARCHAR(100) NOT NULL CHECK (LEN(president) > 0),
    coach_id INT NOT NULL
    CONSTRAINT fk_coach_id FOREIGN KEY (coach_id) REFERENCES Coach(id)
)

DROP INDEX IF EXISTS TeamTitleIndex ON Team;
GO

CREATE INDEX TeamTitleIndex
	ON Team (title, country)
	INCLUDE (president)
GO

CREATE TABLE Participation(
    team_id INT
    CONSTRAINT fk_team_id FOREIGN KEY (team_id) REFERENCES Team(id) ON UPDATE CASCADE ON DELETE CASCADE,
    --ON UPDATE NO ACTION ON DELETE SET NULL
    player_id INT
    CONSTRAINT fk_player_id FOREIGN KEY (player_id) REFERENCES Player(id) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

CREATE TABLE Tournament(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    title NVARCHAR(300) NOT NULL CHECK (LEN(title) > 0),
    country VARCHAR(2) NOT NULL CHECK (dbo.check_country(country) = 1),
    end_date SMALLDATETIME NOT NULL CHECK(end_date > GETDATE()),
    ball NVARCHAR(100) NOT NULL
)

CREATE TABLE Match(
    id INT IDENTITY(1,1) PRIMARY KEY,
    tournament_id INT
    CONSTRAINT fk_tournament_id FOREIGN KEY (tournament_id) REFERENCES Tournament(id) ON UPDATE NO ACTION ON DELETE SET NULL,
    team_1_id INT NOT NULL,
    CONSTRAINT fk_team_1_id FOREIGN KEY (team_1_id) REFERENCES Team(id) ON UPDATE NO ACTION ON DELETE NO ACTION,
    team_2_id INT
    CONSTRAINT fk_team_2_id FOREIGN KEY (team_2_id) REFERENCES Team(id) ON UPDATE NO ACTION ON DELETE NO ACTION,
    date SMALLDATETIME NOT NULL,
    result NVARCHAR(7) DEFAULT NULL,
    arbiter NVARCHAR(100) DEFAULT NULL,
    stadium NVARCHAR(200) NOT NULL
)

DROP INDEX IF EXISTS MatchDateIndex ON Team;
GO

CREATE INDEX MatchDateIndex
	ON Match (date, stadium)
	INCLUDE (result)
GO

DROP TRIGGER IF EXISTS InsertParticipation;
GO

CREATE TRIGGER InsertParticipation ON Participation
INSTEAD OF INSERT
AS
    BEGIN
        IF EXISTS (SELECT team_id FROM inserted WHERE inserted.team_id NOT IN (SELECT id FROM Team))
            BEGIN
                RAISERROR('Insert query contains unexisting team_id!', 16, 1)
                ROLLBACK
            END
        ELSE IF EXISTS (SELECT player_id FROM inserted WHERE inserted.player_id NOT IN (SELECT id FROM Player))
            BEGIN
                RAISERROR('Insert query contains unexisting player_id!', 16, 1)
                ROLLBACK
            END
        ELSE
            INSERT INTO Participation SELECT * FROM inserted
    END
GO

DROP TRIGGER IF EXISTS InsertMatch;
GO

CREATE TRIGGER InsertMatch ON Match
INSTEAD OF INSERT
AS
    BEGIN
        IF EXISTS (SELECT team_1_id FROM inserted WHERE inserted.team_1_id NOT IN (SELECT id FROM Team) OR inserted.team_2_id NOT IN (SELECT id FROM Team))
            BEGIN
                RAISERROR('Insert query contains unexisting team_id!', 16, 1)
                ROLLBACK
            END
        ELSE IF EXISTS (SELECT tournament_id FROM inserted WHERE inserted.tournament_id NOT IN (SELECT id FROM Tournament))
            BEGIN
                RAISERROR('Insert query contains unexisting tournament_id!', 16, 1)
                ROLLBACK
            END
        ELSE IF EXISTS (SELECT team_1_id FROM inserted WHERE inserted.team_1_id = inserted.team_2_id)
            BEGIN
                RAISERROR('Insert query contains identical team_ids!', 16, 1)
                ROLLBACK
            END
        ELSE
            INSERT INTO Match(tournament_id, team_1_id, team_2_id, date, result, arbiter, stadium) SELECT tournament_id, team_1_id, team_2_id, date, result, arbiter, stadium FROM inserted
    END
GO

INSERT INTO Tournament(title, country, end_date, ball) VALUES
('Champions league 2023', 'EN', '2024-06-01', 'ADIDAS Finale PRO'),
('Premier League 2023', 'EN', '2024-05-19', 'Nike Flight')

INSERT INTO Coach(name, surname, country) VALUES
('Jurgen', 'Klopp', 'DE'),
('Hosep', 'Guardiola', 'ES'),
('Carlo', 'Ancelotti', 'IT'),
('Xavi', 'Hernandez', 'ES')


INSERT INTO Team(title, country, [location], president, coach_id) VALUES
('Liverpool', 'EN', 'Merseyside', 'Tom Werner', 1),
('Manchester City', 'EN', 'Manchester', 'Mansour bin Zayed Al Nahyan', 2),
('Real Madrid', 'ES', 'Madrid', 'Florentino Perez', 3),
('Barcelona', 'ES', 'Barcelona', 'Joan Laporta', 4)

INSERT INTO Player(name, surname, country, [position], injury) VALUES
('Mohamed', 'Salah', 'EG', 'forward', 0),
('Darwin', 'Nunez', 'PT', 'forward', 0),
('Jack', 'Grealish', 'EN', 'midfield', 0),
('Jude', 'Bellingham', 'EN', 'midfield', 0),
('Virgil', 'Van Dijk', 'NL', 'back', 0),
('Ederson', 'Moraes', 'BR', 'goalkeeper', 0),
('Manuel', 'Neuer', 'DE', 'goalkeeper', 0),
('Erling', 'Haaland', 'NO', 'forward', 0),
('Lionel', 'Messi', 'AR', 'forward', 0)

INSERT INTO Participation(team_id, player_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(1, 5),
(2, 6),
(3, 8)

INSERT INTO Participation(team_id, player_id) VALUES
(3, 7)

INSERT INTO Match(tournament_id, team_1_id, team_2_id, date, result, arbiter, stadium) VALUES
(2, 2, 1, '2023-11-25', '1:1', 'Chris Kavanagh', 'Etihad stadium'),
(2, 2, 3,  '2023-05-17', '4:0', 'Shimon Marchinyak', 'Etihad stadium')

SELECT * FROM Player
SELECT * FROM Coach
SELECT * FROM Team
SELECT * FROM Tournament
SELECT * FROM Participation
SELECT * FROM Match

DELETE FROM Player WHERE name = 'Manuel'

SELECT * FROM Player
SELECT * FROM Participation

UPDATE Participation SET team_id = 2 WHERE player_id = 8
SELECT * FROM Participation;

SELECT DISTINCT position FROM Player

SELECT name, surname, country as [from] FROM Player

SELECT pl.name, pl.surname, t.title FROM Player as pl JOIN Participation as p ON pl.id = p.player_id JOIN Team as t ON t.id = p.team_id

SELECT pl.name, pl.surname, t.title FROM Player as pl LEFT JOIN Participation as p ON pl.id = p.player_id LEFT JOIN Team as t ON t.id = p.team_id

SELECT pl.name, pl.surname, t.title FROM Player as pl JOIN Participation as p ON pl.id = p.player_id RIGHT JOIN Team as t ON t.id = p.team_id

SELECT pl.name, pl.surname, t.title FROM Player as pl FULL JOIN Participation as p ON pl.id = p.player_id FULL JOIN Team as t ON t.id = p.team_id

SELECT pl.name, pl.surname, t.title
FROM Player as pl LEFT JOIN Participation as p ON pl.id = p.player_id LEFT JOIN Team as t ON t.id = p.team_id
WHERE t.title IS NULL

SELECT pl.name, pl.surname, t.title
FROM Player as pl LEFT JOIN Participation as p ON pl.id = p.player_id LEFT JOIN Team as t ON t.id = p.team_id
WHERE t.title IS NOT NULL

SELECT * FROM Player WHERE surname LIKE 'M%' ORDER BY surname, name DESC

SELECT * FROM Match WHERE date BETWEEN '2023-11-01' AND '2023-11-30'

SELECT * FROM Player WHERE name IN ('Darwin', 'Virgil', 'Andrei')

SELECT * FROM Team ORDER BY president
SELECT * FROM Team ORDER BY president ASC
SELECT * FROM Team ORDER BY president DESC
GO

CREATE VIEW player_team AS
SELECT pl.id as id, pl.name AS name, pl.surname AS surname, t.title AS team
FROM Player AS pl JOIN Participation AS p ON pl.id = p.player_id JOIN Team AS t ON t.id = p.team_id

GO
SELECT team, COUNT(*) AS count FROM player_team GROUP BY team
SELECT team, COUNT(*) AS count FROM player_team WHERE name LIKE 'J%' GROUP BY team

SELECT team, AVG(id) AS avg FROM player_team GROUP BY team
SELECT team, AVG(id) AS avg FROM player_team GROUP BY team HAVING AVG(id) > 3

SELECT team, MIN(id) AS min FROM player_team GROUP BY team
SELECT team, MIN(id) AS min FROM player_team GROUP BY team HAVING AVG(id) > 3

SELECT team, MAX(id) AS max FROM player_team GROUP BY team
SELECT team, MAX(id) AS max FROM player_team GROUP BY team HAVING AVG(id) > 3

SELECT title FROM Team WHERE country = 'ES'
UNION
SELECT title FROM Team WHERE coach_id = 3
ORDER BY title DESC
GO

SELECT title FROM Team WHERE country = 'ES'
UNION ALL
SELECT title FROM Team WHERE coach_id = 3
ORDER BY title DESC
GO

SELECT title FROM Team WHERE country = 'ES'
EXCEPT
SELECT title FROM Team WHERE coach_id = 3
ORDER BY title DESC
GO

SELECT name, surname FROM player_team WHERE team = 'Manchester City'
INTERSECT
SELECT name, surname FROM Player WHERE country = 'EN'
ORDER BY name, surname
GO

SELECT * FROM Player WHERE id > (SELECT id FROM Player WHERE name = 'Virgil')
USE [lab_6];

--1.Создать представление на основе одной из таблиц задания 6.
IF OBJECT_ID(N'PortugalPlayer', N'V') IS NOT NULL
	DROP VIEW PortugalPlayer;
GO

CREATE VIEW PortugalPlayer AS
	SELECT *
	FROM Player
	WHERE country = 'PT';
GO


--2.Создать представление на основе полей обеих связанных таблиц задания 6.
IF OBJECT_ID(N'LiverpoolPlayer', N'V') IS NOT NULL
	DROP VIEW LiverpoolPlayer;
GO
CREATE VIEW LiverpoolPlayer AS
	SELECT
		p.name AS name,
		p.surname AS surname,
		t.title AS club
	FROM Player p
	INNER JOIN Participation n
		ON p.id = n.player_id
    INNER JOIN Team t
        ON t.id = n.team_id AND t.title = 'Liverpool';
GO


--3.Создать индекс для одной из таблиц задания 6, включив в него дополнительные неключевые поля.
IF EXISTS (SELECT NAME FROM sys.indexes
			WHERE name = N'PositionPlayer')
	DROP INDEX PositionPlayer ON Player;
GO


CREATE INDEX PositionPlayer
	ON Player (country)
	INCLUDE (position);
GO
SELECT country, position FROM Player WHERE (country = 'PT')

--4.Создать индексированное представление.
IF OBJECT_ID(N'PlayerView', N'V') IS NOT NULL
	DROP VIEW PlayerView;
GO

CREATE VIEW PlayerView
	WITH SCHEMABINDING AS
	SELECT country, position
	FROM dbo.Player
	WHERE position = 'forward';
GO

IF EXISTS (SELECT NAME FROM sys.indexes
			WHERE NAME = N'PlayerView')
	DROP INDEX PlayerView ON Player;
GO
CREATE UNIQUE CLUSTERED INDEX Ind1 ON PlayerView(country, position);
CREATE UNIQUE NONCLUSTERED INDEX Ind2 ON PlayerView(country, position);
GO
--SELECT *  FROM PlayerView
GO
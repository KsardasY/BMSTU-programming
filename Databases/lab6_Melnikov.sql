USE [master];
GO
ALTER DATABASE lab_6
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
DROP DATABASE lab_6
GO

CREATE DATABASE lab_6
ON ( NAME = lab_6_pr, FILENAME = '/var/opt/mssql/lab6.mdf', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = lab_6_log, FILENAME = '/var/opt/mssql/lab6.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5% );
GO

USE [lab_6];
DROP TABLE IF EXISTS [Player]
CREATE TABLE [Player](
    id INT IDENTITY(1, 1) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL CHECK (LEN(name) > 1),
	surname NVARCHAR(50) NOT NULL CHECK (LEN(surname) > 1),
	country VARCHAR(2) NOT NULL CHECK (country = UPPER(country)),
	position NVARCHAR(50) NOT NULL CHECK (LEN(position) > 1),
	injury BIT NOT NULL DEFAULT 0
)


INSERT INTO [Player] (name, surname, country, position, injury) VALUES
('Mohamed',' Salah','EG','forward', 0)

DROP TABLE IF EXISTS [Coach]
CREATE TABLE Coach(
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT(NEWID()),
	name NVARCHAR(50) NOT NULL,
	surname NVARCHAR(50) NOT NULL,
	country VARCHAR(2) NOT NULL
)

INSERT INTO Coach(name, surname, country) VALUES
('Jurgen',' Klopp', 'DE')

DROP SEQUENCE IF EXISTS seq

CREATE SEQUENCE seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 100000000000000


DROP TABLE IF EXISTS [Team]

CREATE TABLE Team(
    id INT PRIMARY KEY NOT NULL,
    title NVARCHAR(100) NOT NULL,
    country VARCHAR(2) NOT NULL,
    location NVARCHAR(200) NOT NULL,
    president NVARCHAR(100) NOT NULL
)

INSERT INTO Team(id, title, country, location, president) VALUES
(NEXT VALUE FOR seq, 'Liverpool', 'EN', 'Merseyside', 'Tom Werner')


DROP TABLE IF EXISTS Participation
CREATE TABLE Participation(
    team_id INT
    CONSTRAINT fk_team_id FOREIGN KEY (team_id) REFERENCES Team(id)
    ON UPDATE CASCADE --каскадное изменение ссылающихся таблиц;
	--ON UPDATE NO ACTION --выдаст ошибку при удалении/изменении
	--ON UPDATE SET NULL --установка NULL для ссылающихся внешних ключей;
	--ON UPDATE SET DEFAULT --установка значений по умолчанию для ссылающихся внешних ключей;
	ON DELETE SET NULL
    --ON DELETE NO ACTION
    --ON DELETE SET DEFAULT
    --ON DELETE CASCADE
    ,
    player_id INT NOT NULL
    CONSTRAINT fk_player_id FOREIGN KEY (player_id) REFERENCES Player(id) ON UPDATE CASCADE ON DELETE CASCADE
	);

INSERT INTO Participation(team_id, player_id) VALUES
(1, 1)

SELECT * FROM Player
SELECT * FROM Coach
SELECT * FROM Team
SELECT * FROM Participation

--SELECT IDENT_CURRENT ('Employment_contract'); --(для определенной таблицы)
--SELECT @@IDENTITY; --(глобально)
--SELECT SCOPE_IDENTITY(); --(для области, в которой указан)

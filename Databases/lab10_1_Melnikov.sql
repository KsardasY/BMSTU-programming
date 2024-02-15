--ЛАБА 10 1
USE master;
GO

ALTER DATABASE lab_10
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
DROP DATABASE lab_10
GO

CREATE DATABASE lab_10
ON
(
	NAME = lab_10,
	FILENAME = '/var/opt/mssql/lab_10/lab_10.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5%
)
LOG ON
(
	NAME = lab_10_Log,
	FILENAME = '/var/opt/mssql/lab_10/lab_10_log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5%
)
GO

USE lab_10
GO

DROP TABLE IF EXISTS Player;

CREATE TABLE Player(
    id INT IDENTITY(1, 1) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL CHECK (LEN(name) > 0),
	surname NVARCHAR(50) NOT NULL CHECK (LEN(surname) > 0),
	country VARCHAR(2) NOT NULL,
	position NVARCHAR(50) NOT NULL,
	injury BIT NOT NULL DEFAULT 0
);
GO

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

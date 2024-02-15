USE [master]
GO
ALTER DATABASE lab_5
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
DROP DATABASE lab_5
GO

CREATE DATABASE lab_5
ON PRIMARY
(
	NAME = lab_5_PrimaryData,
	FILENAME = '/var/opt/mssql/lab_5/lab_5.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5%
),
(
	NAME = lab_5_SecondaryData,
	FILENAME = '/var/opt/mssql/lab_5/lab_5.ndf'
)
LOG ON
(
	NAME = lab_5_Log,
	FILENAME = '/var/opt/mssql/lab_5/lab_5_log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5%
)
GO

USE lab_5
GO

CREATE TABLE Player(
	id INT NOT NULL,
	name NVARCHAR(50) NOT NULL,
	surname NVARCHAR(50) NOT NULL,
	country VARCHAR(2) NOT NULL,
	position NVARCHAR(50) NOT NULL,
	injury BIT NOT NULL
)
GO

ALTER DATABASE lab_5
ADD FILEGROUP lab_5_group;
GO

ALTER DATABASE lab_5
ADD FILE(
    NAME = lab_5_2,
    FILENAME = '/var/opt/mssql/lab_5_group.ndf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5%
)
TO FILEGROUP lab_5_group
GO

ALTER DATABASE lab_5
  MODIFY FILEGROUP lab_5_group DEFAULT;
GO

CREATE TABLE Coach(
    id INT NOT NULL,
	name NVARCHAR(50) NOT NULL,
	surname NVARCHAR(50) NOT NULL,
	country VARCHAR(2) NOT NULL
)
GO

DROP TABLE Coach;
GO

ALTER DATABASE lab_5
  MODIFY FILEGROUP [primary] DEFAULT;
GO

ALTER DATABASE lab_5
REMOVE FILE lab_5_2;
GO

ALTER DATABASE lab_5
REMOVE FILEGROUP lab_5_group;
GO

CREATE SCHEMA Schema1;
GO

ALTER SCHEMA Schema1 TRANSFER dbo.Player;
GO

DROP TABLE Schema1.Player;
GO

DROP SCHEMA Schema1;
GO
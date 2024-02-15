--ЛАБА 10 3

USE lab_10;
GO

--dirty read
-- BEGIN TRANSACTION
-- GO
--     SELECT name, surname, country FROM Player
--     UPDATE Player SET country = 'ES' WHERE surname = 'Messi'
--     ROLLBACK
-- GO

-- nonrepeatable read
-- BEGIN TRANSACTION
--     UPDATE Player SET country = 'ES' WHERE surname = 'Messi'
--     COMMIT TRANSACTION
-- GO


-- phantom read
BEGIN TRANSACTION
    SELECT name, surname FROM Player
    INSERT INTO Player VALUES
    ('Alisson', 'Becker', 'BR', 'goalkeeper', 0)
    SELECT name, surname FROM Player
    COMMIT TRANSACTION
GO
--ЛАБА 10 2

USE lab_10;
GO
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

-- BEGIN TRANSACTION
--     SELECT name, surname, country FROM Player
--     SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
-- COMMIT TRANSACTION
-- GO

BEGIN TRANSACTION
    SELECT name, surname, country FROM Player
    WAITFOR DELAY '00:00:05'
    SELECT name, surname, country FROM Player
    SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
COMMIT TRANSACTION
GO
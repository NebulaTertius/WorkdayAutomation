CREATE PROCEDURE AI.ClearHistorySystemBatches
AS

BEGIN TRY 
BEGIN TRANSACTION

DECLARE @FirstDayOfCurrentMonth datetime
SET @FirstDayOfCurrentMonth = (CAST(CAST(YEAR(GETDATE()) as varchar) + '/' + RIGHT('00' + CAST(MONTH(GETDATE()) as varchar),2) + '/' + '01' as datetime))

--Take On Batches
DELETE FROM TakeOn.EmployeeTakeOnRecordChild WHERE EmployeeTakeOnRecordID IN (SELECT EmployeeTakeOnRecordID FROM TakeOn.EmployeeTakeOnRecord WHERE EmployeeTakeOnInstanceID IN (SELECT EmployeeTakeOnInstanceID FROM TakeOn.EmployeeTakeOnInstance WHERE ISNULL(DateProcessed,GETDATE()) < @FirstDayOfCurrentMonth))
DELETE FROM TakeOn.EmployeeTakeOnRecord WHERE EmployeeTakeOnInstanceID IN (SELECT EmployeeTakeOnInstanceID FROM TakeOn.EmployeeTakeOnInstance WHERE ISNULL(DateProcessed,GETDATE()) < @FirstDayOfCurrentMonth)
DELETE FROM TakeOn.EmployeeLeaveTakeOn WHERE EmployeeTakeOnInstanceID IN (SELECT EmployeeTakeOnInstanceID FROM TakeOn.EmployeeTakeOnInstance WHERE ISNULL(DateProcessed,GETDATE()) < @FirstDayOfCurrentMonth)
DELETE FROM TakeOn.EmployeeTakeOnInstance WHERE ISNULL(DateProcessed,GETDATE()) < @FirstDayOfCurrentMonth


--Instance Batches
DELETE FROM Batch.BatchEmployeeField WHERE BatchEmployeeID IN (SELECT BatchEmployeeID FROM Batch.BatchEmployee WHERE BatchInstanceID IN (SELECT BatchInstanceID FROM Batch.BatchInstance WHERE ISNULL(DateProcessed,GETDATE()) < @FirstDayOfCurrentMonth))
DELETE FROM Batch.BatchEmployee WHERE BatchInstanceID IN (SELECT BatchInstanceID FROM Batch.BatchInstance WHERE ISNULL(DateProcessed,GETDATE()) < @FirstDayOfCurrentMonth)
DELETE FROM Batch.BatchInstance WHERE ISNULL(DateProcessed,GETDATE()) < @FirstDayOfCurrentMonth

IF ((SELECT XACT_STATE()) = 1) COMMIT TRANSACTION 
END TRY 
BEGIN CATCH IF ((SELECT XACT_STATE()) = -1) ROLLBACK TRANSACTION END CATCH
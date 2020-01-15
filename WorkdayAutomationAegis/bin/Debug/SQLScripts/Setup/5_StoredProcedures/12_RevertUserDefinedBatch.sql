CREATE PROCEDURE AI.RevertUserDefinedBatch @BatchInstanceID int
AS

BEGIN TRY BEGIN TRANSACTION
INSERT INTO Batch.BatchInstance 
(Code,ShortDescription,LongDescription,Comment,CompanyRule,PayRunDef,ProcessPeriod,BatchTemplateID,BatchInstanceType,ExportOption,DisplayCodes,DisplayCodesOption,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies
,ExcludeFromScheduler,ProcessingStatus,DateCaptured,CapturedBy,LastChanged,UserID
)
SELECT 'UNDO_' + LEFT(Code,3) + '_' + RIGHT(CONVERT(varchar,@BatchInstanceID),6) [Code]
	,LEFT('Undo ' + ShortDescription,35)
	,LEFT('Undo ' + LongDescription,100)
	,Comment,CompanyRule,PayRunDef,ProcessPeriod,BatchTemplateID,BatchInstanceType,ExportOption,DisplayCodes,DisplayCodesOption,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies
,ExcludeFromScheduler,'V' [ProcessingStatus],GETDATE() DateCaptured,CapturedBy,GETDATE() LastChanged,UserID 
FROM Batch.BatchInstance WHERE BatchInstanceID = @BatchInstanceID
IF ((SELECT XACT_STATE()) = 1) COMMIT TRANSACTION END TRY 
BEGIN CATCH IF ((SELECT XACT_STATE()) = -1) ROLLBACK TRANSACTION END CATCH



BEGIN TRY BEGIN TRANSACTION
		INSERT INTO Batch.BatchInstanceFilter (BatchInstanceID,CompanyRuleID,PayslipTypeID,TaxYearID,ProcessPeriodID,PayRunDefID,LastChanged,UserID)
		SELECT (SELECT MAX(BatchInstanceID) FROM Batch.BatchInstance) AS BatchInstanceID
			,CompanyRuleID
			,0
			,NULL
			,ProcessPeriodID
			,PayRunDefID
			,GETDATE()
			,UserID
		FROM Batch.BatchInstanceFilter
		WHERE BatchInstanceID = @BatchInstanceID
IF ((SELECT XACT_STATE()) = 1) COMMIT TRANSACTION END TRY 
BEGIN CATCH IF ((SELECT XACT_STATE()) = -1) ROLLBACK TRANSACTION END CATCH

		
		
BEGIN TRY BEGIN TRANSACTION
		INSERT INTO Batch.BatchEmployee (BatchInstanceID,EmployeeCode,DisplayName,EmployeeRuleID,CompanyID,CompanyRuleID,ProcessingStatus,LastChanged,UserID)
		SELECT (SELECT MAX(bi.BatchInstanceID) FROM Batch.BatchInstance bi)
			,EmployeeCode
			,DisplayName
			,EmployeeRuleID
			,CompanyID
			,CompanyRuleID
			,'U' AS ProcessingStatus
			,GETDATE()
			,UserID
		FROM Batch.BatchEmployee 
		WHERE BatchInstanceID = @BatchInstanceID
IF ((SELECT XACT_STATE()) = 1) COMMIT TRANSACTION END TRY 
BEGIN CATCH IF ((SELECT XACT_STATE()) = -1) ROLLBACK TRANSACTION END CATCH



BEGIN TRY BEGIN TRANSACTION
		INSERT INTO Batch.BatchEmployeeField (BatchEmployeeID,PayRunDefID,ProcessPeriodID,PayslipTypeID,BatchItemID,Sequence,Value,RowIndex,ProcessingStatus,Included,Verified,LastChanged,UserID)
		SELECT 
			(SELECT BatchEmployeeID FROM Batch.BatchEmployee WHERE BatchInstanceID = (SELECT MAX(BatchInstanceID) FROM Batch.BatchInstance) AND EmployeeCode = be.EmployeeCode)
			,bf.PayRunDefID
			,bf.ProcessPeriodID
			,0 AS PayslipTypeID
			,bf.BatchItemID
			,bf.Sequence
			,CASE WHEN bi.[Override] = 1 THEN 0.0000 ELSE CONVERt(decimal(18,4),bf.[Value]) * -1 END 
			,1 AS RowIndex
			,'V' AS ProcessingStatus
			,1 AS Included
			,0 AS Verified
			,GETDATE()
			,bf.UserID
		FROM Batch.BatchEmployeeField bf
			INNER JOIN Batch.BatchEmployee be ON be.BatchEmployeeID = bf.BatchEmployeeID
			INNER JOIN Batch.BatchItem bi ON bi.BatchItemID = bf.BatchItemID
		WHERE be.BatchInstanceID = @BatchInstanceID
IF ((SELECT XACT_STATE()) = 1) COMMIT TRANSACTION END TRY 
BEGIN CATCH IF ((SELECT XACT_STATE()) = -1) ROLLBACK TRANSACTION END CATCH

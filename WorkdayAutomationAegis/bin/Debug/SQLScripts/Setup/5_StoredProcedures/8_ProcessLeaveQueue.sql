CREATE PROCEDURE [AI].[ProcessLeaveQueue]
AS

--Mark Non Annual/Unpaid as Ignored.
BEGIN TRANSACTION
UPDATE AI.LeaveBalanceQueue 
SET StatusCode = 'Ignore', StatusMessage = 'Non-Annual/Unpaid Leave Type Excluded from automation', EventCode = 'Ignored', EventDescription = 'Non-Annual/Unpaid Leave Type Excluded from automation' 
FROM AI.LeaveBalanceQueue q
	INNER JOIN AI.CatalogMapping c ON c.TargetField = q.LeaveTypeCode
WHERE CatalogName IN ('Non-Annual/Unpaid Leave')
COMMIT

--Remove previously run successful records
INSERT INTO AI.LeaveBalanceQueueHistory SELECT * FROM AI.LeaveBalanceQueue WHERE StatusCode IN ('Success','Ignore')
DELETE FROM AI.LeaveBalanceQueue WHERE StatusCode IN ('Success','Ignore')

--Update previous failures to be reset and processed again
UPDATE AI.LeaveBalanceQueue
SET StatusCode = 'New', StatusMessage = NULL, ErrorCode = NULL, ErrorMessage = NULL
WHERE StatusCode IN ('New','Failed')

DECLARE @UserDefinedBatchType AS AI.UserDefinedBatchType

INSERT INTO @UserDefinedBatchType (ProductCode,EmployeeCode,Company,CompanyRule,PayRun,BatchTemplateCode,LineType,BatchItemCode,BatchItemType,Value,StatusCode,StatusComment,LastChanged,UserID)
SELECT 'WDL' [ProductCode],EmployeeCode,NULL [Company],NULL [CompanyRule],NULL [PayRun],'WORKDAY_LEAVE' [BatchTemplateCode],'Leave' [LineType],ISNULL(LeaveCode,'None') [BatchItemCode],'Adjustment' [BatchItemType],UnitOverride [Value],'New' [StatusCode],QueueComment [StatusComment],GETDATE() [LastChanged],'AUTO' [UserID]
FROM AI.LeaveBalanceQueue
WHERE StatusCode = 'New'

DECLARE @OutputResult Table([ProductCode] [varchar](3),[EmployeeCode] [varchar](15),[FirstName] [varchar](50),[LastName] [varchar](50),[Company] [varchar](15),
	[CompanyRule] [varchar](15),[PayRun] [varchar](15),[BatchTemplateCode] [varchar](15),[LineType] [varchar](15),[BatchItemCode] [varchar](15),
	[BatchItemType] [varchar](25),[Value] [varchar](256),[StatusCode] [varchar](15),[StatusComment] [varchar](250),[LastChanged] [datetime],[UserID] [varchar](32))

INSERT @OutputResult
EXEC AI.FinancialBatchSP @UserDefinedBatchType

UPDATE AI.LeaveBalanceQueue
SET StatusCode = res.StatusCode
	,StatusMessage = res.StatusComment
	,ErrorCode = res.StatusCode
	,ErrorMessage = res.StatusComment
FROM AI.LeaveBalanceQueue q
	INNER JOIN @OutputResult res ON res.EmployeeCode = q.EmployeeCode AND res.BatchItemCode = q.LeaveCode AND res.[Value] = q.UnitOverride
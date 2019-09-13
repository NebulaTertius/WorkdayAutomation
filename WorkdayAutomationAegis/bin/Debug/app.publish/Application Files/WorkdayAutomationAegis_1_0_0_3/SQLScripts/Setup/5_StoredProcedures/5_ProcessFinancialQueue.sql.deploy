CREATE PROCEDURE [AI].[ProcessFinancialQueue]
AS

--Remove previously run successful records
INSERT INTO AI.FinancialQueueHistory SELECT * FROM AI.FinancialQueue WHERE StatusCode = 'Success'
DELETE FROM AI.FinancialQueue WHERE StatusCode = 'Success'

--Update previous failures to be reset and processed again
UPDATE AI.FinancialQueue
SET StatusCode = 'New', StatusMessage = NULL, ErrorCode = NULL, ErrorMessage = NULL
WHERE StatusCode IN ('New','Failed')

DECLARE @UserDefinedBatchType AS AI.UserDefinedBatchType

INSERT INTO @UserDefinedBatchType (ProductCode,EmployeeCode,Company,CompanyRule,PayRun,BatchTemplateCode,LineType,BatchItemCode,BatchItemType,Value,StatusCode,StatusComment,LastChanged,UserID)
SELECT 'PAY' [ProductCode],EmployeeCode,NULL [Company],NULL [CompanyRule],NULL [PayRun],'WORKDAY_' + CASE WHEN OneTimePayment = 'false' THEN 'RECUR' ELSE 'OTP' END [BatchTemplateCode],'Earning' [LineType],ISNULL(WageTypeCode,'None') [BatchItemCode],'Amount' [BatchItemType],Amount [Value],'New' [StatusCode],QueueComment [StatusComment],GETDATE() [LastChanged],'AUTO' [UserID]
FROM AI.FinancialQueue
WHERE StatusCode = 'New'

DECLARE @OutputResult Table([ProductCode] [varchar](3),[EmployeeCode] [varchar](15),[FirstName] [varchar](50),[LastName] [varchar](50),[Company] [varchar](15),
	[CompanyRule] [varchar](15),[PayRun] [varchar](15),[BatchTemplateCode] [varchar](15),[LineType] [varchar](15),[BatchItemCode] [varchar](15),
	[BatchItemType] [varchar](25),[Value] [varchar](256),[StatusCode] [varchar](15),[StatusComment] [varchar](250),[LastChanged] [datetime],[UserID] [varchar](32))

INSERT @OutputResult
EXEC AI.FinancialBatchSP @UserDefinedBatchType

UPDATE AI.FinancialQueue
SET StatusCode = res.StatusCode
	,StatusMessage = res.StatusComment
	,ErrorCode = res.StatusCode
	,ErrorMessage = res.StatusComment
FROM AI.FinancialQueue q
	INNER JOIN @OutputResult res ON res.EmployeeCode = q.EmployeeCode AND res.BatchItemCode = q.WageTypeCode AND res.[Value] = q.Amount

INSERT INTO AI.AllowanceAndOTPSourceHistory SELECT * FROM AI.AllowanceAndOTPSource
DELETE FROM AI.AllowanceAndOTPSource

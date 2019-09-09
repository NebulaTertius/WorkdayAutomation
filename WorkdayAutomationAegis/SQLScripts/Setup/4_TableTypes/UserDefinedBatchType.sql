IF OBJECT_ID('AI.FinancialBatchSP', 'P') IS NOT NULL DROP PROCEDURE AI.FinancialBatchSP
IF TYPE_ID('AI.UserDefinedBatchType') IS NOT NULL DROP TYPE AI.UserDefinedBatchType
CREATE TYPE [AI].[UserDefinedBatchType] AS TABLE(
	[ProductCode] [varchar](3) NOT NULL,
	[EmployeeCode] [varchar](15) NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Company] [varchar](15) NULL,
	[CompanyRule] [varchar](15) NULL,
	[PayRun] [varchar](15) NULL,
	[BatchTemplateCode] [varchar](15) NOT NULL,
	[LineType] [varchar](15) NOT NULL,
	[BatchItemCode] [varchar](15) NOT NULL,
	[BatchItemType] [varchar](25) NOT NULL,
	[Value] [varchar](256) NOT NULL,
	[StatusCode] [varchar](15) NULL,
	[StatusComment] [varchar](250) NULL,
	[LastChanged] [datetime] NULL,
	[UserID] [varchar](32) NULL
)
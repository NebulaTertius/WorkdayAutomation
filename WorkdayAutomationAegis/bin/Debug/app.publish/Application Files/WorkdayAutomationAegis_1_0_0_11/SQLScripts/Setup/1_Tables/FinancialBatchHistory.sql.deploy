IF OBJECT_ID('AI.FinancialBatchHistory', 'U') IS NOT NULL DROP TABLE AI.FinancialBatchHistory
CREATE TABLE [AI].[FinancialBatchHistory](
	[FinancialBatchHistoryID] [int] IDENTITY(1,1) NOT NULL,
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
	[StatusCode] [varchar](15) NOT NULL,
	[StatusComment] [varchar](250) NULL,
	[LastChanged] [datetime] NOT NULL,
	[UserID] [varchar](32) NULL,
PRIMARY KEY CLUSTERED 
(
	[FinancialBatchHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [AI].[FinancialBatchHistory] ADD  CONSTRAINT [DF_FinancialBatchHistory_StatusCode]  DEFAULT ('N') FOR [StatusCode]

ALTER TABLE [AI].[FinancialBatchHistory] ADD  CONSTRAINT [DF_FinancialBatchHistory_LastChanged]  DEFAULT (getdate()) FOR [LastChanged]

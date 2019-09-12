IF OBJECT_ID('AI.FinancialQueue', 'U') IS NOT NULL DROP TABLE AI.FinancialQueue
CREATE TABLE [AI].[FinancialQueue](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EventCode] [nvarchar](100) NULL,
	[EventDescription] [nvarchar](100) NULL,
	[EventSequenceID] [smallint] NULL,
	[EffectiveStartDate] [datetime] NULL,
	[EffectiveEndDate] [datetime] NULL,
	[CountryCodeIndicator] [nvarchar](100) NULL,
	[CompanyCode] [nvarchar](100) NULL,
	[EmployeeCode] [nvarchar](100) NULL,
	[WageTypeCode] [nvarchar](100) NULL,
	[Amount] [nvarchar](100) NULL,
	[Ccy] [nvarchar](100) NULL,
	[OneTimePayment] [nvarchar](100) NULL,
	[Frequency] [nvarchar](100) NULL,
	[EffectiveDate] [nvarchar](100) NULL,
	[EndDate] [nvarchar](100) NULL,
	[DateCreated] [datetime] NULL,
	[LastChanged] [datetime] NULL,
	[QueueComment] [nvarchar](max) NULL,
	[QueueFilter] [nvarchar](max) NULL,
	[StatusCode] [nvarchar](100) NULL,
	[StatusMessage] [nvarchar](max) NULL,
	[WarningCode] [nvarchar](100) NULL,
	[WarningMessage] [nvarchar](max) NULL,
	[ErrorCode] [nvarchar](100) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_FinancialQueue_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

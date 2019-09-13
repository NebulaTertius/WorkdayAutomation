IF OBJECT_ID('AI.AllowanceAndOTPSource', 'U') IS NOT NULL DROP TABLE AI.AllowanceAndOTPSource
CREATE TABLE [AI].[AllowanceAndOTPSource](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CountryCodeIndicator] [nvarchar](max) NULL,
	[EmployeeCode] [nvarchar](max) NULL,
	[WageTypeCode] [nvarchar](max) NULL,
	[Amount] [nvarchar](max) NULL,
	[Ccy] [nvarchar](max) NULL,
	[OneTimePayment] [nvarchar](max) NULL,
	[Frequency] [nvarchar](max) NULL,
	[EffectiveDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[SourceFileName] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_AllowanceAndOTPSource_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
IF OBJECT_ID('AI.AllowanceAndOTPSourceArchive', 'U') IS NOT NULL DROP TABLE AI.AllowanceAndOTPSourceArchive
CREATE TABLE [AI].[AllowanceAndOTPSourceArchive](
	[OID] [int] NULL,
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
)
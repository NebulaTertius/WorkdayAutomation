IF OBJECT_ID('AI.AbsenceSource', 'U') IS NOT NULL DROP TABLE AI.AbsenceSource
CREATE TABLE [AI].[AbsenceSource](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CountryCodeIndicator] [nvarchar](max) NULL,
	[EmployeeCode] [nvarchar](max) NULL,
	[LeaveID] [nvarchar](max) NULL,
	[LeaveTypeID] [nvarchar](max) NULL,
	[LeaveAction] [nvarchar](max) NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[UnitsTaken] [nvarchar](max) NULL,
	[Unit] [nvarchar](max) NULL,
	[SourceFileName] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_AbsenceSource_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
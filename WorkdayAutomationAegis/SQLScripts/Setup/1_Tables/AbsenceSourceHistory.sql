IF OBJECT_ID('AI.AbsenceSourceHistory', 'U') IS NOT NULL DROP TABLE AI.AbsenceSourceHistory
CREATE TABLE [AI].[AbsenceSourceHistory](
	[OID] [int] NULL,
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
)
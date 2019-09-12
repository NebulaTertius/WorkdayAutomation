IF OBJECT_ID('AI.LeaveBalanceQueue', 'U') IS NOT NULL DROP TABLE AI.LeaveBalanceQueue
CREATE TABLE [AI].[LeaveBalanceQueue](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EventCode] [nvarchar](100) NULL,
	[EventDescription] [nvarchar](100) NULL,
	[EventSequenceID] [smallint] NULL,
	[EffectiveStartDate] [datetime] NULL,
	[EffectiveEndDate] [datetime] NULL,
	[CountryCodeIndicator] [nvarchar](100) NULL,
	[EmployeeCode] [nvarchar](100) NULL,
	[LeaveTypeCode] [nvarchar](100) NULL,
	[LeaveCode] [nvarchar](100) NULL,
	[CurrentStartBalance] [decimal](18,4) NULL,
	[CurrentAccrual] [decimal](18,4) NULL,
	[CurrentTaken] [decimal](18,4) NULL,
	[CurrentAdjustment] [decimal](18,4) NULL,
	[CurrentEndBalance] [decimal](18,4) NULL,
	[CurrentPlanned] [decimal](18,4) NULL,
	[UnitAdjustment] [decimal](18,4) NULL,
	[UnitOverride] [decimal](18,4) NULL,
	[EndBalanceIncludingAdjustment] [decimal](18,4) NULL,
	[Note] [nvarchar](max) NULL,
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
 CONSTRAINT [PK_AI_LeaveBalanceQueue_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


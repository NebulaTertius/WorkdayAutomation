IF OBJECT_ID('AI.EmployeeSubQueue', 'U') IS NOT NULL DROP TABLE AI.EmployeeSubQueue
CREATE TABLE [AI].[EmployeeSubQueue](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EmployeeQueueOID] [int] NULL,
	[EmployeeCode] [nvarchar](100) NULL,
	[SubQueueTableType] [nvarchar](100) NULL,
	[SubQueueType] [nvarchar](max) NULL,
	[SubQueueValue] [nvarchar](max) NULL,
	[DateCreated] [datetime] NULL,
	[LastChanged] [datetime] NULL,
	[QueueComment] [nvarchar](100) NULL,
	[QueueFilter] [nvarchar](100) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_EmployeeSubQueue_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
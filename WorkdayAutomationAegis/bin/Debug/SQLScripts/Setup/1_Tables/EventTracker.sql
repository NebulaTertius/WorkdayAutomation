IF OBJECT_ID('AI.EventTracker', 'U') IS NOT NULL DROP TABLE AI.EventTracker
CREATE TABLE [AI].[EventTracker](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[QueueType] [nvarchar](100) NULL,
	[TrackerComment] [nvarchar](max) NULL,
	[TrackerCreatedDate] [datetime] NULL,
	[SourceOID] [int] NULL,
	[SourceComment] [nvarchar](max) NULL,
	[FieldName] [nvarchar](max) NULL,
	[PreProcessValue] [nvarchar](max) NULL,
	[QueueValue] [nvarchar](max) NULL,
	[PostProcessValue] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_EventTracker_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
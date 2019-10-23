IF OBJECT_ID('AI.QueueMapping', 'U') IS NOT NULL DROP TABLE AI.QueueMapping
CREATE TABLE [AI].[QueueMapping](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[QueueType] [nvarchar](max) NULL,
	[MappingType] [nvarchar](max) NULL,
	[SourceField] [nvarchar](max) NULL,
	[TargetField] [nvarchar](max) NULL,
	[TargetFieldDataType] [nvarchar](100) NULL,
	[TargetFieldMaxLength] [nvarchar](100) NULL,
	[DefaultValue] [nvarchar](100) NULL,
	[SQLStatement] [nvarchar](max) NULL,
	[CatalogStatement] [nvarchar](max) NULL,
	[Comment] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
	[TargetFieldDataFormat] [nvarchar](100) NULL,
 CONSTRAINT [PK_AI_QueueMapping_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
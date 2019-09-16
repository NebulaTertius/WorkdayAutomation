IF OBJECT_ID('AI.SourceValueOverride', 'U') IS NOT NULL DROP TABLE AI.SourceValueOverride
CREATE TABLE [AI].[SourceValueOverride](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SourceFieldName] [nvarchar](max) NULL,
	[SourceValue] [nvarchar](max) NULL,
	[OverrideValue] [nvarchar](max) NULL,
	[Comment] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_SourceValueOverride_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
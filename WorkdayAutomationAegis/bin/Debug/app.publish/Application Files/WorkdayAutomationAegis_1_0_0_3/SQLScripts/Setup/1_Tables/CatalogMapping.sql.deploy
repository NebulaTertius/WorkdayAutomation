IF OBJECT_ID('AI.CatalogMapping', 'U') IS NOT NULL DROP TABLE AI.CatalogMapping
CREATE TABLE [AI].[CatalogMapping](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CatalogType] [nvarchar](max) NULL,
	[CatalogSubType] [nvarchar](max) NULL,
	[CatalogName] [nvarchar](max) NULL,
	[CatalogLocale] [nvarchar](max) NULL,
	[LookupOrigin] [nvarchar](max) NULL,
	[LookupObjectType] [nvarchar](max) NULL,
	[LookupObjectName] [nvarchar](max) NULL,
	[LookupFieldName] [nvarchar](max) NULL,
	[SourceField] [nvarchar](max) NULL,
	[SourceValue] [nvarchar](max) NULL,
	[TargetField] [nvarchar](max) NULL,
	[TargetValue] [nvarchar](max) NULL,
	[Comment] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_CatalogMapping_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
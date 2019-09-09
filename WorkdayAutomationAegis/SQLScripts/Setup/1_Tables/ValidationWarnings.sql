IF OBJECT_ID('AI.ValidationWarnings', 'U') IS NOT NULL DROP TABLE AI.ValidationWarnings
CREATE TABLE AI.ValidationWarnings(
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	ValidationDate datetime NULL,
	ValidationType nvarchar(max) NULL,
	ValidationMessage nvarchar(max) NULL,
	SourceLocation nvarchar(max) NULL,
	CountryCode nvarchar(max) NULL,
	EmployeeCode nvarchar(max) NULL,
	FieldName nvarchar(max) NULL,
	FieldValue nvarchar(max) NULL,
	Comment nvarchar(max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_ValidationWarnings_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
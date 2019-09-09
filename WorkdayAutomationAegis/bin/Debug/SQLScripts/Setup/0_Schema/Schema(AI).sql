--Create Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'AI')
EXEC sys.sp_executesql N'CREATE SCHEMA [AI] AUTHORIZATION [dbo]'
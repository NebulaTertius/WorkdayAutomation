CREATE PROCEDURE AI.ArchiveTableData @TableName nvarchar(max)
AS

BEGIN TRY BEGIN TRAN
IF OBJECT_ID('tempdb..##TempArchive') IS NOT NULL DROP TABLE ##TempArchive

DECLARE @sql nvarchar(max)

SET @sql = 
N'
	SELECT * INTO ##TempArchive
	FROM (SELECT * FROM ' + @TableName + ' WHERE StatusCode <> ''Future'' UNION ALL SELECT * FROM ' + @TableName + 'Archive) e
	ORDER BY OID
	
	DROP TABLE '+@TableName+'Archive
	
	SELECT * INTO '+@TableName+'Archive
	FROM ##TempArchive
	ORDER BY OID

	DELETE FROM '+@TableName+' WHERE StatusCode <> ''Future''
'

EXEC sp_executesql @Sql

IF ((SELECT XACT_STATE()) = 1) COMMIT TRANSACTION 
END TRY 
BEGIN CATCH IF ((SELECT XACT_STATE()) = -1) ROLLBACK TRANSACTION END CATCH
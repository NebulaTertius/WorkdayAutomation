CREATE PROCEDURE AI.ValidateBatchTemplates
AS

--***Important Note:
--Must be done per company. Batch skips lines if there are multiple employees with the same DefCode, but in different companies.
--Table versions must be updated at the end to force a cache refresh.
--If the batch instance gives an Object Reference error for each line, this is due to the cache not refreshing, and therefore the system is not able to get the Batch Item

DECLARE @BatchTemplateCode varchar(15)
	,@OverrideIndicator int

--===========================================================================================================================================================
--Payslip Batch
--===========================================================================================================================================================
SET @BatchTemplateCode = 'WORKDAY_RECUR'
SET @OverrideIndicator = 1

IF NOT EXISTS (SELECT TOP 1 * FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode)
BEGIN
	INSERT INTO Batch.BatchTemplate (CompanyID,Code,ShortDescription,LongDescription,BatchTemplateType,BatchInstanceType,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies,[Status],ExportType,LastChanged,UserID)
	VALUES (1,@BatchTemplateCode, @BatchTemplateCode + ' Template',@BatchTemplateCode + ' Template','U','I',1,1,'W',0,1,'A','U',GETDATE(),'Automation')
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END

IF EXISTS (SELECT TOP 1 * FROM Company.CompanyRule WHERE [Status] = 'A' AND CompanyRuleID NOT IN (SELECT CompanyRuleID FROM Batch.BatchTemplateFilter btf INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = btf.BatchTemplateID WHERE bt.Code = @BatchTemplateCode))
BEGIN
	INSERT INTO Batch.BatchTemplateFilter (BatchTemplateID,CompanyRuleID,PayslipTypeID,PayRunDefOption,LastChanged,UserID)
	SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode)
		,CompanyRuleID
		,0
		,'M'
		,GETDATE()
		,'Automation'
	FROM Company.CompanyRule
	WHERE [Status] = 'A'
		AND CompanyRuleID NOT IN (SELECT CompanyRuleID FROM Batch.BatchTemplateFilter btf INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = btf.BatchTemplateID WHERE bt.Code = @BatchTemplateCode)
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END


IF EXISTS (SELECT TOP 1 * FROM Payroll.EarningDef WHERE DefCode NOT IN (SELECT REPLACE(REPLACE(FieldName,'PayslipEarningLine : ',''),'Amount','') FROM Batch.BatchItem bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bt.Code = @BatchTemplateCode))
BEGIN
	INSERT INTO Batch.BatchItem (BatchTemplateID,ItemType,SystemObjectFieldID,FieldType,Sequence,FieldName,FieldDisplayName,BatchHierarchy,Override,DefaultType,ColumnTotal,ShowOnReport,WidthMeasurement,LastChanged,UserID)
	SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode) [BatchTemplateID]
		,'V' [ItemType]
		,SystemObjectFieldID
		,FieldType
		,ROW_NUMBER() OVER (ORDER BY UserID) [Sequence]
		,FieldName
		,FieldDisplayName
		,BatchHierarchy
		,Override
		,'N' [DefaultType]
		,0 [ColumnTotal]
		,1 [ShowOnReport]
		,'U' [WidthMeasurement]
		,GETDATE() [LastChanged]
		,[UserID]
	FROM
	(
	--SystemObjectFieldID's:
	--Amount = 1600450154
	--Fixed = 1804359881
	--Leave Adjustment = 19079023
	SELECT NULL [SystemObjectFieldID],11 [FieldType],'CompanyID' [FieldName],'Company' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'EmployeeCode' [FieldName],'Employee Code' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'CompanyRuleID' [FieldName],'Company Rule' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'PayslipTypeID' [FieldName],'Payslip Type' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'ProcessPeriodID' [FieldName],'Process Period' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'PayRunDefID' [FieldName],'Pay Run Definition' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL
	SELECT '1600450154'
		,1
		,'PayslipEarningLine : ' + ed.DefCode + 'Amount'
		,'PayslipEarningLine : ' + ed.DefCode + ' - Amount'
		,'PS.EA.CODE.' + ed.DefCode + '.Amount'
		,@OverrideIndicator --1 = Override, 0 = Accumulate
		,'Automation'
	FROM Payroll.EarningDef ed
	) bt
	WHERE bt.FieldName NOT IN (SELECT FieldName FROM Batch.BatchItem bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bt.Code = @BatchTemplateCode)
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END




SET @BatchTemplateCode = 'WORKDAY_OTP'
SET @OverrideIndicator = 0

IF NOT EXISTS (SELECT TOP 1 * FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode)
BEGIN
	INSERT INTO Batch.BatchTemplate (CompanyID,Code,ShortDescription,LongDescription,BatchTemplateType,BatchInstanceType,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies,[Status],ExportType,LastChanged,UserID)
	VALUES (1,@BatchTemplateCode, @BatchTemplateCode + ' Template',@BatchTemplateCode + ' Template','U','I',1,1,'W',0,1,'A','U',GETDATE(),'Automation')
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END

IF EXISTS (SELECT TOP 1 * FROM Company.CompanyRule WHERE [Status] = 'A' AND CompanyRuleID NOT IN (SELECT CompanyRuleID FROM Batch.BatchTemplateFilter btf INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = btf.BatchTemplateID WHERE bt.Code = @BatchTemplateCode))
BEGIN
	INSERT INTO Batch.BatchTemplateFilter (BatchTemplateID,CompanyRuleID,PayslipTypeID,PayRunDefOption,LastChanged,UserID)
	SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode)
		,CompanyRuleID
		,0
		,'M'
		,GETDATE()
		,'Automation'
	FROM Company.CompanyRule
	WHERE [Status] = 'A'
		AND CompanyRuleID NOT IN (SELECT CompanyRuleID FROM Batch.BatchTemplateFilter btf INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = btf.BatchTemplateID WHERE bt.Code = @BatchTemplateCode)
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END


IF EXISTS (SELECT TOP 1 * FROM Payroll.EarningDef WHERE DefCode NOT IN (SELECT REPLACE(REPLACE(FieldName,'PayslipEarningLine : ',''),'Amount','') FROM Batch.BatchItem bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bt.Code = @BatchTemplateCode))
BEGIN
	INSERT INTO Batch.BatchItem (BatchTemplateID,ItemType,SystemObjectFieldID,FieldType,Sequence,FieldName,FieldDisplayName,BatchHierarchy,Override,DefaultType,ColumnTotal,ShowOnReport,WidthMeasurement,LastChanged,UserID)
	SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode) [BatchTemplateID]
		,'V' [ItemType]
		,SystemObjectFieldID
		,FieldType
		,ROW_NUMBER() OVER (ORDER BY UserID) [Sequence]
		,FieldName
		,FieldDisplayName
		,BatchHierarchy
		,Override
		,'N' [DefaultType]
		,0 [ColumnTotal]
		,1 [ShowOnReport]
		,'U' [WidthMeasurement]
		,GETDATE() [LastChanged]
		,[UserID]
	FROM
	(
	--SystemObjectFieldID's:
	--Amount = 1600450154
	--Fixed = 1804359881
	--Leave Adjustment = 19079023
	SELECT NULL [SystemObjectFieldID],11 [FieldType],'CompanyID' [FieldName],'Company' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'EmployeeCode' [FieldName],'Employee Code' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'CompanyRuleID' [FieldName],'Company Rule' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'PayslipTypeID' [FieldName],'Payslip Type' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'ProcessPeriodID' [FieldName],'Process Period' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'PayRunDefID' [FieldName],'Pay Run Definition' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL
	SELECT '1600450154'
		,1
		,'PayslipEarningLine : ' + ed.DefCode + 'Amount'
		,'PayslipEarningLine : ' + ed.DefCode + ' - Amount'
		,'PS.EA.CODE.' + ed.DefCode + '.Amount'
		,@OverrideIndicator --1 = Override, 0 = Accumulate
		,'Automation'
	FROM Payroll.EarningDef ed
	) bt
	WHERE bt.FieldName NOT IN (SELECT FieldName FROM Batch.BatchItem bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bt.Code = @BatchTemplateCode)
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END



--===========================================================================================================================================================
--Leave Batch
--===========================================================================================================================================================


SET @BatchTemplateCode = 'WORKDAY_LEAVE'
SET @OverrideIndicator = 1

IF NOT EXISTS (SELECT TOP 1 * FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode)
BEGIN
	INSERT INTO Batch.BatchTemplate (CompanyID,Code,ShortDescription,LongDescription,BatchTemplateType,BatchInstanceType,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies,[Status],ExportType,LastChanged,UserID)
	VALUES (1,@BatchTemplateCode, @BatchTemplateCode + ' Template',@BatchTemplateCode + ' Template','U','I',1,1,'W',0,1,'A','U',GETDATE(),'Automation')
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END

IF EXISTS (SELECT TOP 1 * FROM Company.CompanyRule WHERE [Status] = 'A' AND CompanyRuleID NOT IN (SELECT CompanyRuleID FROM Batch.BatchTemplateFilter btf INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = btf.BatchTemplateID WHERE bt.Code = @BatchTemplateCode))
BEGIN
	INSERT INTO Batch.BatchTemplateFilter (BatchTemplateID,CompanyRuleID,PayslipTypeID,PayRunDefOption,LastChanged,UserID)
	SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode)
		,CompanyRuleID
		,0
		,'M'
		,GETDATE()
		,'Automation'
	FROM Company.CompanyRule
	WHERE [Status] = 'A'
		AND CompanyRuleID NOT IN (SELECT CompanyRuleID FROM Batch.BatchTemplateFilter btf INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = btf.BatchTemplateID WHERE bt.Code = @BatchTemplateCode)
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END


IF EXISTS (SELECT TOP 1 * FROM Leave.LeaveDef WHERE Code NOT IN (SELECT REPLACE(REPLACE(FieldName,'EmployeeLeave : ',''),'Adjustment','') FROM Batch.BatchItem bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bt.Code = @BatchTemplateCode))
BEGIN
	INSERT INTO Batch.BatchItem (BatchTemplateID,ItemType,SystemObjectFieldID,FieldType,Sequence,FieldName,FieldDisplayName,BatchHierarchy,Override,DefaultType,ColumnTotal,ShowOnReport,WidthMeasurement,LastChanged,UserID)
	SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = @BatchTemplateCode) [BatchTemplateID]
		,'V' [ItemType]
		,SystemObjectFieldID
		,FieldType
		,ROW_NUMBER() OVER (ORDER BY UserID) [Sequence]
		,FieldName
		,FieldDisplayName
		,BatchHierarchy
		,Override
		,'N' [DefaultType]
		,0 [ColumnTotal]
		,1 [ShowOnReport]
		,'U' [WidthMeasurement]
		,GETDATE() [LastChanged]
		,[UserID]
	FROM
	(
	--SystemObjectFieldID's:
	--Amount = 1600450154
	--Fixed = 1804359881
	--Leave Adjustment = 19079023
	SELECT NULL [SystemObjectFieldID],11 [FieldType],'CompanyID' [FieldName],'Company' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'EmployeeCode' [FieldName],'Employee Code' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'CompanyRuleID' [FieldName],'Company Rule' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'PayslipTypeID' [FieldName],'Payslip Type' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'ProcessPeriodID' [FieldName],'Process Period' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL SELECT NULL [SystemObjectFieldID],11 [FieldType],'PayRunDefID' [FieldName],'Pay Run Definition' [FieldDisplayName],'FIELD' [BatchHierarchy],0 [Override],'Automation' [UserID]
	UNION ALL
	SELECT DISTINCT '19079023'
		,NULL
		,'EmployeeLeave : ' + l.Code + 'Adjustment'
		,'EmployeeLeave : ' + l.Code + ' - Adjustment'
		,'EE.EL.' + l.Code + '.Adjustment'
		,1 --Override
		,'Automation'
	FROM Leave.LeaveDef l
	) bt
	WHERE bt.FieldName NOT IN (SELECT FieldName FROM Batch.BatchItem bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bt.Code = @BatchTemplateCode)
	
	UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] IN ('BatchTemplateList','BatchItemList')
END
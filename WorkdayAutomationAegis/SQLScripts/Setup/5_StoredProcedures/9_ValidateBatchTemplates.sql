CREATE PROCEDURE AI.ValidateBatchTemplates
AS

--***Important Note:
--Must be done per company. Batch skips lines if there are multiple employees with the same DefCode, but in different companies.
--If the batch instance gives an Object Reference error for each line, close the system, make sure after the template is created, and then refresh Sage 300 People cache. 

--===========================================================================================================================================================
--Payslip Batch
--===========================================================================================================================================================
IF NOT EXISTS (SELECT TOP 1 * FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_RECUR')
BEGIN
--Override
INSERT INTO Batch.BatchTemplate (CompanyID,Code,ShortDescription,LongDescription,BatchTemplateType,BatchInstanceType,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies,[Status],ExportType,LastChanged,UserID)
VALUES (1,'WORKDAY_RECUR','Workday Recurring Template','Workday Recurring Template','U','I',1,1,'W',0,1,'A','U',GETDATE(),'Automation')

INSERT INTO Batch.BatchTemplateFilter (BatchTemplateID,CompanyRuleID,PayslipTypeID,PayRunDefOption,LastChanged,UserID)
SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_RECUR')
	,CompanyRuleID
	,0
	,'M'
	,GETDATE()
	,'Automation'
FROM Company.CompanyRule
WHERE [Status] = 'A'



INSERT INTO Batch.BatchItem (BatchTemplateID,ItemType,SystemObjectFieldID,FieldType,Sequence,FieldName,FieldDisplayName,BatchHierarchy,Override,DefaultType,ColumnTotal,ShowOnReport,WidthMeasurement,LastChanged,UserID)
SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_RECUR') [BatchTemplateID]
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
	,1 --Override
	,'Automation'
FROM Payroll.EarningDef ed
) bt
END



IF NOT EXISTS (SELECT TOP 1 * FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_OTP')
BEGIN
--Accummulate Template
INSERT INTO Batch.BatchTemplate (CompanyID,Code,ShortDescription,LongDescription,BatchTemplateType,BatchInstanceType,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies,[Status],ExportType,LastChanged,UserID)
VALUES (1,'WORKDAY_OTP','Workday Once Off Template','Workday Once Off Template','U','I',1,1,'W',0,1,'A','U',GETDATE(),'Automation')

INSERT INTO Batch.BatchTemplateFilter (BatchTemplateID,CompanyRuleID,PayslipTypeID,PayRunDefOption,LastChanged,UserID)
SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_OTP')
	,CompanyRuleID
	,0
	,'M'
	,GETDATE()
	,'Automation'
FROM Company.CompanyRule
WHERE [Status] = 'A'

INSERT INTO Batch.BatchItem (BatchTemplateID,ItemType,SystemObjectFieldID,FieldType,Sequence,FieldName,FieldDisplayName,BatchHierarchy,Override,DefaultType,ColumnTotal,ShowOnReport,WidthMeasurement,LastChanged,UserID)
SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_OTP') [BatchTemplateID]
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
SELECT DISTINCT '1600450154'
	,1
	,'PayslipEarningLine : ' + ed.DefCode + 'Amount'
	,'PayslipEarningLine : ' + ed.DefCode + ' - Amount'
	,'PS.EA.CODE.' + ed.DefCode + '.Amount'
	,0 --Accummulate
	,'Automation'
FROM Payroll.EarningDef ed
) bt
END


--===========================================================================================================================================================
--Leave Batch
--===========================================================================================================================================================

IF NOT EXISTS (SELECT TOP 1 * FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_LEAVE')
BEGIN
--Overrid Template - No accumulate adjustment can be done for leave
INSERT INTO Batch.BatchTemplate (CompanyID,Code,ShortDescription,LongDescription,BatchTemplateType,BatchInstanceType,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies,[Status],ExportType,LastChanged,UserID)
VALUES (1,'WORKDAY_LEAVE','Workday Leave Balance Template','Workday Leave Balance Adjust Template','U','I',1,1,'W',0,1,'A','U',GETDATE(),'Automation')

INSERT INTO Batch.BatchTemplateFilter (BatchTemplateID,CompanyRuleID,PayslipTypeID,PayRunDefOption,LastChanged,UserID)
SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_LEAVE')
	,CompanyRuleID
	,0
	,'M'
	,GETDATE()
	,'Automation'
FROM Company.CompanyRule
WHERE [Status] = 'A'

INSERT INTO Batch.BatchItem (BatchTemplateID,ItemType,SystemObjectFieldID,FieldType,Sequence,FieldName,FieldDisplayName,BatchHierarchy,Override,DefaultType,ColumnTotal,ShowOnReport,WidthMeasurement,LastChanged,UserID)
SELECT (SELECT TOP 1 BatchTemplateID FROM Batch.BatchTemplate WHERE Code = 'WORKDAY_LEAVE') [BatchTemplateID]
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
END

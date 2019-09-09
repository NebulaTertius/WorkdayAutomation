CREATE PROCEDURE AI.RefreshValidationWarnings
AS

--##########################
--New Source Mapping Values
--##########################
--New Mapping Values
IF OBJECT_ID('tempdb..##EmployeeCatalogFields') IS NOT NULL DROP TABLE ##EmployeeCatalogFields
SELECT DISTINCT CatalogType, CatalogLocale, SourceField
INTO ##EmployeeCatalogFields
FROM AI.CatalogMapping 
WHERE CatalogType = 'Employee Batch' 
	AND SourceField IN (SELECT SourceField FROM AI.QueueMapping)
ORDER BY SourceField


TRUNCATE TABLE AI.ValidationWarnings

DECLARE @FieldName nvarchar(max)
	,@Sql nvarchar(max)
WHILE EXISTS (SELECT * FROM ##EmployeeCatalogFields)
BEGIN
	SET @FieldName = (SELECT TOP 1 SourceField FROM ##EmployeeCatalogFields ORDER BY SourceField)
	SET @Sql = N'
	INSERT INTO AI.ValidationWarnings (ValidationDate,ValidationType,ValidationMessage,SourceLocation,CountryCode,EmployeeCode,FieldName,FieldValue,Comment)
	SELECT GETDATE() [ValidationDate],''Employee Batch'' [ValidationType],''New Mapping Value'' [ValidationMessage]
		,SourceFileName [SourceLocation],CountryCodeIndicator [CountryCode],EmployeeCode,'''+@FieldName+''' [FieldName],'+@FieldName+' [FieldValue]
		,''Update the catalog mapping or correct the source data if invalid.'' [Comment] 
	FROM AI.EmployeeSource WHERE '+@FieldName+' IS NOT NULL AND '+@FieldName+' NOT IN (SELECT SourceValue FROM AI.CatalogMapping WHERE SourceField = '''+@FieldName+''')
	'
	EXEC sp_executesql @Sql

	DELETE TOP(1) FROM ##EmployeeCatalogFields WHERE SourceField = @FieldName
END




--New Earning Lines
IF OBJECT_ID('tempdb..##PayslipCatalogFields') IS NOT NULL DROP TABLE ##PayslipCatalogFields
SELECT DISTINCT CatalogType, CatalogLocale, SourceField
INTO ##PayslipCatalogFields
FROM AI.CatalogMapping 
WHERE CatalogType = 'Payslip Batch' 
ORDER BY SourceField

--TRUNCATE TABLE AI.ValidationWarnings
--DECLARE @Sql nvarchar(max)
BEGIN
	SET @Sql = N'
	INSERT INTO AI.ValidationWarnings (ValidationDate,ValidationType,ValidationMessage,SourceLocation,CountryCode,EmployeeCode,FieldName,FieldValue,Comment)
	SELECT DISTINCT GETDATE() [ValidationDate],''Payslip Batch'' [ValidationType],''New Earning Type'' [ValidationMessage]
		,SourceFileName [SourceLocation],CountryCodeIndicator [CountryCode],EmployeeCode,''Earning'' [FieldName],WageTypeCode [FieldValue]
		,''Update the catalog mapping or correct the source data if invalid.'' [Comment] 
	FROM AI.AllowanceAndOTPSource WHERE WageTypeCode IS NOT NULL AND WageTypeCode NOT IN (SELECT SourceValue FROM AI.CatalogMapping WHERE CatalogType = ''Payslip Batch'')
	'
	EXEC sp_executesql @Sql
END



--New Leave Type Lines
IF OBJECT_ID('tempdb..##LeaveCatalogFields') IS NOT NULL DROP TABLE ##LeaveCatalogFields
SELECT DISTINCT CatalogType, CatalogLocale, SourceField
INTO ##LeaveCatalogFields
FROM AI.CatalogMapping 
WHERE CatalogType = 'Leave Batch' 
ORDER BY SourceField

--TRUNCATE TABLE AI.ValidationWarnings
--DECLARE @Sql nvarchar(max)
BEGIN
	SET @Sql = N'
	INSERT INTO AI.ValidationWarnings (ValidationDate,ValidationType,ValidationMessage,SourceLocation,CountryCode,EmployeeCode,FieldName,FieldValue,Comment)
	SELECT DISTINCT GETDATE() [ValidationDate],''Leave Batch'' [ValidationType],''New Leave Type'' [ValidationMessage]
		,SourceFileName [SourceLocation],CountryCodeIndicator [CountryCode],EmployeeCode,''Leave Type'' [FieldName],LeaveTypeID [FieldValue]
		,''Update the catalog mapping or correct the source data if invalid.'' [Comment] 
	FROM AI.AbsenceSource WHERE LeaveTypeID IS NOT NULL AND LeaveTypeID NOT IN (SELECT SourceValue FROM AI.CatalogMapping WHERE CatalogType = ''Leave Batch'')
	'
	EXEC sp_executesql @Sql
END



--##########################
--Invalid Target Mapping Values
--##########################



IF OBJECT_ID('tempdb..##EmployeeTargetCatalogFields') IS NOT NULL DROP TABLE ##EmployeeTargetCatalogFields
SELECT DISTINCT CatalogType, CatalogLocale, LookupObjectName, LookupFieldName
INTO ##EmployeeTargetCatalogFields
FROM AI.CatalogMapping 
WHERE CatalogType = 'Employee Batch'
	AND LookupOrigin = 'Sage300People' 
	AND LookupObjectType = 'Table'
ORDER BY LookupObjectName


DECLARE @ObjectName nvarchar(max)
	--,@FieldName nvarchar(max)
	--,@Sql nvarchar(max)
WHILE EXISTS (SELECT * FROM ##EmployeeTargetCatalogFields)
BEGIN
	SET @ObjectName = (SELECT TOP 1 LookupObjectName FROM ##EmployeeTargetCatalogFields ORDER BY LookupObjectName)
	SET @FieldName = (SELECT TOP 1 LookupFieldName FROM ##EmployeeTargetCatalogFields ORDER BY LookupObjectName)

	SET @Sql = N'
	INSERT INTO AI.ValidationWarnings (ValidationDate,ValidationType,ValidationMessage,SourceLocation,CountryCode,EmployeeCode,FieldName,FieldValue,Comment)
	SELECT GETDATE() [ValidationDate],''Invalid Target Value'' [ValidationType],''Target Value Does Not Exist On Sage'' [ValidationMessage]
		,''Catalog: '+@ObjectName+''' [SourceLocation],NULL [CountryCode],NULL [EmployeeCode],'''+@FieldName+''' [FieldName],TargetValue [FieldValue]
		,''Update the catalog mapping or correct the source data if invalid.'' [Comment] 
	FROM AI.CatalogMapping 
	WHERE CatalogType = ''Employee Batch'' AND LookupObjectName = '''+@ObjectName+''' AND TargetValue NOT IN (SELECT '+@FieldName+' FROM '+@ObjectName+')
	'
	EXEC sp_executesql @Sql

	DELETE TOP(1) FROM ##EmployeeTargetCatalogFields WHERE LookupObjectName = @ObjectName AND LookupFieldName = @FieldName
END


--Earning Lines

BEGIN
	SET @Sql = N'
	INSERT INTO AI.ValidationWarnings (ValidationDate,ValidationType,ValidationMessage,SourceLocation,CountryCode,EmployeeCode,FieldName,FieldValue,Comment)
	SELECT DISTINCT GETDATE() [ValidationDate],''Earning Line Does Not Exist On Sage'' [ValidationType],''Create New Earning Line or Adjust Mapping'' [ValidationMessage]
		,''Catalog: Earning'' [SourceLocation],CatalogLocale [CountryCode],NULL [EmployeeCode],TargetField [FieldName],TargetValue [FieldValue]
		,''Update the catalog mapping or correct the source data if invalid.'' [Comment] 
	FROM AI.CatalogMapping cm 
		LEFT JOIN (SELECT c.TaxCountryCode, d.DefCode FROM Payroll.EarningDef d INNER JOIN Company.Company c ON c.CompanyID = d.CompanyID) d ON CASE ISNULL(cm.CatalogLocale,''All'') WHEN ''All'' THEN d.TaxCountryCode ELSE cm.CatalogLocale END = d.TaxCountryCode AND cm.TargetValue = d.DefCode
	WHERE CatalogType = ''Payslip Batch''
		AND d.DefCode IS NULL
	ORDER BY CatalogLocale, TargetValue
	'
	EXEC sp_executesql @Sql

END


--Leave Lines
BEGIN
	SET @Sql = N'
	INSERT INTO AI.ValidationWarnings (ValidationDate,ValidationType,ValidationMessage,SourceLocation,CountryCode,EmployeeCode,FieldName,FieldValue,Comment)
	SELECT DISTINCT GETDATE() [ValidationDate],''Leave Type Does Not Exist On Sage'' [ValidationType],''Create New Leave Type or Adjust Mapping'' [ValidationMessage]
		,''Catalog: Leave'' [SourceLocation],CatalogLocale [CountryCode],NULL [EmployeeCode],TargetField [FieldName],TargetValue [FieldValue]
		,''Update the catalog mapping or correct the source data if invalid.'' [Comment] 
	FROM AI.CatalogMapping cm 
		LEFT JOIN (SELECT DISTINCT c.TaxCountryCode, lp.Code [LeavePolicyCode], lp.LongDescription [LeavePolicy], lt.Code [LeaveTypeCode]
			FROM Leave.LeavePolicy lp
				INNER JOIN Company.Company c ON c.CompanyID = lp.CompanyID
				INNER JOIN Leave.LeavePolicyDefRel lpdr ON lpdr.LeavePolicyID = lp.LeavePolicyID
				INNER JOIN Leave.LeaveDef ld ON ld.LeaveDefID = lpdr.LeaveDefID
				INNER JOIN Leave.LeaveType lt ON lt.LeaveTypeID = ld.LeaveTypeID) l ON CASE ISNULL(cm.CatalogLocale,''All'') WHEN ''All'' THEN l.TaxCountryCode ELSE cm.CatalogLocale END = l.TaxCountryCode AND cm.TargetValue = l.LeaveTypeCode
	WHERE CatalogType = ''Leave Batch''
		AND l.LeaveTypeCode IS NULL
	ORDER BY CatalogLocale, TargetValue
	'
	EXEC sp_executesql @Sql

END

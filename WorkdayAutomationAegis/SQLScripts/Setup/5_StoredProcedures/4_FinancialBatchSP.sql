CREATE PROCEDURE [AI].[FinancialBatchSP]
	@UDB AI.UserDefinedBatchType READONLY
	,@ProductCode varchar(3) = NULL
	,@EmployeeCode varchar(15) = NULL
	,@FirstName varchar(50) = NULL
	,@LastName varchar(50) = NULL
	,@Company varchar(15) = NULL
	,@CompanyRule varchar(15) = NULL
	,@PayRun varchar(15) = NULL
	,@BatchTemplateCode varchar(15) = NULL
	,@LineType varchar(15) = NULL
	,@BatchItemCode varchar(15) = NULL
	,@BatchItemType varchar(25) = NULL
	,@Value varchar (256) = NULL
	,@StatusCode varchar(15) = NULL
	,@StatusComment varchar(250) = NULL
	,@LastChanged datetime = NULL
	,@UserID varchar(32) = NULL
	,@BatchVersion int = 1
	,@OutputFilter varchar(MAX) = NULL
	,@SQL nvarchar(MAX) = NULL
	
AS
	SET NOCOUNT ON

IF EXISTS (SELECT * FROM (SELECT * FROM @UDB UNION ALL SELECT @ProductCode,@EmployeeCode,@FirstName,@LastName,@Company,@CompanyRule,@PayRun,@BatchTemplateCode,@LineType,@BatchItemCode,@BatchItemType,@Value,@StatusCode,@StatusComment,@LastChanged,@UserID) r WHERE r.ProductCode IS NOT NULL AND r.EmployeeCode IS NOT NULL AND r.BatchTemplateCode IS NOT NULL AND r.LineType IS NOT NULL AND r.BatchItemCode IS NOT NULL AND r.BatchItemType IS NOT NULL AND r.Value IS NOT NULL)
BEGIN

IF EXISTS (SELECT * FROM @UDB)
	BEGIN
		INSERT INTO AI.FinancialBatchHistory
		SELECT LTRIM(RTRIM(ProductCode)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(EmployeeCode)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(FirstName)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(LastName)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,CASE WHEN LTRIM(RTRIM(Company)) = '' THEN NULL ELSE LTRIM(RTRIM(Company)) END COLLATE SQL_Latin1_General_CP1_CI_AS
			,CASE WHEN LTRIM(RTRIM(CompanyRule)) = '' THEN NULL ELSE LTRIM(RTRIM(CompanyRule)) END COLLATE SQL_Latin1_General_CP1_CI_AS
			,CASE WHEN LTRIM(RTRIM(PayRun)) = '' THEN NULL ELSE LTRIM(RTRIM(PayRun)) END COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(BatchTemplateCode)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(LineType)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(BatchItemCode)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(BatchItemType)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(Value)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(StatusCode)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LTRIM(RTRIM(StatusComment)) COLLATE SQL_Latin1_General_CP1_CI_AS
			,LastChanged
			,LTRIM(RTRIM(UserID)) COLLATE SQL_Latin1_General_CP1_CI_AS
		FROM @UDB
	END
ELSE
	BEGIN
	IF @StatusCode IS NULL SET @StatusCode = 'New'
	IF @LastChanged IS NULL SET @LastChanged = GETDATE()

	INSERT INTO AI.FinancialBatchHistory
	SELECT LTRIM(RTRIM(@ProductCode)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@EmployeeCode)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@FirstName)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@LastName)) COLLATE SQL_Latin1_General_CP1_CI_AS,CASE WHEN LTRIM(RTRIM(@Company)) = '' THEN NULL ELSE LTRIM(RTRIM(@Company)) END COLLATE SQL_Latin1_General_CP1_CI_AS,CASE WHEN LTRIM(RTRIM(@CompanyRule)) = '' THEN NULL ELSE LTRIM(RTRIM(@CompanyRule)) END COLLATE SQL_Latin1_General_CP1_CI_AS,CASE WHEN LTRIM(RTRIM(@PayRun)) = '' THEN NULL ELSE LTRIM(RTRIM(@PayRun)) END COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@BatchTemplateCode)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@LineType)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@BatchItemCode)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@BatchItemType)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@Value)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@StatusCode)) COLLATE SQL_Latin1_General_CP1_CI_AS,LTRIM(RTRIM(@StatusComment)) COLLATE SQL_Latin1_General_CP1_CI_AS,@LastChanged,LTRIM(RTRIM(@UserID)) COLLATE SQL_Latin1_General_CP1_CI_AS
	END

	--Set Output filter to include only input sent in during end selections
	SET @OutputFilter = (SELECT DISTINCT STUFF((SELECT ',' + CONVERT(varchar,FinancialBatchHistoryID) AS [text()]
		FROM (SELECT FinancialBatchHistoryID FROM AI.FinancialBatchHistory WHERE StatusCode = 'New') t
	FOR XML PATH('')
	), 1, 1, '' ))

	IF EXISTS (SELECT object_id FROM tempdb.sys.tables WHERE name LIKE '##BatchInstanceDetails%') DROP TABLE ##BatchInstanceDetails
	
	--Validations
	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t LEFT JOIN Employee.Employee e ON e.EmployeeCode = t.EmployeeCode WHERE StatusCode = 'New' AND e.EmployeeCode IS NULL)
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Employee does not yet exist'
			WHERE FinancialBatchHistoryID IN (SELECT t.FinancialBatchHistoryID FROM AI.FinancialBatchHistory t LEFT JOIN Employee.Employee e ON e.EmployeeCode = t.EmployeeCode WHERE StatusCode = 'New' AND e.EmployeeCode IS NULL)
				AND StatusCode = 'New'
		END

	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t LEFT JOIN Batch.BatchTemplate b ON b.Code = t.BatchTemplateCode WHERE StatusCode = 'New' AND b.Code IS NULL)
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Batch Template Code does not yet exist'
			WHERE FinancialBatchHistoryID IN (SELECT t.FinancialBatchHistoryID FROM AI.FinancialBatchHistory t LEFT JOIN Batch.BatchTemplate b ON b.Code = t.BatchTemplateCode WHERE StatusCode = 'New' AND b.Code IS NULL)
				AND StatusCode = 'New'
		END

	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t LEFT JOIN Batch.BatchItem b ON LEFT(RIGHT(b.BatchHierarchy,(LEN(t.BatchItemCode) + LEN(t.BatchItemType) + 1)),(LEN(t.BatchItemType) + 1)) = t.BatchItemCode LEFT JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = b.BatchTemplateID AND bt.Code = t.BatchTemplateCode WHERE StatusCode = 'New' AND b.BatchHierarchy IS NULL)
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Batch Item Code does not yet exist'
			WHERE FinancialBatchHistoryID IN (SELECT FinancialBatchHistoryID FROM AI.FinancialBatchHistory t LEFT JOIN Batch.BatchItem b ON LEFT(RIGHT(b.BatchHierarchy,(LEN(t.BatchItemCode) + LEN(t.BatchItemType) + 1)),(LEN(t.BatchItemCode))) = t.BatchItemCode LEFT JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = b.BatchTemplateID AND bt.Code = t.BatchTemplateCode WHERE StatusCode = 'New' AND b.BatchHierarchy IS NULL)
				AND StatusCode = 'New'
		END

	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t WHERE ISNULL(Value,'') = '')
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Value is either blank or NULL'
			WHERE FinancialBatchHistoryID IN (SELECT t.FinancialBatchHistoryID FROM AI.FinancialBatchHistory t WHERE ISNULL(Value,'') = '')
				AND StatusCode = 'New'
		END

	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t WHERE LineType NOT IN ('Earning','Deduction','CoContribution','FringeBenefit','Provision','Additional','PvtContribution','Leave'))
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Line Type Invalid (Valid values = Earning, Deduction, CoContribution, FringeBenefit, Provision, Additional, PvtContribution, Leave)'
			WHERE FinancialBatchHistoryID IN (SELECT t.FinancialBatchHistoryID FROM AI.FinancialBatchHistory t WHERE LineType NOT IN ('Earning','Deduction','CoContribution','FringeBenefit','Provision','Additional','PvtContribution','Medical','Leave'))
				AND StatusCode = 'New'
		END
	
	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t WHERE BatchItemType NOT IN ('Fixed','Amount','Balance','Units','UnitsCapture','Adjustment'))
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Batch Item Type Invalid (Valid Values = Fixed, Amount, Balance, Units, UnitsCapture, Adjustment)'
			WHERE FinancialBatchHistoryID IN (SELECT t.FinancialBatchHistoryID FROM AI.FinancialBatchHistory t WHERE BatchItemType NOT IN ('Fixed','Amount','Balance','Units','UnitsCapture','Adjustment'))
				AND StatusCode = 'New'
		END

	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t WHERE ((BatchItemType IN ('Fixed','Amount','Balance','Units','UnitsCapture') AND LineType IN ('Leave')) OR (BatchItemType NOT IN ('Fixed','Amount','Balance','Units','UnitsCapture') AND LineType NOT IN ('Leave'))))
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Line Type and Batch Item Type do not correspond (Adjustment type can only be used with a Leave line type)'
			WHERE FinancialBatchHistoryID IN (SELECT t.FinancialBatchHistoryID FROM AI.FinancialBatchHistory t WHERE ((BatchItemType IN ('Fixed','Amount','Balance','Units','UnitsCapture') AND LineType IN ('Leave')) OR (BatchItemType NOT IN ('Fixed','Amount','Balance','Units','UnitsCapture') AND LineType NOT IN ('Leave')))
				AND StatusCode = 'New')
		END

	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t INNER JOIN Employee.Employee e ON e.EmployeeCode = t.EmployeeCode INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID LEFT JOIN Company.CompanyRule cr ON cr.CompanyRuleID = er.CompanyRuleID WHERE StatusCode = 'New' AND cr.CompanyRuleCode <> t.CompanyRule)
		BEGIN
			UPDATE AI.FinancialBatchHistory
			SET StatusCode = 'Failed'
				,StatusComment = 'Failed: Employee does not exist in the specified company rule'
			WHERE FinancialBatchHistoryID IN (SELECT FinancialBatchHistoryID FROM AI.FinancialBatchHistory t INNER JOIN Employee.Employee e ON e.EmployeeCode = t.EmployeeCode INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID LEFT JOIN Company.CompanyRule cr ON cr.CompanyRuleID = er.CompanyRuleID WHERE StatusCode = 'New' AND cr.CompanyRuleCode <> t.CompanyRule)
		END
	


	--If there are still valid records, continue with inserts
	IF EXISTS (SELECT * FROM AI.FinancialBatchHistory WHERE StatusCode = 'New')
	BEGIN
	CREATE TABLE ##BatchInstanceDetails
	(
		InstanceDetailsID int IDENTITY(1,1) PRIMARY KEY
		,ProductCode varchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		,BatchTemplateCode varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		,Company varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		,CompanyRule varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		,PayRun varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)
	

	INSERT INTO ##BatchInstanceDetails
	SELECT DISTINCT t.ProductCode
		,t.BatchTemplateCode
		,ISNULL(t.Company,c.CompanyCode)
		,ISNULL(t.CompanyRule,cr.CompanyRuleCode)
		,ISNULL(t.PayRun,pr.Code)
	FROM AI.FinancialBatchHistory t
		INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode, TerminationDate ORDER BY TerminationDate) AS RwNumber ,* FROM Employee.Employee) e WHERE RwNumber = 1) e ON e.EmployeeCode = t.EmployeeCode
		INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID
		INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID
		INNER JOIN Company.CompanyRuleLivePeriod cr ON cr.CompanyRuleID = er.CompanyRuleID
		INNER JOIN Company.PayRunDef pr ON er.CompanyRuleID = pr.CompanyRuleID AND MainPayRunDef = 1
	WHERE t.StatusCode = 'New'


	DECLARE @CurrentTemplateCode varchar(15)
	,@CurrentCompany varchar(15)
	,@CurrentProductCode varchar(15)


	--Loop to create different batch instances based on product and batch templates
	WHILE (SELECT TOP 1 BatchTemplateCode FROM ##BatchInstanceDetails ORDER BY BatchTemplateCode, Company) IS NOT NULL
		BEGIN
	
	SET @CurrentTemplateCode = (SELECT TOP 1 BatchTemplateCode FROM ##BatchInstanceDetails ORDER BY BatchTemplateCode, Company)
	SET @CurrentCompany = (SELECT TOP 1 Company FROM ##BatchInstanceDetails ORDER BY BatchTemplateCode, Company)
	SET @CurrentProductCode = (SELECT TOP 1 ProductCode FROM ##BatchInstanceDetails ORDER BY BatchTemplateCode, Company)
	SET @BatchVersion = 1 + (SELECT ISNULL(COUNT(Code),0) FROM Batch.BatchInstance WHERE CONVERT(varchar,GETDATE(),112) = CASE LEN(Code) WHEN 14 THEN LEFT(RIGHT(Code,10),8) WHEN 15 THEN LEFT(RIGHT(Code,11),8) END)

	--IF NOT EXISTS (SELECT * FROM Batch.BatchInstance bi INNER JOIN Batch.BatchTemplate t ON t.BatchTemplateID = bi.BatchTemplateID LEFT JOIN (SELECT TOP 1 * FROM ##BatchInstanceDetails WHERE BatchTemplateCode = @CurrentTemplateCode AND Company = @CurrentCompany) d ON d.BatchTemplateCode = t.Code WHERE d.BatchTemplateCode IS NOT NULL AND bi.ProcessingStatus = 'V' AND LEFT(bi.Code,3) = d.ProductCode)
	--BEGIN
	INSERT INTO Batch.BatchInstance (Code,ShortDescription,LongDescription,Comment,CompanyRule,PayRunDef,ProcessPeriod,BatchTemplateID,BatchInstanceType,ExportOption,DisplayCodes,DisplayCodesOption,VerifyBatch,CreateLines,AllowDuplicate,SkipTerminated,AllowMultipleCompanies,ExcludeFromScheduler,ProcessingStatus,[Action],ErrorMsg,DateCaptured,CapturedBy,DateProcessed,ProcessedBy,[FileName],FileSize,LastChanged,UserID)
	SELECT bid.ProductCode + '_' + CONVERT(varchar,GETDATE(),112) + '_' + CONVERT(varchar,@BatchVersion)
		,bid.BatchTemplateCode + ' ' + bid.ProductCode + CONVERT(varchar,GETDATE(),112)
		,bid.BatchTemplateCode + ' ' + bid.ProductCode + CONVERT(varchar,GETDATE(),112)
		,@CurrentCompany
		,bid.CompanyRule
		,bid.PayRun
		,CONVERT(varchar,EndDate,111)
		,bt.BatchTemplateID
		,'I'
		,NULL
		,NULL
		,NULL
		,1
		,1
		,'W'
		,0
		,1
		,0
		,'V'
		,NULL
		,NULL
		,GETDATE()
		,ProductCode
		,NULL
		,NULL
		,NULL
		,NULL
		,GETDATE()
		,ProductCode
	FROM (SELECT TOP 1 * FROM ##BatchInstanceDetails WHERE BatchTemplateCode = @CurrentTemplateCode AND Company = @CurrentCompany) bid
		INNER JOIN Batch.BatchTemplate bt ON bt.Code = bid.BatchTemplateCode
		INNER JOIN Company.CompanyRuleLivePeriod cr ON cr.CompanyRuleCode = bid.CompanyRule
		INNER JOIN Company.PayRunDef pr ON pr.Code = bid.PayRun AND pr.CompanyRuleID = cr.CompanyRuleID
	--END
	
	--IF NOT EXISTS (SELECT * FROM Batch.BatchInstanceFilter bf INNER JOIN Batch.BatchInstance bi ON bi.BatchInstanceID = bf.BatchInstanceID INNER JOIN Batch.BatchTemplate t ON t.BatchTemplateID = bi.BatchTemplateID INNER JOIN Company.CompanyRule cr ON cr.CompanyRuleID = bf.CompanyRuleID LEFT JOIN (SELECT TOP 1 * FROM ##BatchInstanceDetails WHERE BatchTemplateCode = @CurrentTemplateCode AND Company = @CurrentCompany) d ON d.BatchTemplateCode = t.Code AND d.CompanyRule = cr.CompanyRuleCode WHERE d.CompanyRule IS NOT NULL AND bi.ProcessingStatus = 'V')
	--BEGIN
	
		INSERT INTO Batch.BatchInstanceFilter (BatchInstanceID,CompanyRuleID,PayslipTypeID,TaxYearID,ProcessPeriodID,PayRunDefID,LastChanged,UserID)
		SELECT DISTINCT (SELECT MAX(BatchInstanceID) FROM Batch.BatchInstance) AS BatchInstanceID
			,cr.CompanyRuleID
			,0
			,NULL
			,cr.PayPeriodGenID
			,pr.PayRunDefID
			,GETDATE()
			,bid.ProductCode
		FROM (SELECT * FROM ##BatchInstanceDetails WHERE BatchTemplateCode IN (SELECT TOP 1 BatchTemplateCode FROM ##BatchInstanceDetails WHERE BatchTemplateCode = @CurrentTemplateCode AND Company = @CurrentCompany)) bid
			INNER JOIN Company.CompanyRuleLivePeriod cr ON cr.CompanyRuleCode = bid.CompanyRule
			INNER JOIN Company.Company c ON c.CompanyID = cr.CompanyID AND c.CompanyCode = @CurrentCompany
			INNER JOIN Company.PayRunDef pr ON pr.Code = bid.PayRun AND pr.CompanyRuleID = cr.CompanyRuleID
			INNER JOIN Batch.BatchTemplate bt ON bt.Code = bid.BatchTemplateCode
			INNER JOIN Batch.BatchInstance bi ON bi.BatchTemplateID = bt.BatchTemplateID AND bi.BatchInstanceID = (SELECT MAX(BatchInstanceID) FROM Batch.BatchInstance WHERE ProcessingStatus = 'V')

	--END
		
		
		DELETE FROM ##BatchInstanceDetails WHERE BatchTemplateCode = @CurrentTemplateCode AND Company = @CurrentCompany
	END

	--Insert employees and values to latest batch
	--IF EXISTS (SELECT DISTINCT t.EmployeeCode FROM AI.FinancialBatchHistory t LEFT JOIN Batch.BatchEmployee be ON be.EmployeeCode = t.EmployeeCode AND be.BatchInstanceID IN (SELECT MAX(bi.BatchInstanceID) FROM Batch.BatchInstance bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bi.ProcessingStatus = 'V' AND LEFT(bi.Code,3) = t.ProductCode AND bt.Code = t.BatchTemplateCode) WHERE be.BatchEmployeeID IS NULL AND t.StatusCode = 'New')
	--BEGIN
		INSERT INTO Batch.BatchEmployee (BatchInstanceID,EmployeeCode,DisplayName,EmployeeRuleID,CompanyID,CompanyRuleID,ProcessingStatus,LastChanged,UserID)
		SELECT DISTINCT (SELECT MAX(bi.BatchInstanceID) FROM Batch.BatchInstance bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bi.ProcessingStatus = 'V' AND LEFT(bi.Code,3) = t.ProductCode AND bt.Code = t.BatchTemplateCode 
		AND 
		LEFT(bi.Comment,15) = c.CompanyCode) AS BatchInstanceID
			,t.EmployeeCode
			,ge.DisplayName
			,er.EmployeeRuleID
			,e.CompanyID
			,er.CompanyRuleID
			,'U' AS ProcessingStatus
			,GETDATE()
			,t.ProductCode
		FROM AI.FinancialBatchHistory t
			INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode, TerminationDate ORDER BY TerminationDate) AS RwNumber ,* FROM Employee.Employee) e WHERE RwNumber = 1) e ON e.EmployeeCode = t.EmployeeCode
			INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID
			INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID
			INNER JOIN Entity.GenEntity ge ON ge.GenEntityID = e.GenEntityID
			LEFT JOIN Batch.BatchEmployee be ON be.EmployeeCode = t.EmployeeCode AND be.BatchInstanceID IN (SELECT MAX(bi.BatchInstanceID) FROM Batch.BatchInstance bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bi.ProcessingStatus = 'V' AND LEFT(bi.Code,3) = t.ProductCode AND bt.Code = t.BatchTemplateCode AND LEFT(bi.Comment,15) = c.CompanyCode)
		WHERE be.BatchEmployeeID IS NULL
			AND t.StatusCode = 'New'
	--END

	--IF EXISTS (SELECT * FROM AI.FinancialBatchHistory t WHERE t.StatusCode = 'New')
	--BEGIN
		INSERT INTO Batch.BatchEmployeeField (BatchEmployeeID,PayRunDefID,ProcessPeriodID,PayslipTypeID,BatchItemID,Sequence,Value,RowIndex,ProcessingStatus,Included,Verified,LastChanged,UserID)
		SELECT be.BatchEmployeeID
			,pr.PayRunDefID
			,cr.PayPeriodGenID
			,0 AS PayslipTypeID
			,bi.BatchItemID
			,bi.Sequence
			,t.Value
			,1 AS RowIndex
			,'V' AS ProcessingStatus
			,1 AS Included
			,0 AS Verified
			,GETDATE()
			,t.ProductCode
		FROM AI.FinancialBatchHistory t
			INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode, TerminationDate ORDER BY TerminationDate) AS RwNumber ,* FROM Employee.Employee) e WHERE RwNumber = 1) e ON e.EmployeeCode = t.EmployeeCode
			INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID
			INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID
			INNER JOIN Company.CompanyRuleLivePeriod cr ON cr.CompanyRuleID = er.CompanyRuleID
			INNER JOIN Company.PayRunDef pr ON pr.CompanyRuleID = cr.CompanyRuleID AND pr.Code =  ISNULL(t.PayRun,'MAIN')
			INNER JOIN Batch.BatchTemplate bt ON bt.Code = t.BatchTemplateCode
			INNER JOIN Batch.BatchItem bi ON bi.BatchTemplateID = bt.BatchTemplateID AND LEFT(RIGHT(bi.BatchHierarchy,(LEN(t.BatchItemCode) + LEN(t.BatchItemType) + 1)),(LEN(t.BatchItemCode))) = t.BatchItemCode
			INNER JOIN Batch.BatchEmployee be ON be.EmployeeCode = t.EmployeeCode AND be.BatchInstanceID IN (SELECT MAX(bi.BatchInstanceID) FROM Batch.BatchInstance bi INNER JOIN Batch.BatchTemplate bt ON bt.BatchTemplateID = bi.BatchTemplateID WHERE bi.ProcessingStatus = 'V' AND LEFT(bi.Code,3) = t.ProductCode AND bt.Code = t.BatchTemplateCode AND LEFT(bi.Comment,15) = c.CompanyCode)
		WHERE t.StatusCode = 'New'
	--END
	
	UPDATE AI.FinancialBatchHistory
	SET StatusCode = 'Success'
		,StatusComment = 'Validations Passed: Event records have been moved to the Sage Batch Instance Management for processing'
	WHERE StatusCode = 'New'

	END
	SET @SQL = 'SELECT ProductCode,EmployeeCode,FirstName,LastName,Company,CompanyRule,PayRun,BatchTemplateCode,LineType,BatchItemCode,BatchItemType,Value,StatusCode,StatusComment,LastChanged,UserID FROM AI.FinancialBatchHistory WHERE FinancialBatchHistoryID IN (' + @OutputFilter + ')'
	EXECUTE sp_EXECUTESQL @SQL
END
	ELSE
	BEGIN
	SELECT NULL AS ProductCode, NULL AS EmployeeCode, NULL AS FirstName, NULL AS LastName, NULL AS Company, NULL AS CompanyRule, NULL AS PayRun, NULL AS BatchTemplateCode, NULL AS LineType, NULL AS BatchItemCode, NULL AS BatchItemType, NULL AS Value, 'Failed' AS StatusCode, 'Failed: No parameters passed through' AS StatusComment, GETDATE() AS LastChanged, NULL AS UserID
	END
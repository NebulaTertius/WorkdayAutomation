CREATE PROCEDURE [AI].[EmployeeBatchValidations] @QueueFilter varchar(MAX) = ''
AS

BEGIN TRANSACTION
UPDATE AI.EmployeeQueue SET EventCode = 'Exclude', EventDescription = 'Record manually excluded from automation run' WHERE StatusCode = 'Exclude'
COMMIT

--Create a CASH run per company if none exist
IF EXISTS (SELECT c.CompanyID FROM Company.Company c LEFT JOIN Payroll.PaymentRunDef prd ON prd.CompanyID = c.CompanyID AND prd.PaymentTypeID = 1 WHERE prd.CompanyID IS NULL)
BEGIN
	INSERT INTO Payroll.PaymentRunDef (CompanyID,Code,ShortDescription,LongDescription,PaymentTypeID,PaymentCycleTypeID,Ccy,UserID,LastChanged)
	SELECT c.CompanyID,'CASH','Cash','Cash',1,1,c.CompanyCCY,'Automation',GETDATE() 
		FROM Company.Company c
		LEFT JOIN Payroll.PaymentRunDef prd ON prd.CompanyID = c.CompanyID AND prd.PaymentTypeID = 1
	WHERE prd.CompanyID IS NULL
END

--Create a ACB run per company if none exist
IF EXISTS (SELECT c.CompanyID FROM Company.Company c LEFT JOIN Payroll.PaymentRunDef prd ON prd.CompanyID = c.CompanyID AND prd.PaymentTypeID = 4 WHERE prd.CompanyID IS NULL)
BEGIN
	INSERT INTO Payroll.PaymentRunDef (CompanyID,Code,ShortDescription,LongDescription,PaymentTypeID,PaymentCycleTypeID,Ccy,UserID,LastChanged)
	SELECT c.CompanyID,'ACB','ACB','ACB',4,1,c.CompanyCCY,'Automation',GETDATE() 
		FROM Company.Company c
		LEFT JOIN Payroll.PaymentRunDef prd ON prd.CompanyID = c.CompanyID AND prd.PaymentTypeID = 4
	WHERE prd.CompanyID IS NULL
END



--Limit date ranges to prevent failure on smalldatetime data types
UPDATE AI.EmployeeQueue SET DateJoinedGroup = CONVERT(datetime,'1900-01-01') WHERE ISNULL(DateJoinedGroup,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET DateJoinedGroup = CONVERT(datetime,'2079-06-06') WHERE ISNULL(DateJoinedGroup,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET IDNumberExpiryDate = CONVERT(datetime,'1900-01-01') WHERE ISNULL(IDNumberExpiryDate,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET IDNumberExpiryDate = CONVERT(datetime,'2079-06-06') WHERE ISNULL(IDNumberExpiryDate,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET BirthDate = CONVERT(datetime,'1900-01-01') WHERE ISNULL(BirthDate,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET BirthDate = CONVERT(datetime,'2079-06-06') WHERE ISNULL(BirthDate,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET DateEngaged = CONVERT(datetime,'1900-01-01') WHERE ISNULL(DateEngaged,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET DateEngaged = CONVERT(datetime,'2079-06-06') WHERE ISNULL(DateEngaged,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET TerminationDate = CONVERT(datetime,'1900-01-01') WHERE ISNULL(TerminationDate,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET TerminationDate = CONVERT(datetime,'2079-06-06') WHERE ISNULL(TerminationDate,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET LeaveStartDate = CONVERT(datetime,'1900-01-01') WHERE ISNULL(LeaveStartDate,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET LeaveStartDate = CONVERT(datetime,'2079-06-06') WHERE ISNULL(LeaveStartDate,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET ProbationPeriodEndDate = CONVERT(datetime,'1900-01-01') WHERE ISNULL(ProbationPeriodEndDate,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET ProbationPeriodEndDate = CONVERT(datetime,'2079-06-06') WHERE ISNULL(ProbationPeriodEndDate,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET MedicalStartDate = CONVERT(datetime,'1900-01-01') WHERE ISNULL(MedicalStartDate,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET MedicalStartDate = CONVERT(datetime,'2079-06-06') WHERE ISNULL(MedicalStartDate,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')
UPDATE AI.EmployeeQueue SET TaxStartDate = CONVERT(datetime,'1900-01-01') WHERE ISNULL(TaxStartDate,CONVERT(datetime,'1900-01-01')) < CONVERT(datetime,'1900-01-01')
UPDATE AI.EmployeeQueue SET TaxStartDate = CONVERT(datetime,'2079-06-06') WHERE ISNULL(TaxStartDate,CONVERT(datetime,'2079-06-06')) > CONVERT(datetime,'2079-06-06')


--Change Master Queue table with a find and replace (Current value is AI.EmployeeQueue)
--If the THROW statement does not work with your applicaton, this can be changed to select the error details based on each field required, or by using the RAISE_ERROR statement

--Update fields that have the Word NULL or blank as a value, to be changed to the value NULL(Empty).
--This is done for consistency across the validations, as well as easier readibility of the code
DECLARE @sql NVARCHAR(MAX);
SET @sql = N'';

BEGIN TRY 
	BEGIN TRANSACTION 
		SELECT @sql = @sql+' '+QUOTENAME(name)+' = CASE WHEN '+QUOTENAME(name)+' = ''NULL'' THEN NULL ELSE CASE WHEN '+QUOTENAME(name)+' = '''' THEN NULL ELSE'+QUOTENAME(name)+' END END,'
		FROM sys.columns
		WHERE [object_id] = OBJECT_ID('AI.EmployeeQueue')
		AND system_type_id IN (35,99,167,175,231,239);
		SELECT @sql = N'UPDATE AI.EmployeeQueue SET '+LEFT(@sql, LEN(@sql)-1)+';';
		EXEC sp_executesql @sql;
	COMMIT TRANSACTION 
END TRY 
BEGIN CATCH 
	THROW 
	IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION 
	IF (XACT_STATE()) = 1 COMMIT TRANSACTION 
END CATCH


--Set any NULL(Blank) StatusCodes to N to indicate this as a New record where a default constraint was not applied or it was dropped.
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET StatusCode = 'N', StatusMessage = NULL WHERE StatusCode IS NULL OR StatusCode IN ('On-Hold','Error') COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = NULL, EventDescription = NULL, WarningCode = NULL, WarningMessage = NULL, ErrorCode = NULL, ErrorMessage = NULL COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

-----------------------------------------------------------------------------------------------------------------------------------------
--Apply customer specific defaults or data transformations when inserting to the Queue.
--Otherwise apply these here before validations are run, to have the best possibility for a successful outcome.




--BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET CompanyCode = 'DOS' WHERE StatusCode = 'N' AND CompanyCode = 'Osi' COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH
--BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET RacialGroup = 'A' WHERE StatusCode = 'N' AND RacialGroup = 'N' COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH
--BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET PeriodInMonth = 'L' WHERE StatusCode = 'N' AND PeriodInMonth = 'N' COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH
--BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET TaxStatusCode = 'ST' WHERE StatusCode = 'N' AND TaxStatusCode = 'S' COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

------------------------------------------------------------------------------------------------------------------------------------------


IF EXISTS (SELECT TOP 1 * FROM AI.EmployeeQueue WHERE StatusCode = 'N' AND ISNULL(QueueFilter,'') = @QueueFilter)
BEGIN --(Only starts processes if there are new records in the master queue)


--Determine the event type of the new record. (This can be a risk if the SP is running more than once a day).
--New
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'N', EventDescription = 'New Event' FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND q.EmployeeCode NOT IN (SELECT e.EmployeeCode FROM Employee.Employee e INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID WHERE c.CompanyCode = q.CompanyCode) AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--New & Stop
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'X', EventDescription = 'New With Stop Event' FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND q.EmployeeCode NOT IN (SELECT e.EmployeeCode FROM Employee.Employee e INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID WHERE c.CompanyCode = q.CompanyCode) AND q.TerminationDate IS NOT NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Update
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'U', EventDescription = 'Update Event' FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND q.EmployeeCode IN (SELECT e.EmployeeCode FROM Employee.Employee e INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID WHERE c.CompanyCode = q.CompanyCode) AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Stop
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'S', EventDescription = 'Stop Event' FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND q.TerminationDate IS NOT NULL AND q.EmployeeCode IN (SELECT e.EmployeeCode FROM Employee.Employee e INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID WHERE c.CompanyCode = q.CompanyCode) AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Temporary Stop
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'T', EventDescription = 'Temporary Stop Event'  WHERE StatusCode = 'N' AND UIFStatusCode IN ('MAT','MATERNITY') AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH



--Default values for New Events if NULL
UPDATE AI.EmployeeQueue SET AnnualSalary = 0.0000												WHERE EventCode IN ('N','X') AND AnnualSalary IS NULL
UPDATE AI.EmployeeQueue SET PeriodSalary = 0.0000												WHERE EventCode IN ('N','X') AND PeriodSalary IS NULL
UPDATE AI.EmployeeQueue SET HoursPerPeriod = 162.5300											WHERE EventCode IN ('N','X') AND HoursPerPeriod IS NULL
UPDATE AI.EmployeeQueue SET HoursPerDay = 8.0000												WHERE EventCode IN ('N','X') AND HoursPerDay IS NULL
UPDATE AI.EmployeeQueue SET [Disabled] = CASE WHEN [Disabled] = 'TRUE' THEN 1 ELSE 0 END		WHERE EventCode IN ('N','X') AND [Disabled] IS NOT NULL
UPDATE AI.EmployeeQueue SET ForeignIncome = CASE WHEN ForeignIncome = 'TRUE' THEN 1 ELSE 0 END	WHERE EventCode IN ('N','X') AND ForeignIncome IS NOT NULL
UPDATE AI.EmployeeQueue SET UseWork = CASE WHEN UseWork = 'TRUE' THEN 1 ELSE 0 END				WHERE EventCode IN ('N','X') AND UseWork IS NOT NULL
UPDATE AI.EmployeeQueue SET UsePhysical1 = CASE WHEN UsePhysical1 = 'TRUE' THEN 1 ELSE 0 END	WHERE EventCode IN ('N','X') AND UsePhysical1 IS NOT NULL
UPDATE AI.EmployeeQueue SET UsePostal2 = CASE WHEN UsePostal2 = 'TRUE' THEN 1 ELSE 0 END		WHERE EventCode IN ('N','X') AND UsePostal2 IS NOT NULL


--Update termination reason for update events, if employee is already terminated in the system and no reason has been supplied from source
UPDATE AI.EmployeeQueue SET TerminationReasonCode = tr.Code
FROM AI.EmployeeQueue q 
	INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY emr.EmployeeCode, emr.CompanyID ORDER BY TerminationDate, DateEngaged DESC) RwNo, emr.* FROM Employee.Employee emr) em WHERE em.RwNo = 1) e ON e.EmployeeCode = q.EmployeeCode
	INNER JOIN Employee.TerminationReason tr ON tr.TerminationReasonID = e.TerminationReasonID
WHERE q.TerminationDate IS NOT NULL
	AND q.TerminationReasonCode IS NULL
	AND q.EventCode IN ('U','S','T')


--Set the Mandatory Integration Field Default (These are typically set as a default because the external application cannot send or determine values for these)
--This also includes critical fields where values are mandatory to perform other validations and so that error record are prevented from pass through validations due to ISNULL not being applied to all field checks.

--Create new EntityCode for new events
IF EXISTS (SELECT OID FROM AI.EmployeeQueue WHERE EventCode IN ('N','X') AND StatusCode = 'N' AND EntityCode IS NULL)
BEGIN
	UPDATE AI.EmployeeQueue
	SET EntityCode = 'EC'+EmployeeCode
	WHERE EventCode IN ('N','X') AND StatusCode = 'N' AND EntityCode IS NULL
END

--Company Code
--Already being supplied

--Company Rule Code. Default for new records
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET CompanyRuleCode = (SELECT TOP 1 cr.CompanyRuleCode FROM Company.CompanyRuleLivePeriod cr INNER JOIN Company.Company c ON c.CompanyID = cr.CompanyID WHERE c.CompanyCode = q.CompanyCode ORDER BY StartDate DESC) FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND EventCode IN ('N','X') AND q.CompanyRuleCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Company Rule Code. Latest linking for existing records
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET CompanyRuleCode = cr.CompanyRuleCode FROM AI.EmployeeQueue q INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY emr.EmployeeCode, emr.CompanyID ORDER BY TerminationDate, DateEngaged DESC) RwNo, emr.* FROM Employee.Employee emr) em WHERE em.RwNo = 1) e ON e.EmployeeCode = q.EmployeeCode INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID INNER JOIN Company.CompanyRule cr ON cr.CompanyRuleID = er.CompanyRuleID WHERE StatusCode = 'N' AND EventCode IN ('U','S','T') AND q.CompanyRuleCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH


--Payment Run Def
--Existing employees link
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET PaymentRunDefCode = pmt.Code FROM AI.EmployeeQueue q INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY emr.EmployeeCode, emr.CompanyID ORDER BY TerminationDate, DateEngaged DESC) RwNo, emr.* FROM Employee.Employee emr) em WHERE em.RwNo = 1) e ON e.EmployeeCode = q.EmployeeCode INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID INNER JOIN Payroll.PayslipDef pd ON pd.EmployeeRuleID = er.EmployeeRuleID AND pd.PayRunDefID IN (SELECT PayRunDefID FROM Company.PayRunDef WHERE MainPayRunDef = 1) INNER JOIN Payroll.PaymentRunDef pmt ON pmt.PaymentRunDefID = pd.PaymentRunDefID WHERE StatusCode = 'N' AND EventCode IN ('U','S','T') AND q.PaymentRunDefCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Default for records with banking details
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET PaymentRunDefCode = (SELECT TOP 1 Code FROM Payroll.PaymentRunDef prd INNER JOIN Company.Company c ON c.CompanyID = prd.CompanyID WHERE c.CompanyCode = q.CompanyCode AND prd.PaymentTypeID IN (3,4)) FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND EventCode IN ('N','X') AND q.PaymentRunDefCode IS NULL AND q.AccountNo IS NOT NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH


--Default for records without banking details
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET PaymentRunDefCode = (SELECT TOP 1 Code FROM Payroll.PaymentRunDef prd INNER JOIN Company.Company c ON c.CompanyID = prd.CompanyID WHERE prd.PaymentTypeID = 1 AND c.CompanyCode = q.CompanyCode), AccountHolderRelationship = NULL, AccountName = NULL, BankCode = NULL, BankDescription = NULL, AccountTypeCode = NULL, AccountNo = NULL, BankBranchCode = NULL, BankBranchDescription = NULL, Ccy = NULL FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND EventCode IN ('N','X') AND (q.PaymentRunDefCode IS NULL OR q.PaymentRunDefCode = 'CASH') AND q.AccountNo IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH


--Remuneration Earn Def
--Remuneration Earn Def. Latest linking for existing records
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET RemunerationEarnDefCode = ed.DefCode FROM AI.EmployeeQueue q INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY emr.EmployeeCode, emr.CompanyID ORDER BY TerminationDate, DateEngaged DESC) RwNo, emr.* FROM Employee.Employee emr) em WHERE em.RwNo = 1) e ON e.EmployeeCode = q.EmployeeCode INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID INNER JOIN Payroll.PayslipDef pd ON pd.EmployeeRuleID = er.EmployeeRuleID AND pd.PayRunDefID IN (SELECT PayRunDefID FROM Company.PayRunDef WHERE MainPayRunDef = 1) INNER JOIN Payroll.EarningDef ed ON ed.EarningDefID = pd.RemunerationEarnDefID WHERE StatusCode = 'N' AND EventCode IN ('U','S','T') AND q.RemunerationEarnDefCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Remuneration Earn Def default for new records
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET RemunerationEarnDefCode = (SELECT TOP 1 DefCode FROM Payroll.EarningDef ed INNER JOIN Company.Company c ON c.CompanyID = ed.CompanyID WHERE ed.EarningTypeID = 1 AND c.CompanyCode = q.CompanyCode ORDER BY ed.EarningDefID) FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND EventCode IN ('N','X') AND RemunerationEarnDefCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH


--Leave Policy
--Leave Policy. Latest linking for existing records
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET LeavePolicyCode = lp.Code FROM AI.EmployeeQueue q INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY emr.EmployeeCode, emr.CompanyID ORDER BY TerminationDate, DateEngaged DESC) RwNo, emr.* FROM Employee.Employee emr) em WHERE em.RwNo = 1) e ON e.EmployeeCode = q.EmployeeCode INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID INNER JOIN Leave.EmployeeLeavePolicy elp ON elp.EmployeeRuleID = er.EmployeeRuleID INNER JOIN Leave.LeavePolicy lp ON lp.LeavePolicyID = elp.LeavePolicyID WHERE StatusCode = 'N' AND EventCode IN ('U','S','T') AND q.LeavePolicyCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Leave Policy Default for New Records
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET LeavePolicyCode = (SELECT TOP 1 Code FROM Leave.LeavePolicy lp INNER JOIN Company.Company c ON c.CompanyID = lp.CompanyID WHERE c.CompanyCode = q.CompanyCode ORDER BY lp.LeavePolicyID) FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND EventCode IN ('N','X') AND q.LeavePolicyCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH




--On Hold Events:
--Manual Intervention Validations (Applied after setting the defaults as this could have an influence on these 2 validations)
--Moving
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'M', StatusCode = 'On-Hold', ErrorCode = ISNULL(ErrorCode,'')+'MIR|', ErrorMessage = ISNULL(ErrorMessage,'')+'Hold: Manual Transfer Process Required for move from Company '+'('+c.CompanyCode+') to '+'('+q.CompanyCode+')|', StatusMessage = 'Manual Intervention Required' 
FROM AI.EmployeeQueue q 
	INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY DateEngaged DESC) [RwNumb], * FROM Employee.Employee) eq WHERE eq.RwNumb = 1) e ON e.EmployeeCode = q.EmployeeCode
	INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID
WHERE StatusCode = 'N' AND e.TerminationDate IS NULL AND q.CompanyCode <> c.CompanyCode AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'M', StatusCode = 'On-Hold', ErrorCode = ISNULL(ErrorCode,'')+'MIR|', ErrorMessage = ISNULL(ErrorMessage,'')+'Hold: Manual Transfer Process Required for move from CompanyRule '+'('+cr.CompanyRuleCode+') to '+'('+q.CompanyRuleCode+')|', StatusMessage = 'Manual Intervention Required' 
FROM AI.EmployeeQueue q 
	INNER JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY DateEngaged DESC) [RwNumb], e.*, er.CompanyRuleID FROM Employee.Employee e INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID) eq WHERE eq.RwNumb = 1) e ON e.EmployeeCode = q.EmployeeCode
	INNER JOIN Company.CompanyRule cr ON cr.CompanyRuleID = e.CompanyRuleID
WHERE StatusCode = 'N' AND e.TerminationDate IS NULL AND q.CompanyRuleCode <> cr.CompanyRuleCode AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

--Reinstated
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET EventCode = 'R', StatusCode = 'On-Hold', ErrorCode = ISNULL(ErrorCode,'')+'MIR|', ErrorMessage = ISNULL(ErrorMessage,'')+'Hold: Manual Reinstatment Process Required|', StatusMessage = 'Manual Intervention Required' FROM AI.EmployeeQueue q WHERE StatusCode = 'N' AND q.EmployeeCode IN (SELECT e.EmployeeCode FROM Employee.Employee e INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID WHERE c.CompanyCode = q.CompanyCode AND e.TerminationDate IS NOT NULL) AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH







--Validations based on the Event Types

--Mandatory for all event types
BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Missing Mandatory Field(s)', ErrorCode = 'MCF|', ErrorMessage = ISNULL(ErrorMessage,'')+'EmployeeCode is Mandatory|' WHERE StatusCode NOT IN ('Success') AND ISNULL(EmployeeCode,'') = '' AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Missing Mandatory Field(s)', ErrorCode = 'MCF|', ErrorMessage = ISNULL(ErrorMessage,'')+'Company is Mandatory|' WHERE StatusCode NOT IN ('Success') AND CompanyCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Missing Mandatory Field(s)', ErrorCode = 'MCF|', ErrorMessage = ISNULL(ErrorMessage,'')+'CompanyRule is Mandatory|' WHERE StatusCode NOT IN ('Success') AND CompanyRuleCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Missing Mandatory Field(s)', ErrorCode = 'MCF|', ErrorMessage = ISNULL(ErrorMessage,'')+'PaymentRunDefCode is Mandatory|' WHERE StatusCode NOT IN ('Success') AND PaymentRunDefCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Missing Mandatory Field(s)', ErrorCode = 'MCF|', ErrorMessage = ISNULL(ErrorMessage,'')+'RemunerationEarnDefCode is Mandatory|' WHERE StatusCode NOT IN ('Success') AND RemunerationEarnDefCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH

BEGIN TRY BEGIN TRANSACTION UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Missing Mandatory Field(s)', ErrorCode = 'MCF|', ErrorMessage = ISNULL(ErrorMessage,'')+'LeavePolicy is Mandatory|' WHERE StatusCode NOT IN ('Success') AND LeavePolicyCode IS NULL AND ISNULL(QueueFilter,'') = @QueueFilter COMMIT TRANSACTION END TRY BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION END CATCH


--New Event Validations (Using Dynamic SQL methods)
--Missing Mandatory Fields (These are typically set as per the local legislation in the country)

--Dynamic methods removed due to the complexity required to properly understand this when their is maintenance required.
--DECLARE @dynamicsql nvarchar(max); --Used as the variable which builds up the list of mandatory columns in SimpleNullFields where the IS NULL check is applied.
--DECLARE @SimpleMandatoryFields nvarchar(max);
--DECLARE @SimpleMandatoryFieldsFilters nvarchar(max);
--DECLARE @CustomerRequestedAdditionalFields nvarchar(max);
--DECLARE @CustomerRequestedAdditionalFieldsFilters nvarchar(max);
--DECLARE @ComplexValidations nvarchar(max);
--DECLARE @ComplexValidationsFilters nvarchar(max);

--SET @dynamicsql = N''
--SET @SimpleMandatoryFields = N'
--	''TitleTypeCode'',''Initials'',''FirstName'',''LastName'',''MaritalStatusTypeCode'',''Gender'',''LanguageTypeCode'',''BirthDate'',''TaxStartDate''';
--SET @SimpleMandatoryFieldsFilters = REPLACE(REPLACE(@SimpleMandatoryFields,'''',''),',',' IS NOT NULL OR ')
--SET @ComplexValidations = N'
--	CASE WHEN COALESCE(NationalityCountryCode,PassportCountryCode) IS NULL THEN ''NationalityOrPassportCountryCode|'' ELSE '''' END +
--	CASE WHEN PassportNo IS NOT NULL AND PassportCountryCode IS NULL THEN ''PassportNo without PassportCountrCode|'' ELSE '''' END +
--	CASE WHEN [Disabled] = 1 AND DisabilityTypeCode IS NULL THEN ''DisabilityTypeCode|'' ELSE '''' END +
--	CASE WHEN (SELECT MAX(LicenseModuleID) FROM dbo.LicenseModule WHERE ModuleName IN (''Skills'',''Equity'') AND Licensed = 1) IS NOT NULL AND Gender IS NULL THEN ''Gender|'' ELSE '''' END +
--	CASE WHEN TerminationDate IS NOT NULL AND TerminationReasonCode IS NULL THEN ''TerminationDate without TerminationReasonCode|'' ELSE CASE WHEN TerminationReasonCode IS NOT NULL AND TerminationDate IS NULL THEN ''TerminationReasonCode without TerminationDate|'' ELSE '''' END END +
--	ISNULL(CONVERT(varchar,COALESCE(AnnualSalary,PeriodSalary,RatePerDay,RatePerHour)),''Salary Or Rates|'')';
--SET @ComplexValidationsFilters = N'
--	(COALESCE(NationalityCountryCode,PassportCountryCode) IS NULL) OR 
--	(PassportNo IS NOT NULL AND PassportCountryCode IS NULL) OR
--	([Disabled] = 1 AND DisabilityTypeCode IS NULL) OR
--	((SELECT MAX(LicenseModuleID) FROM dbo.LicenseModule WHERE ModuleName IN (''Skills'',''Equity'') AND Licensed = 1) IS NOT NULL AND Gender IS NULL) OR
--	(TerminationDate IS NOT NULL AND TerminationReasonCode IS NULL) OR 
--	(TerminationReasonCode IS NOT NULL AND TerminationDate IS NULL) OR
--	(COALESCE(AnnualSalary,PeriodSalary,RatePerDay,RatePerHour)IS NULL)
--	AND ISNULL(QueueFilter,'''') = @QueueFilter';

--BEGIN TRY 
--	BEGIN TRANSACTION 
--		SELECT @dynamicsql = @dynamicsql+' CASE WHEN '+name+' IS NULL THEN '''+name+'|'' ELSE '''' END +'
--		FROM sys.columns c
--		WHERE [object_id] = OBJECT_ID('AI.EmployeeQueue')
--		AND c.name IN ('TitleTypeCode','Initials','FirstName','LastName','MaritalStatusTypeCode','Gender','LanguageTypeCode','BirthDate','TaxStartDate')
--		AND ISNULL(QueueFilter,'') = @QueueFilter

--		SELECT @dynamicsql = N'UPDATE AI.EmployeeQueue SET LastChanged = GETDATE(), StatusCode = ''Error'', ErrorCode = ''MMF'', ErrorMessage = ISNULL(ErrorMessage,'''')+''Missing Mandatory Field(s): '+LEFT(@dynamicsql,LEN(@dynamicsql)-1)+@CustomerRequestedAdditionalFields+@ComplexValidations+' WHERE EventCode IN (''N'',''X'') AND StatusCode = ''N'' AND
--			('+@SimpleMandatoryFieldsFilters+' OR '+@CustomerRequestedAdditionalFieldsFilters+' OR '+@ComplexValidationsFilters+') AND ISNULL(QueueFilter,'''') = @QueueFilter;';
--		EXEC sp_executesql @dynamicsql;
--	COMMIT TRANSACTION 
--END TRY 
--BEGIN CATCH 
--	THROW 
--	IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION 
--	IF (XACT_STATE()) = 1 COMMIT TRANSACTION 
--END CATCH


--_________________________________________________________________________________________________________________________________________________
--Address checks

--IF EXISTS (SELECT UseWork FROM AI.EmployeeQueue WHERE ISNULL(UseWork,0) = 1)
--BEGIN
--	--Work Address
--	UPDATE AI.EmployeeQueue
--	SET UnitPostalNumber = ''
--	WHERE UseWork = 1 AND UnitPostalNumber IS NULL
--	UPDATE AI.EmployeeQueue
--	SET Complex = ''
--	WHERE UseWork = 1 AND Complex IS NULL
--	UPDATE AI.EmployeeQueue
--	SET LevelFloor = ''
--	WHERE UseWork = 1 AND LevelFloor IS NULL
--	UPDATE AI.EmployeeQueue
--	SET [Block] = ''
--	WHERE UseWork = 1 AND [Block] IS NULL
--	UPDATE AI.EmployeeQueue
--	SET StreetNumber = ''
--	WHERE UseWork = 1 AND StreetNumber IS NULL
--	UPDATE AI.EmployeeQueue
--	SET StreetFarmName = ''
--	WHERE UseWork = 1 AND StreetFarmName IS NULL
--	UPDATE AI.EmployeeQueue
--	SET SuburbDistrict = ''
--	WHERE UseWork = 1 AND SuburbDistrict IS NULL
--	UPDATE AI.EmployeeQueue
--	SET CityTown = ''
--	WHERE UseWork = 1 AND CityTown IS NULL
--	UPDATE AI.EmployeeQueue
--	SET Province = ''
--	WHERE UseWork = 1 AND Province IS NULL
--	UPDATE AI.EmployeeQueue
--	SET PostalCode = ''
--	WHERE UseWork = 1 AND PostalCode IS NULL
--	UPDATE AI.EmployeeQueue
--	SET CountryCode = ''
--	WHERE UseWork = 1 AND CountryCode IS NULL
--END

--IF EXISTS (SELECT UsePhysical1 FROM AI.EmployeeQueue WHERE ISNULL(UsePhysical1,0) = 1)
--BEGIN
--	--Work Address
--	UPDATE AI.EmployeeQueue
--	SET UnitPostalNumber1 = ''
--	WHERE UsePhysical1 = 1 AND UnitPostalNumber1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET Complex1 = ''
--	WHERE UsePhysical1 = 1 AND Complex1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET LevelFloor1 = ''
--	WHERE UsePhysical1 = 1 AND LevelFloor1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET [Block1] = ''
--	WHERE UsePhysical1 = 1 AND [Block1] IS NULL
--	UPDATE AI.EmployeeQueue
--	SET StreetNumber1 = ''
--	WHERE UsePhysical1 = 1 AND StreetNumber1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET StreetFarmName1 = ''
--	WHERE UsePhysical1 = 1 AND StreetFarmName1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET SuburbDistrict1 = ''
--	WHERE UsePhysical1 = 1 AND SuburbDistrict1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET CityTown1 = ''
--	WHERE UsePhysical1 = 1 AND CityTown1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET Province1 = ''
--	WHERE UsePhysical1 = 1 AND Province1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET PostalCode1 = ''
--	WHERE UsePhysical1 = 1 AND PostalCode1 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET CountryCode1 = ''
--	WHERE UsePhysical1 = 1 AND CountryCode1 IS NULL
--END

--IF EXISTS (SELECT UsePostal2 FROM AI.EmployeeQueue WHERE ISNULL(UsePostal2,0) = 1)
--BEGIN
--	--Work Address
--	UPDATE AI.EmployeeQueue
--	SET UnitPostalNumber2 = ''
--	WHERE UsePostal2 = 1 AND UnitPostalNumber2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET Complex2 = ''
--	WHERE UsePostal2 = 1 AND Complex2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET LevelFloor2 = ''
--	WHERE UsePostal2 = 1 AND LevelFloor2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET [Block2] = ''
--	WHERE UsePostal2 = 1 AND [Block2] IS NULL
--	UPDATE AI.EmployeeQueue
--	SET StreetNumber2 = ''
--	WHERE UsePostal2 = 1 AND StreetNumber2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET StreetFarmName2 = ''
--	WHERE UsePostal2 = 1 AND StreetFarmName2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET SuburbDistrict2 = ''
--	WHERE UsePostal2 = 1 AND SuburbDistrict2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET CityTown2 = ''
--	WHERE UsePostal2 = 1 AND CityTown2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET Province2 = ''
--	WHERE UsePostal2 = 1 AND Province2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET PostalCode2 = ''
--	WHERE UsePostal2 = 1 AND PostalCode2 IS NULL
--	UPDATE AI.EmployeeQueue
--	SET CountryCode2 = ''
--	WHERE UsePostal2 = 1 AND CountryCode2 IS NULL
--END
--_________________________________________________________________________________________________________________________________________________


--New Events Mandatory Validations
BEGIN TRY 
BEGIN TRANSACTION 
UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Missing Mandatory Field(s)', ErrorCode = ISNULL(ErrorCode,'')+'MMF|', ErrorMessage = ISNULL(ErrorMessage,'')+'Missing Mandatory Fields: '
	+ CASE WHEN TitleTypeCode IS NULL THEN 'TitleTypeCode|' ELSE '' END
	+ CASE WHEN Initials IS NULL THEN 'Initials|' ELSE '' END
	+ CASE WHEN FirstName IS NULL THEN 'FirstName|' ELSE '' END
	+ CASE WHEN LastName IS NULL THEN 'LastName|' ELSE '' END
	+ CASE WHEN MaritalStatusTypeCode IS NULL AND NationalityCountryCode = 'ZAF' THEN 'MaritalStatusTypeCode|' ELSE '' END
	+ CASE WHEN Gender IS NULL THEN 'Gender|' ELSE '' END
	+ CASE WHEN LanguageTypeCode IS NULL THEN 'LanguageType|' ELSE '' END 
	+ CASE WHEN RacialGroup IS NULL AND CompanyCode IN (SELECT CompanyCode FROM Company.Company WHERE TaxCountryCode IN ('ZAF')) THEN 'RacialGroup|' ELSE '' END
	+ CASE WHEN [Disabled] = 1 AND DisabilityTypeCode IS NULL THEN 'DisabilityTypeCode|' ELSE '' END 
	+ CASE WHEN (SELECT MAX(LicenseModuleID) FROM dbo.LicenseModule WHERE ModuleName IN ('Skills','Equity') AND Licensed = 1) IS NOT NULL AND Gender IS NULL THEN 'Gender|' ELSE '' END 
	+ CASE WHEN CONVERT(varchar,BirthDate,112) IS NULL THEN 'BirthDate|' ELSE '' END
	+ CASE WHEN CONVERT(varchar,DateEngaged,112) IS NULL THEN 'DateEngaged|' ELSE '' END 
	+ CASE WHEN CONVERT(varchar,DateJoinedGroup,112) IS NULL THEN 'DateJoinedGroup|' ELSE '' END
	+ CASE WHEN CONVERT(varchar,LeaveStartDate,112) IS NULL THEN 'LeaveStartDate|' ELSE '' END
	+ CASE WHEN CONVERT(varchar,HoursPerPeriod) IS NULL THEN 'HoursPerPeriod|' ELSE '' END
	+ CASE WHEN CONVERT(varchar,HoursPerDay) IS NULL THEN 'HoursPerDay|' ELSE '' END
	+ CASE WHEN CONVERT(varchar,COALESCE(AnnualSalary,PeriodSalary,RatePerDay,RatePerHour)) IS NULL THEN 'No Salary Or Rates|' ELSE '' END
	+ CASE WHEN UIFStatusCode IS NULL THEN 'UIFStatusCode|' ELSE '' END
	+ CASE WHEN TaxStatusCode IS NULL THEN 'TaxStatusCode|' ELSE '' END
	+ CASE WHEN CONVERT(varchar,TaxStartDate,112) IS NULL THEN 'TaxStartDate|' ELSE '' END
	+ CASE WHEN TaxCalculation IS NULL THEN 'TaxCalculation|' ELSE '' END
FROM AI.EmployeeQueue q
WHERE EventCode IN ('N','X') AND StatusCode = 'N' AND
	--Employee names and general details
	(TitleTypeCode IS NULL 
	OR FirstName IS NULL 
	OR LastName IS NULL 
	OR (MaritalStatusTypeCode IS NULL AND NationalityCountryCode = 'ZAF')
	OR Gender IS NULL 
	OR LanguageTypeCode IS NULL 
	OR ([Disabled] = 1 AND DisabilityTypeCode IS NULL) 
	OR ((SELECT MAX(LicenseModuleID) FROM dbo.LicenseModule WHERE ModuleName IN ('Skills','Equity') AND Licensed = 1) IS NOT NULL AND Gender IS NULL) 
	OR (RacialGroup IS NULL AND CompanyCode IN (SELECT CompanyCode FROM Company.Company WHERE TaxCountryCode IN ('ZAF')))
	--Mandatory Date validations
	OR BirthDate IS NULL 
	OR DateEngaged IS NULL 
	OR UIFStatusCode IS NULL 
	OR DateJoinedGroup IS NULL 
	OR LeaveStartDate IS NULL 
	--Salary and Working Durations
	OR COALESCE(HoursPerPeriod,HoursPerDay) IS NULL
	OR COALESCE(AnnualSalary,PeriodSalary,RatePerDay,RatePerHour) IS NULL 
	--Tax Related Fields
	OR TaxStatusCode IS NULL 
	OR TaxStartDate IS NULL 
	OR TaxCalculation IS NULL)
	AND ISNULL(QueueFilter,'') = @QueueFilter 
COMMIT TRANSACTION 
END TRY 
BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION 
END CATCH



--Value validations with no match in Sage.
--Applies to all events


--*Note that Status Code might need to stay N during the checks, so that all messages can be added in 1 check.

BEGIN TRY 
BEGIN TRANSACTION 
UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Invalid Data', ErrorCode = ISNULL(ErrorCode,'')+'NMD|', ErrorMessage = ISNULL(ErrorMessage,'')+'No Data Match: '
	+ CASE WHEN CompanyCode NOT IN (SELECT CompanyCode FROM Company.Company WHERE [Status] = 'A') THEN 'CompanyCode('+CompanyCode+')|' ELSE '' END
	+ CASE WHEN CompanyRuleCode NOT IN (SELECT CompanyRuleCode FROM Company.CompanyRule WHERE [Status] = 'A') THEN 'CompanyRuleCode('+CompanyRuleCode+')|' ELSE '' END
	+ CASE WHEN PaymentRunDefCode NOT IN (SELECT Code FROM Payroll.PaymentRunDef) THEN 'PaymentRunDefCode('+PaymentRunDefCode+')|' ELSE '' END
	+ CASE WHEN RemunerationEarnDefCode NOT IN (SELECT DefCode FROM Payroll.EarningDef WHERE [Status] = 'A') THEN 'PeriodSalaryEarningDef('+RemunerationEarnDefCode+')|' ELSE '' END
	+ CASE WHEN LeavePolicyCode NOT IN (SELECT Code FROM Leave.LeavePolicy) THEN 'LeavePolicy('+LeavePolicyCode+')|' ELSE '' END
	+ CASE WHEN MaritalStatusTypeCode NOT IN (SELECT Code FROM Entity.MaritalStatusType WHERE [Status] = 'A') AND NationalityCountryCode = 'ZAF' THEN 'MaritalStatus('+MaritalStatusTypeCode+')|' ELSE '' END
	+ CASE WHEN LanguageTypeCode NOT IN (SELECT LanguageCode FROM Entity.LanguageType WHERE [Status] = 'A') THEN 'LanguageType('+LanguageTypeCode+')|' ELSE '' END
	+ CASE WHEN NationalityCountryCode NOT IN (SELECT CountryCode FROM Entity.Country) THEN 'NationalityCountryCode('+NationalityCountryCode+')|' ELSE '' END
	+ CASE WHEN PassportCountryCode NOT IN (SELECT CountryCode FROM Entity.Country) THEN 'PassportCountryCode('+PassportCountryCode+')|' ELSE '' END
	+ CASE WHEN DisabilityTypeCode NOT IN (SELECT Code FROM Entity.DisabilityType WHERE [Status] = 'A') THEN 'DisabilityTypeCode('+DisabilityTypeCode+')|' ELSE '' END
	+ CASE WHEN Gender NOT IN ('M','F') THEN 'Gender('+Gender+') can only be M or F|' ELSE '' END
	+ CASE WHEN UIFStatusCode NOT IN (SELECT Code FROM Employee.UIFStatus WHERE [Status] = 'A') THEN 'UIFStatusCode('+UIFStatusCode+')|' ELSE '' END
	+ CASE WHEN TerminationReasonCode NOT IN (SELECT Code FROM Employee.TerminationReason WHERE [Status] = 'A') THEN 'TerminationReasonCode('+TerminationReasonCode+')|' ELSE '' END
	+ CASE WHEN TaxStatusCode NOT IN (SELECT Code FROM Employee.TaxStatus WHERE [Status] = 'A') THEN 'TaxStatusCode('+TaxStatusCode+')|' ELSE '' END
	+ CASE WHEN TaxCalculation NOT IN ('A','N','G') THEN 'TaxCalculation('+TaxCalculation+')|' ELSE '' END
FROM AI.EmployeeQueue q
WHERE StatusCode = 'N' AND
	((CompanyCode NOT IN (SELECT CompanyCode FROM Company.Company WHERE [Status] = 'A'))
	OR (CompanyRuleCode NOT IN (SELECT CompanyRuleCode FROM Company.CompanyRule WHERE [Status] = 'A'))
	OR (PaymentRunDefCode NOT IN (SELECT Code FROM Payroll.PaymentRunDef))
	OR (RemunerationEarnDefCode NOT IN (SELECT DefCode FROM Payroll.EarningDef WHERE [Status] = 'A'))
	OR (LeavePolicyCode NOT IN (SELECT Code FROM Leave.LeavePolicy))
	OR ((MaritalStatusTypeCode NOT IN (SELECT Code FROM Entity.MaritalStatusType WHERE [Status] = 'A')) AND NationalityCountryCode = 'ZAF')
	OR (LanguageTypeCode NOT IN (SELECT LanguageCode FROM Entity.LanguageType WHERE [Status] = 'A')) 
	OR (NationalityCountryCode NOT IN (SELECT CountryCode FROM Entity.Country))
	OR (PassportCountryCode NOT IN (SELECT CountryCode FROM Entity.Country))
	OR (DisabilityTypeCode NOT IN (SELECT Code FROM Entity.DisabilityType WHERE [Status] = 'A'))
	OR (Gender NOT IN ('M','F'))
	OR (UIFStatusCode NOT IN (SELECT Code FROM Employee.UIFStatus WHERE [Status] = 'A'))
	OR (TerminationReasonCode NOT IN (SELECT Code FROM Employee.TerminationReason WHERE [Status] = 'A'))
	OR (TaxStatusCode NOT IN (SELECT Code FROM Employee.TaxStatus WHERE [Status] = 'A'))
	OR (TaxCalculation NOT IN ('A','N','G'))) 
	AND ISNULL(QueueFilter,'') = @QueueFilter
COMMIT TRANSACTION 
END TRY 
BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION 
END CATCH


--Bad Data validations

--Note: Add checks for COmpany and COmpany Rule mismatch, as well as other like Earning Def and Main Payslip Def Mismatch, and checks if Payment type is part of the company rule etc.

BEGIN TRY 
BEGIN TRANSACTION 
UPDATE AI.EmployeeQueue SET StatusCode = 'Error', StatusMessage = 'Invalid Data', ErrorCode = ISNULL(ErrorCode,'')+'NMD|', ErrorMessage = ISNULL(ErrorMessage,'')+'Bad Data: '
	+ CASE WHEN TerminationDate IS NOT NULL AND TerminationReasonCode IS NULL THEN 'TerminationDate without TerminationReasonCode|' ELSE CASE WHEN TerminationReasonCode IS NOT NULL AND TerminationDate IS NULL THEN 'TerminationReasonCode without TerminationDate|' ELSE '' END END 
	+ CASE WHEN COALESCE(NationalityCountryCode,PassportCountryCode) IS NULL THEN 'NationalityOrPassportCountryCode|' ELSE '' END 
	+ CASE WHEN PassportNo IS NOT NULL AND PassportCountryCode IS NULL THEN 'PassportNo without PassportCountrCode|' ELSE '' END 
	+ CASE WHEN (BirthDate IS NOT NULL AND IDNumber IS NOT NULL) AND RIGHT(CONVERT(varchar,YEAR(BirthDate)),2) + CONVERT(varchar,MONTH(BirthDate)) + RIGHT('00' + CONVERT(varchar,DAY(BirthDate)),2) <> LEFT(IDNumber,6) THEN 'BirthDate & IDNumber differ|' ELSE '' END
	+ CASE WHEN PassportNo IS NOT NULL AND PassportCountryCode IS NULL THEN 'PassportNo without PassportCountrCode|' ELSE '' END
	+ CASE WHEN DateJoinedGroup > DateEngaged THEN 'DateJoinedGroup cannot be greater than DateEngaged|' ELSE '' END
	+ CASE WHEN LeaveStartDate < DateJoinedGroup THEN 'LeaveStartDate cannot be less than DateJoinedGroup|' ELSE '' END
	+ CASE WHEN TaxStartDate < DateEngaged THEN 'TaxStartDate cannot be less than DateEngaged|' ELSE '' END
	+ CASE WHEN TaxStartDate < (SELECT DISTINCT CompanyTaxYearStart FROM Company.CompanyRuleLivePeriod cr WHERE cr.CompanyRuleCode = q.CompanyRuleCode) THEN 'TaxStartDate cannot be less than the active period CompanyTaxYearStart|' ELSE '' END
FROM AI.EmployeeQueue q --Check when there is more clear data that the join aligns with the Update
WHERE StatusCode = 'N' AND
	((COALESCE(NationalityCountryCode,PassportCountryCode) IS NULL) 
	OR (PassportNo IS NOT NULL AND PassportCountryCode IS NULL) 
	OR (TerminationDate IS NOT NULL AND TerminationReasonCode IS NULL) 
	OR (TerminationReasonCode IS NOT NULL AND TerminationDate IS NULL)) 
	AND ISNULL(QueueFilter,'') = @QueueFilter	
COMMIT TRANSACTION 
END TRY 
BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION 
END CATCH




--Warning Validations
--Possible duplicate employee with different employee code
BEGIN TRY 
BEGIN TRANSACTION 
UPDATE AI.EmployeeQueue SET StatusCode = 'Warning', StatusMessage = 'Possible duplicate employee', WarningCode = ISNULL(WarningCode,'')+'DUP|', WarningMessage = ISNULL(WarningMessage,'')+'Possible duplicate of Employee Code: ' + e.EmployeeCode
	 --  SELECT q.EmployeeCode
		--,e.EmployeeCode [ExistingEmployeeCode]
		--,q.CompanyCode
		--,(SELECT CompanyCode FROM Company.Company WHERE CompanyID = e.CompanyID) [ExistingCompanyCode]
		--,q.DateEngaged
		--,e.DateEngaged [ExistingDateEngaged]
		--,q.TerminationDate
		--,e.TerminationDate [ExistingTerminationDate]
		--,q.IDNumber
		--,e.IDNumber [ExistingIDNumber]
		--,q.FirstName + ' ' + q.LastName [FullName]
		--,e.FirstName + ' ' + e.LastName [ExistingFullName]
	FROM AI.EmployeeQueue q 
		LEFT JOIN (SELECT * FROM 
			(SELECT ROW_NUMBER() OVER (PARTITION BY emr.EmployeeCode, emr.CompanyID ORDER BY TerminationDate, DateEngaged DESC) RwNo, emr.EmployeeCode, emr.DateEngaged, emr.TerminationDate, emr.CompanyID, ge.* 
			FROM Employee.Employee emr INNER JOIN Entity.GenEntity ge ON ge.GenEntityID = emr.GenEntityID) em 
			WHERE em.RwNo = 1) e ON e.EmployeeCode <> q.EmployeeCode 
					AND (e.IDNumber = ISNULL(q.IDNumber,'')
						OR (e.FirstName = ISNULL(q.FirstName,'') AND e.LastName = ISNULL(q.LastName,''))
						)
	WHERE e.EmployeeCode IS NOT NULL
		AND q.StatusCode = 'N'
		AND q.EventCode IN ('N','X')
		AND ISNULL(QueueFilter,'') = @QueueFilter
COMMIT TRANSACTION 
END TRY 
BEGIN CATCH THROW IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION IF (XACT_STATE()) = 1 COMMIT TRANSACTION 
END CATCH


--Other validations
--Entity Code and ID Number do not match
--BEGIN TRAN
--UPDATE AI.EmployeeQueue
--SET StatusCode = 'W'
--	,StatusMessage = ISNULL(StatusMessage,'')+'ID Number and Entity Code mismatch'
--FROM AI.EmployeeQueue q INNER JOIN Employee.Employee e ON e.EmployeeCode = q.EmployeeCode INNER JOIN Entity.GenEntity ge ON ge.GenEntityID = e.GenEntityID
--WHERE ((q.EntityCode = ge.EntityCode AND q.IDNumber <> ge.IDNumber)
--	OR (q.IDNumber = ge.IDNumber AND q.EntityCode <> ge.EntityCode))
--	AND ISNULL(QueueFilter,'') = @QueueFilter
--COMMIT TRAN
--Needs to be tested to check the outcome for the OR mismatch type and how to handle NULL IDNumber record mismatches

END --(End of processes if there are no new records in the master queue)
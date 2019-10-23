CREATE PROCEDURE AI.LeaveBalanceValidations
AS

--Validations on Leave Balance Queue
--Employee has a history terminated status
UPDATE AI.LeaveBalanceQueue 
SET 
	--StatusCode = 'Warning', 
	StatusMessage = ISNULL(StatusMessage,'')+'Employee terminated in previous period|', WarningCode = ISNULL(WarningCode,'')+'Terminated|', WarningMessage = ISNULL(WarningMessage,'')+'Terminated employee ('+q.EmployeeCode+') in company ('+q.CompanyCode+') is included for processing|'
FROM AI.LeaveBalanceQueue q
	INNER JOIN AI.EmployeeContractSequence i ON i.EmployeeCode = q.EmployeeCode AND i.ContractSequenceByEmployeeCode = 1 
	INNER JOIN Company.Company c ON c.CompanyID = i.CompanyID
WHERE i.EmployeeStatusID IN (3)
	AND StatusCode = 'New'


--Result will be a negative balance
UPDATE AI.LeaveBalanceQueue 
SET 
	--StatusCode = 'Warning', 
	StatusMessage = ISNULL(StatusMessage,'')+'Balance will result in a negative|', WarningCode = ISNULL(WarningCode,'')+'Negative|', WarningMessage = ISNULL(WarningMessage,'')+'Value for Employee ('+q.EmployeeCode+') in company ('+q.CompanyCode+') will result in a negative|'
FROM AI.LeaveBalanceQueue q
WHERE q.UnitOverride < 0
	AND StatusCode = 'New'


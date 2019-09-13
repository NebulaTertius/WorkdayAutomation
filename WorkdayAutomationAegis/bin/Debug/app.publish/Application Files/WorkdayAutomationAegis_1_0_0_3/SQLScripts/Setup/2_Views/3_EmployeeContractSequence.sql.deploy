CREATE VIEW AI.EmployeeContractSequence
AS

SELECT *
FROM
(SELECT COUNT(e.EmployeeCode) OVER (PARTITION BY e.EmployeeCode) [ContractCountByEmployeeCode]
	,ROW_NUMBER() OVER (PARTITION BY e.EmployeeCode ORDER BY e.TerminationDate, e.DateEngaged DESC) [ContractSequenceByEmployeeCode] 
	,e.EmployeeID
	,e.EmployeeCode
	,e.EmployeeStatusID
	,e.CompanyID
	,er.CompanyRuleID
	,e.DateJoinedGroup
	,e.LeaveStartDate
	,e.DateEngaged
	,e.TerminationDate
	,e.TerminationReasonID
	,ge.GenEntityID
	,ge.EntityCode
	,ge.IDNumber
	,ge.PassportNo
	,ge.FirstName
	,ge.LastName
	,ge.KnownAsName
	,ge.SecondName
	,ge.OtherNames
	,ge.MaidenName
	,ge.BirthDate
	,ge.TitleTypeID
FROM Employee.Employee e
	INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID
	INNER JOIN Entity.GenEntity ge ON ge.GenEntityID = e.GenEntityID
) ev

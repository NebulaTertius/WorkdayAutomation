CREATE PROCEDURE [AI].[ProcessEmployeeQueue] @QueueFilter varchar(MAX) = ''
AS

--Remove previously run successful records
INSERT INTO AI.EmployeeQueueHistory SELECT * FROM AI.EmployeeQueue WHERE StatusCode IN ('Success') AND ISNULL(QueueFilter,'') = @QueueFilter
DELETE FROM AI.EmployeeQueue WHERE StatusCode IN ('Success') AND ISNULL(QueueFilter,'') = @QueueFilter


--Instances
--New Events
IF EXISTS (SELECT TOP 1 OID FROM AI.EmployeeQueue WHERE StatusCode = 'N' AND EventCode IN ('N','X') AND ISNULL(QueueFilter,'') = @QueueFilter)
BEGIN


IF NOT EXISTS (SELECT * FROM TakeOn.EmployeeTakeOnInstance WHERE LEFT(Code,15) = (SELECT 'NEW_' + RIGHT(CONVERT(varchar,GETDATE(),112),6) + REPLACE(LEFT(CONVERT(varchar,GETDATE(),114),5),':','')) AND TakeOnStatus = 2)
BEGIN
	INSERT INTO TakeOn.EmployeeTakeOnInstance (TakeOnScriptID,Code,ShortDescription,LongDescription,Comment,[Status],UpdateOption,TakeOnStatus,CreatedBy,DateCreated,UserID,LastChanged)
	SELECT 1
		,(SELECT 'NEW_' + RIGHT(CONVERT(varchar,GETDATE(),112),6) + REPLACE(LEFT(CONVERT(varchar,GETDATE(),114),5),':',''))
		,'AI_New_'+RIGHT(CONVERT(varchar,GETDATE(),112),4)+'_'+LEFT(CONVERT(varchar,GETDATE(),114),5)
		,'AI_New_'+RIGHT(CONVERT(varchar,GETDATE(),112),4)+'_'+LEFT(CONVERT(varchar,GETDATE(),114),5)
		,'Source Files: ' + STUFF((SELECT '|' + REPLACE(SUBSTRING(QueueComment,9,11),'-','_') AS [text()]
			FROM AI.EmployeeQueue 
			WHERE StatusCode = 'N'
			FOR XML PATH('')
			),1,1,''
			) [Comment]
		,'A'
		,'U' --Create/Update
		,2
		,'AUTO'
		,GETDATE()
		,'AUTO'
		,GETDATE()
END

END


--Existing Event Records
IF EXISTS (SELECT TOP 1 OID FROM AI.EmployeeQueue WHERE StatusCode = 'N' AND EventCode NOT IN ('N','X') AND ISNULL(QueueFilter,'') = @QueueFilter)
BEGIN

IF NOT EXISTS (SELECT * FROM TakeOn.EmployeeTakeOnInstance WHERE LEFT(Code,15) = (SELECT 'UPD_' + RIGHT(CONVERT(varchar,GETDATE(),112),6) + REPLACE(LEFT(CONVERT(varchar,GETDATE(),114),5),':','')) AND TakeOnStatus = 2)

BEGIN
	INSERT INTO TakeOn.EmployeeTakeOnInstance (TakeOnScriptID,Code,ShortDescription,LongDescription,Comment,[Status],UpdateOption,TakeOnStatus,CreatedBy,DateCreated,UserID,LastChanged)
	SELECT 1
		,(SELECT 'UPD_' + RIGHT(CONVERT(varchar,GETDATE(),112),6) + REPLACE(LEFT(CONVERT(varchar,GETDATE(),114),5),':',''))
		,'AI_Updated_'+RIGHT(CONVERT(varchar,GETDATE(),112),4)+'_'+LEFT(CONVERT(varchar,GETDATE(),114),5)
		,'AI_Updated_'+RIGHT(CONVERT(varchar,GETDATE(),112),4)+'_'+LEFT(CONVERT(varchar,GETDATE(),114),5)
		,'Source Files: ' + STUFF((SELECT '|' + REPLACE(SUBSTRING(QueueComment,9,11),'-','_') AS [text()]
			FROM AI.EmployeeQueue 
			WHERE StatusCode = 'N'
			FOR XML PATH('')
			),1,1,''
			) [Comment]
		,'A'
		,'N' --Update Override Not NULL
		,2
		,'AUTO'
		,GETDATE()
		,'AUTO'
		,GETDATE()
END
END


--Employee Record

INSERT INTO TakeOn.EmployeeTakeOnRecord (EmployeeTakeOnInstanceID,EmployeeCode,EntityCode,CompanyID,CompanyRuleID,PaymentRunDefID,RemunerationEarnDefID,LeavePolicyID,GenEntityTypeID,GenEntitySubTypeID,CompanyName,TaxNo,TaxRegistrationDate,VATNo,CompanyRegistrationNo,CompanyRegistrationDate,TitleTypeID,Initials,FirstName,SecondName,OtherNames,KnownAsName,LastName,MaidenName,MaritalStatusTypeID,IdentityTypeID,IDNumber,IDNumberExpiryDate,BirthDate,BirthCertificateNumber,CityOfBirth,Gender,LanguageTypeID,NationalityCountryCode,CountryOfBirth,PassportNo,PassportCountryCode,[Disabled],DisabilityTypeID,EthnicTypeID,RacialGroup,RaceGroupID,ReligionID,BloodGroup,DateEngaged,TaxBranchID,UIFStatusID,UIFStartDate,JobTitleTypeID,JobGradeID,TerminationDate,TerminationReasonID,FinalCalcNow,DateJoinedGroup,LeaveStartDate,NatureOfContractID,ProbationPeriodEndDate,HoursPerPeriod,HoursPerDay,AnnualSalary,PeriodSalary,OverrideAnnualBonusCalcRecurrence,CalendarMonth,PeriodInMonth,DefaultShiftsPerPeriod,RatePerDay,RatePerHour,PensionFundStartDate,ProvidentFundStartDate,ZoneCodes,IncreaseReasonTypeID,MedicalStartDate,LegallyRetiredforTaxPurpose,ForeignIncome,TaxStatusID,TaxStartDate,TaxCalculation,DirectiveNumber,DirectivePercentage,DirectiveTaxAmount,DeemedRemuneration,UseTaxValue1,UseTaxValue2,RemunerationDefinitionHeaderID,UseWork,UsePhysical,UsePostal,AddressServiceTypeID,CorrespondenceAddress,UnitPostalNumber,Complex,LevelFloor,Block,StreetNumber,StreetFarmName,SuburbDistrict,DistrictID,CityTown,Province,PostalCode,PostalAgency,PostalOffice,PostalAddressNumber,OtherServiceType,CareOf,CareOfName,CountryCode,UseWork1,UsePhysical1,UsePostal1,AddressServiceTypeID1,CorrespondenceAddress1,UnitPostalNumber1,Complex1,LevelFloor1,Block1,StreetNumber1,StreetFarmName1,SuburbDistrict1,DistrictID1,CityTown1,Province1,PostalCode1,PostalAgency1,PostalOffice1,PostalAddressNumber1,OtherServiceType1,CareOf1,CareOfName1,CountryCode1,UseWork2,UsePhysical2,UsePostal2,AddressServiceTypeID2,CorrespondenceAddress2,UnitPostalNumber2,Complex2,LevelFloor2,Block2,StreetNumber2,StreetFarmName2,SuburbDistrict2,DistrictID2,CityTown2,Province2,PostalCode2,PostalAgency2,PostalOffice2,PostalAddressNumber2,OtherServiceType2,CareOf2,CareOfName2,CountryCode2,AccountHolderRelationship,AccountName,BankID,AccountTypeID,AccountNo,BankBranchID,Ccy,DriversLicCountryCode,IssueDate,ExpiryDate,LicenseNumber,LicenseCategoriesTypeID,LicenseRestrictionsTypeID,FWLPolicyID,EffectiveDate,FWLExpiryDate,PermitNumber,CancellationDate,FWLIssueDate,ArrivalDate,ApplicationDate,CPFVoluntaryPolicyID,SocialSecurityFundTypeID,SDLExempt,RTNumber,RWNumber,KartuKeluargaNumber,HealthFacilityID,BPJSPensionNumber,JPKNumber,KPJNumber,EmploymentStatus,BPJSKesehatan,GovernmentAssistance,LineValid,UserID,LastChanged)

--Add fields based on your MasterQueue table, or use NULL where fields are not applicable.

SELECT 
	--(SELECT MAX(EmployeeTakeOnInstanceID) FROM TakeOn.EmployeeTakeOnInstance WHERE LEFT(Code,5) = 'AI' + CASE WHEN q.EventCode NOT IN ('N','X') THEN '_UO' ELSE '_CU' END AND TakeOnStatus = 2)
	(SELECT MAX(EmployeeTakeOnInstanceID) FROM TakeOn.EmployeeTakeOnInstance ti WHERE LEFT(Code,15) = CASE WHEN q.EventCode NOT IN ('N','X') THEN 'UPD_' ELSE 'NEW_' END + RIGHT(CONVERT(varchar,GETDATE(),112),6) + REPLACE(LEFT(CONVERT(varchar,GETDATE(),114),5),':','') AND TakeOnStatus = 2) --Specific for AegisTesting
	,q.EmployeeCode
	,q.EntityCode
	,(SELECT TOP 1 CompanyID FROM Company.Company WHERE CompanyCode = q.CompanyCode)
	,(SELECT TOP 1 CompanyRuleID FROM Company.CompanyRule WHERE CompanyRuleCode = q.CompanyRuleCode)
	,(SELECT TOP 1 PaymentRunDefID FROM Payroll.PaymentRunDef prd INNER JOIN Company.Company c ON c.CompanyID = prd.CompanyID AND c.CompanyCode = q.CompanyCode WHERE Code = q.PaymentRunDefCode)
	,(SELECT TOP 1 EarningDefID FROM Payroll.EarningDef ed INNER JOIN Company.Company c ON c.CompanyID = ed.CompanyID AND c.CompanyCode = q.CompanyCode WHERE DefCode = q.RemunerationEarnDefCode)
	,(SELECT TOP 1 LeavePolicyID FROM Leave.LeavePolicy lp INNER JOIN Company.Company c ON c.CompanyID = lp.CompanyID AND c.CompanyCode = q.CompanyCode WHERE Code = q.LeavePolicyCode)
	,(SELECT TOP 1 GenEntityTypeID FROM Entity.GenEntityType WHERE Code = q.GenEntityTypeCode)
	,(SELECT TOP 1 GenEntitySubTypeID FROM Entity.GenEntitySubType WHERE Code = q.GenEntitySubTypeCode)
	,NULL CompanyName
	,q.TaxNo
	,NULL TaxRegistrationDate
	,NULL VATNo
	,NULL CompanyRegistrationNo
	,NULL CompanyRegistrationDate
	,(SELECT TOP 1 TitleTypeID FROM Entity.TitleType WHERE Code = q.TitleTypeCode)
	,q.Initials
	,q.FirstName
	,q.SecondName
	,q.OtherNames
	,q.KnownAsName
	,q.LastName
	,q.MaidenName
	,(SELECT TOP 1 MaritalStatusTypeID FROM Entity.MaritalStatusType WHERE Code = q.MaritalStatusTypeCode)
	,q.IdentityTypeCode
	,q.IDNumber
	,q.IDNumberExpiryDate
	,q.BirthDate
	,q.BirthCertificateNumber
	,q.CityOfBirth
	,q.Gender 
	,(SELECT TOP 1 LanguageTypeID FROM Entity.LanguageType WHERE LanguageCode = q.LanguageTypeCode)
	,q.NationalityCountryCode
	,q.CountryOfBirth
	,q.PassportNo
	,q.PassportCountryCode
	,q.[Disabled]
	,(SELECT TOP 1 DisabilityTypeID FROM Entity.DisabilityType WHERE Code = q.DisabilityTypeCode)
	,(SELECT TOP 1 EthnicTypeID FROM Entity.EthnicType WHERE Code = q.EthnicTypeCode)
	,q.RacialGroup
	,(SELECT TOP 1 RaceGroupID FROM Entity.RaceGroup WHERE Code = q.RaceGroupCode)
	,(SELECT TOP 1 ReligionID FROM Entity.Religion WHERE Code = q.ReligionCode)
	,q.BloodGroup
	,q.DateEngaged
	,(SELECT TOP 1 TaxBranchID FROM Employee.TaxBranch WHERE Code = q.TaxBranchCode)
	,(SELECT TOP 1 UIFStatusID FROM Employee.UIFStatus WHERE Code = q.UIFStatusCode)
	,q.UIFStartDate
	,(SELECT TOP 1 JobTitleTypeID FROM Employee.JobTitleType WHERE Code = q.JobTitleTypeCode)
	,(SELECT TOP 1 JobGradeID FROM Employee.JobGrade WHERE Code = q.JobGradeCode)
	,q.TerminationDate
	,(SELECT TOP 1 TerminationReasonID FROM Employee.TerminationReason WHERE Code = q.TerminationReasonCode)
	,q.FinalCalcNow
	,q.DateJoinedGroup
	,q.LeaveStartDate
	,(SELECT TOP 1 NatureOfContractID FROM Employee.NatureOfContract WHERE Code = q.NatureOfContractCode)
	,q.ProbationPeriodEndDate
	,q.HoursPerPeriod
	,q.HoursPerDay
	,q.AnnualSalary
	,q.PeriodSalary
	,q.OverrideAnnualBonusCalcRecurrence
	,q.CalendarMonth
	,q.PeriodInMonth
	,q.DefaultShiftsPerPeriod
	,q.RatePerDay
	,q.RatePerHour
	,q.PensionFundStartDate
	,q.ProvidentFundStartDate
	,q.ZoneCodes
	,(SELECT TOP 1 IncreaseReasonTypeID FROM Employee.IncreaseReasonType WHERE Code = q.IncreaseReasonTypeCode)
	,q.MedicalStartDate
	,q.LegallyRetiredforTaxPurpose
	,q.ForeignIncome
	,(SELECT TOP 1 TaxStatusID FROM Employee.TaxStatus WHERE Code = q.TaxStatusCode)
	,q.TaxStartDate
	,q.TaxCalculation
	,q.DirectiveNumber
	,q.DirectivePercentage
	,q.DirectiveTaxAmount
	,q.DeemedRemuneration
	,q.UseTaxValue1
	,q.UseTaxValue2
	,q.RemunerationDefinitionHeaderCode
	,q.UseWork
	,q.UsePhysical
	,q.UsePostal
	,(SELECT TOP 1 AddressServiceTypeID FROM Entity.AddressServiceType WHERE Code = q.AddressServiceTypeCode)
	,q.CorrespondenceAddress
	,q.UnitPostalNumber
	,q.Complex
	,q.LevelFloor
	,q.Block
	,q.StreetNumber
	,q.StreetFarmName
	,q.SuburbDistrict
	,(SELECT TOP 1 DistrictID FROM Entity.District WHERE Code = q.DistrictCode)
	,q.CityTown
	,q.Province
	,q.PostalCode
	,q.PostalAgency
	,q.PostOffice
	,q.PostalAddressNumber
	,q.OtherServiceType
	,q.CareOf
	,q.CareOfName
	,q.CountryCode
	,q.UseWork1
	,q.UsePhysical1
	,q.UsePostal1
	,(SELECT TOP 1 AddressServiceTypeID FROM Entity.AddressServiceType WHERE Code = q.AddressServiceTypeCode1)
	,q.CorrespondenceAddress1
	,q.UnitPostalNumber1
	,q.Complex1
	,q.LevelFloor1
	,q.Block1
	,q.StreetNumber1
	,q.StreetFarmName1
	,q.SuburbDistrict1
	,(SELECT TOP 1 DistrictID FROM Entity.District WHERE Code = q.DistrictCode1)
	,q.CityTown1
	,q.Province1
	,q.PostalCode1
	,q.PostalAgency1
	,q.PostOffice1
	,q.PostalAddressNumber1
	,q.OtherServiceType1
	,q.CareOf1
	,q.CareOfName1
	,q.CountryCode1
	,q.UseWork2
	,q.UsePhysical2
	,q.UsePostal2
	,(SELECT TOP 1 AddressServiceTypeID FROM Entity.AddressServiceType WHERE Code = q.AddressServiceTypeCode2)
	,q.CorrespondenceAddress2
	,q.UnitPostalNumber2
	,q.Complex2
	,q.LevelFloor2
	,q.Block2
	,q.StreetNumber2
	,q.StreetFarmName2
	,q.SuburbDistrict2
	,(SELECT TOP 1 DistrictID FROM Entity.District WHERE Code = q.DistrictCode2)
	,q.CityTown2
	,q.Province2
	,q.PostalCode2
	,q.PostalAgency2
	,q.PostOffice2
	,q.PostalAddressNumber2
	,q.OtherServiceType2
	,q.CareOf2
	,q.CareOfName2
	,q.CountryCode2
	,q.AccountHolderRelationship
	,q.AccountName
	,(SELECT TOP 1 BankID FROM Entity.Bank WHERE Code = q.BankCode)
	,(SELECT TOP 1 AccountTypeID FROM Entity.AccountType WHERE Code = q.AccountTypeCode)
	,q.AccountNo
	,(SELECT TOP 1 BankBranchID FROM Entity.BankBranch WHERE BranchCode = q.BankBranchCode)
	,q.Ccy
	,q.DriversLicCountryCode
	,q.IssueDate
	,q.ExpiryDate
	,q.LicenseNumber
	,(SELECT TOP 1 LicenseCategoriesTypeID FROM Entity.LicenseCategoriesType WHERE Code = q.LicenseCategoriesTypeCode)
	,(SELECT TOP 1 LicenseRestrictionsTypeID FROM Entity.LicenseRestrictionsType WHERE Code = q.LicenseRestrictionsTypeCode)
	,NULL FWLPolicyID
	,q.EffectiveDate
	,q.FWLExpiryDate
	,q.PermitNumber
	,q.CancellationDate
	,q.FWLIssueDate
	,q.ArrivalDate
	,q.ApplicationDate
	,NULL CPFVoluntaryPolicyID
	,NULL SocialSecurityFundTypeID
	,0 [SDLExempt]
	,q.RTNumber
	,q.RWNumber
	,q.KartuKeluargaNumber
	,NULL HealthFacilityID
	,q.BPJSPensionNumber
	,q.JPKNumber
	,q.KPJNumber
	,q.EmploymentStatus
	,q.BPJSKesehatan
	,q.GovernmentAssistance
	,1
	,'Automation'
	,GETDATE()
FROM AI.EmployeeQueue q
WHERE q.StatusCode = 'N'
	AND OID IN (SELECT OID FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY OID DESC) AS RwNumb, * FROM AI.EmployeeQueue) e WHERE e.RwNumb = 1)
	AND ISNULL(QueueFilter,'') = @QueueFilter


UPDATE AI.EmployeeQueue
SET StatusCode = 'I'
	,StatusMessage = 'Ignored: A newer Create record exists for this event'
WHERE OID IN (SELECT OID FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY OID DESC) AS RwNumb, * FROM AI.EmployeeQueue WHERE FirstName IS NOT NULL) e WHERE e.RwNumb <> 1 AND FirstName IS NOT NULL) AND ISNULL(QueueFilter,'') = @QueueFilter



--Hierarchy's, Contacts And Generic Fields
BEGIN TRANSACTION
INSERT INTO TakeOn.EmployeeTakeOnRecordChild (EmployeeTakeOnRecordID,TargetTable,[Lookup],Value,UserID,LastChanged)
SELECT tor.EmployeeTakeOnRecordID
	,q.SubQueueTableType
	,q.SubQueueType
	,q.SubQueueValue
	,'AUTO'
	,GETDATE()
FROM AI.EmployeeSubQueue q
	INNER JOIN TakeOn.EmployeeTakeOnRecord tor ON tor.EmployeeCode = q.EmployeeCode
COMMIT

	

UPDATE AI.EmployeeQueue
SET StatusCode = 'Success'
	,StatusMessage = 'Validations Passed: Event moved to Batch Processing Phase'
	,LastChanged = GETDATE()
WHERE StatusCode = 'N'
	 AND ISNULL(QueueFilter,'') = @QueueFilter


INSERT INTO AI.EmployeeSubQueueHistory SELECT * FROM AI.EmployeeSubQueue
DELETE FROM AI.EmployeeSubQueue

INSERT INTO AI.EmployeeSourceHistory SELECT * FROM AI.EmployeeSource
DELETE FROM AI.EmployeeSource

--Phase 2: create an output to show a type of audit of each field which has changed by comparing the final results of the processed to batch fields, to what is currently in the system to provide to administrators who want to see what changes will occur if the batch is processed.

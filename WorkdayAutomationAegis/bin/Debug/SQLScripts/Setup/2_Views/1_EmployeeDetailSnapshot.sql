CREATE VIEW [AI].[EmployeeDetailSnapshot]
AS
SELECT e.EmployeeID
	,e.EmployeeCode
	,ge.GenEntityID
	,ge.EntityCode
	,c.CompanyCode
	,cr.CompanyRuleCode
	,(SELECT '('+CONVERT(varchar,pd.PaymentRunDefID)+')'+l.Code FROM Payroll.PaymentRunDef l WHERE l.PaymentRunDefID = pd.PaymentRunDefID) [PaymentRunDefCode]
	,(SELECT '('+CONVERT(varchar,pd.RemunerationEarnDefID)+')'+l.DefCode FROM Payroll.EarningDef l WHERE l.EarningDefID = pd.RemunerationEarnDefID) [RemunerationEarnDefCode]
	,(SELECT '('+CONVERT(varchar,l.LeavePolicyID)+')'+lp.Code FROM Leave.EmployeeLeavePolicy l INNER JOIN Leave.LeavePolicy lp ON lp.LeavePolicyID = l.LeavePolicyID WHERE l.EmployeeRuleID = er.EmployeeRuleID AND l.[Status] = 'A') [LeavePolicyCode]
	,(SELECT l.Code FROM Entity.GenEntityType l WHERE l.GenEntityTypeID = ge.GenEntityTypeID) [GenEntityTypeCode]
	,(SELECT l.Code FROM Entity.GenEntitySubType l WHERE l.GenEntitySubTypeID = ge.GenEntitySubTypeID) [GenEntitySubTypeCode]
	,NULL [CompanyName]
	,ge.TaxNo
	,NULL [TaxRegistrationDate]
	,NULL [VATNo]
	,NULL [CompanyRegistrationNo]
	,NULL [CompanyRegistrationDate]
	,tt.Code [TitleTypeCode]
	,ge.Initials
	,ge.FirstName
	,ge.SecondName
	,ge.OtherNames
	,ge.KnownAsName
	,ge.LastName
	,ge.MaidenName
	,ge.ArabicFullName
	,ms.Code [MaritalStatusTypeCode]
	,(SELECT Code FROM Entity.IdentityType l WHERE l.IdentityTypeID = ge.IdentityTypeID) [IdentityTypeCode]
	,ge.IDNumber
	,ge.IDNumberExpiryDate
	,ge.BirthDate
	,ge.BirthCertificateNumber
	,ge.CityOfBirth
	,ge.Gender
	,(SELECT LanguageCode FROM Entity.LanguageType l WHERE l.LanguageTypeID = ge.LanguageTypeID) [LanguageTypeCode]
	,ge.NationalityCountryCode
	,ge.CountryOfBirth
	,ge.PassportNo
	,ge.PassportCountryCode
	,ge.[Disabled]
	,(SELECT l.Code FROM Entity.DisabilityType l WHERE l.DisabilityTypeID = ge.DisabilityTypeID) [DisabilityTypeCode]
	,(SELECT l.Code FROM Entity.EthnicType l WHERE l.EthnicTypeID = ge.EthnicTypeID) [EthnicTypeCode]
	,ge.RacialGroup
	,(SELECT l.Code FROM Entity.RaceGroup l WHERE l.RaceGroupID = ge.RaceGroupID) [RaceGroupCode]
	,(SELECT l.Code FROM Entity.Religion l WHERE l.ReligionID = ge.ReligionID) [ReligionCode]
	,ge.BloodGroup
	,e.DateEngaged
	,(SELECT l.Code FROM Employee.TaxBranch l WHERE l.TaxBranchID = er.TaxBranchID) [TaxBranchCode]
	,(SELECT l.Code FROM Employee.UIFStatus l WHERE l.UIFStatusID = e.UIFStatusID) [UIFStatusCode]
	,e.UIFReasonStartDate
	,(SELECT l.Code FROM Employee.JobTitleType l WHERE l.JobTitleTypeID = e.JobTitleTypeID) [JobTitleTypeCode]
	,(SELECT l.Code FROM Employee.JobGrade l WHERE l.JobGradeID = e.JobGradeID) [JobGradeCode]
	,e.TerminationDate
	,tr.Code [TerminationReasonCode]
	,e.FinalCalcNow
	,e.DateJoinedGroup
	,e.LeaveStartDate
	,(SELECT l.Code FROM Employee.NatureOfContract l WHERE l.NatureOfContractID = e.NatureOfContractID) [NatureOfContractCode]
	,e.ProbationPeriodEndDate
	,er.HoursPerPeriod
	,er.HoursPerDay
	,er.AnnualSalary
	,er.PeriodSalary
	,er.OverrideAnnualBonusCalcRecurrence
	,er.CalendarMonth
	,er.PeriodInMonth
	,er.DefaultShiftsPerPeriod
	,er.RatePerDay
	,er.RatePerHour
	,er.PensionFundStartDate
	,er.ProvidentFundStartDate
	,NULL [ZoneCodes]
	,(SELECT l.Code FROM Employee.IncreaseReasonType l WHERE l.IncreaseReasonTypeID = er.IncreaseReasonTypeID) [IncreaseReasonTypeCode]
	,er.MedicalStartDate
	,er.AddRate1
	,er.AddRate2
	,er.AddRate3
	,er.AddRate4
	,er.AddRate5
	,er.AddDate1
	,er.AddDate2
	,er.AddDate3
	,er.AddDate4
	,er.AddDate5
	,ge.ForeignInd [ForeignIncome]
	,et.TaxStartDate
	,et.TaxCalculation
	,et.DirectiveNumber
	,et.DirectivePercentage
	,et.DirectiveTaxAmount
	,et.DeemedRemuneration
	,et.UseTaxValue1
	,et.UseTaxValue2
	,(SELECT l.Code FROM Payroll.RemunerationDefinitionHeader l WHERE l.RemunerationDefinitionHeaderID = er.RemunerationDefinitionHeaderID) [RemunerationDefinitionHeaderCode]

	,wrk.UseWork
	,NULL [UsePhysical]
	,NULL [UsePostal]
	,(SELECT l.Code FROM Entity.AddressServiceType l WHERE l.AddressServiceTypeID = wrk.AddressServiceTypeID) [AddressServiceTypeCode]
	,wrk.CorrespondenceAddress
	,wrk.UnitPostalNumber
	,wrk.Complex
	,wrk.LevelFloor
	,wrk.[Block]
	,wrk.StreetNumber
	,wrk.StreetFarmName
	,wrk.SuburbDistrict
	,(SELECT l.Code FROM Entity.District l WHERE l.DistrictID = wrk.DistrictID) [DistrictCode]
	,wrk.CityTown
	,wrk.Province
	,wrk.PostalCode
	,wrk.PostalAgency
	,CONVERT(varchar,wrk.PostOffice) [PostOffice]
	,wrk.PostalAddressNumber
	,wrk.OtherServiceType
	,wrk.CareOf
	,wrk.CareOfName
	,wrk.CountryCode
	,NULL [UseWork1]
	,phy.UsePhysical [UsePhysical1]
	,NULL [UsePostal1]
	,(SELECT l.Code FROM Entity.AddressServiceType l WHERE l.AddressServiceTypeID = phy.AddressServiceTypeID) [AddressServiceTypeCode1]
	,phy.CorrespondenceAddress [CorrespondenceAddress1]
	,phy.UnitPostalNumber [UnitPostalNumber1]
	,phy.Complex [Complex1]
	,phy.LevelFloor [LevelFloor1]
	,phy.[Block] [Block1]
	,phy.StreetNumber [StreetNumber1]
	,phy.StreetFarmName [StreetFarmName1]
	,phy.SuburbDistrict [SuburbDistrict1]
	,(SELECT l.Code FROM Entity.District l WHERE l.DistrictID = phy.DistrictID) [DistrictCode1]
	,phy.CityTown [CityTown1]
	,phy.Province [Province1]
	,phy.PostalCode [PostalCode1]
	,phy.PostalAgency [PostalAgency1]
	,CONVERT(varchar,phy.PostOffice) [PostOffice1]
	,phy.PostalAddressNumber [PostalAddressNumber1]
	,phy.OtherServiceType [OtherServiceType1]
	,phy.CareOf [CareOf1]
	,phy.CareOfName [CareOfName1]
	,phy.CountryCode [CountryCode1]
	,NULL [UseWork2]
	,NULL [UsePhysical2]
	,pos.UsePostal [UsePostal2]
	,(SELECT l.Code FROM Entity.AddressServiceType l WHERE l.AddressServiceTypeID = pos.AddressServiceTypeID) [AddressServiceTypeCode2] --,q.[AddressServiceTypeCode2]
	,pos.CorrespondenceAddress [CorrespondenceAddress2] --,q.[CorrespondenceAddress2]
	,pos.UnitPostalNumber [UnitPostalNumber2] --,q.[UnitPostalNumber2]
	,pos.Complex [Complex2] --,q.[Complex2]
	,pos.LevelFloor [LevelFloor2] --,q.[LevelFloor2]
	,pos.[Block] [Block2] --,q.[Block2]
	,pos.StreetNumber [StreetNumber2] --,q.[StreetNumber2]
	,pos.StreetFarmName [StreetFarmName2] --,q.[StreetFarmName2]
	,pos.SuburbDistrict [SuburbDistrict2] --,q.[SuburbDistrict2]
	,(SELECT l.Code FROM Entity.District l WHERE l.DistrictID = pos.DistrictID) [DistrictCode2] --,q.[DistrictCode2]
	,pos.CityTown [CityTown2] --,q.[CityTown2]
	,pos.Province [Province2] --,q.[Province2]
	,pos.PostalCode [PostalCode2] --,q.[PostalCode2]
	,pos.PostalAgency [PostalAgency2] --,q.[PostalAgency2]
	,CONVERT(varchar,pos.PostOffice) [PostOffice2] --,q.[PostOffice2]
	,pos.PostalAddressNumber [PostalAddressNumber2] --,q.[PostalAddressNumber2]
	,pos.OtherServiceType [OtherServiceType2] --,q.[OtherServiceType2]
	,pos.CareOf [CareOf2]
	,pos.CareOfName [CareOfName2]
	,pos.CountryCode [CountryCode2]
	,bd.AccountName
	,act.Code [AccountTypeCode]
	,bd.AccountNo
	,b.Code [BankCode]
	,bb.BranchCode
	,bd.Ccy
	,NULL [DriversLicCountryCode]
	,NULL [IssueDate]
	,NULL [ExpiryDate]
	,NULL [LicenseNumber]
	,NULL [LicenseCategoriesTypeID]
	,NULL [LicenseRestrictionsTypeID]
	,NULL [FWLPolicyID]
	,NULL [EffectiveDate]
	,NULL [FWLExpiryDate]
	,NULL [PermitNumber]
	,NULL [CancellationDate]
	,NULL [FWLIssueDate]
	,NULL [ArrivalDate]
	,NULL [ApplicationDate]
	,NULL [CPFVoluntaryPolicyID]
	,NULL [SocialSecurityFundTypeID]
	,NULL [SDLExempt]
	,NULL [RTNumber]
	,NULL [RWNumber]
	,NULL [KartuKeluargaNumber]
	,NULL [HealthFacilityID]
	,NULL [BPJSPensionNumber]
	,NULL [JPKNumber]
	,NULL [KPJNumber]
	,NULL [EmploymentStatus]
	,NULL [BPJSKesehatan]
	,NULL [GovernmentAssistance]
FROM (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY DateEngaged DESC, ISNULL(CAST(TerminationDate AS datetime),'9999-12-31') DESC) RwNumb ,* FROM Employee.Employee) emp WHERE RwNumb = 1) e
	INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID
	INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID
	INNER JOIN Company.CompanyRule cr ON cr.CompanyRuleID = er.CompanyRuleID
	INNER JOIN Entity.GenEntity ge ON ge.GenEntityID = e.GenEntityID
	LEFT JOIN Entity.TitleType tt ON tt.TitleTypeID = ge.TitleTypeID
	LEFT JOIN Entity.MaritalStatusType ms ON ms.MaritalStatusTypeID = ge.MaritalStatusTypeID
	LEFT JOIN Employee.TerminationReason tr ON tr.TerminationReasonID = e.TerminationReasonID
	LEFT JOIN Entity.Address phy ON phy.AddressID = ge.PhysicalAddressID
	LEFT JOIN Entity.Address wrk ON wrk.AddressID = ge.WorkAddressID
	LEFT JOIN Entity.Address pos ON pos.AddressID = ge.PostalAddressID
	LEFT JOIN Payroll.PayslipDef pd ON pd.EmployeeRuleID = er.EmployeeRuleID AND pd.PayRunDefID IN (SELECT PayRunDefID FROM Company.PayRunDef WHERE MainPayRunDef = 1)
	LEFT JOIN Entity.BankDetail bd ON bd.BankDetailID = pd.BankDetailID
	LEFT JOIN Entity.AccountType act ON act.AccountTypeID = bd.AccountTypeID
	LEFT JOIN Entity.Bank b ON b.BankID = bd.BankID
	LEFT JOIN Entity.BankBranch bb ON bb.BankBranchID = bd.BankBranchID
	LEFT JOIN (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY EmployeeTaxID DESC) [RwNumb] ,* FROM Employee.EmployeeTax) etr WHERE etr.RwNumb = 1) et ON et.EmployeeID = e.EmployeeID

IF OBJECT_ID('AI.EmployeeSource', 'U') IS NOT NULL DROP TABLE AI.EmployeeSource
CREATE TABLE [AI].[EmployeeSource](
	[OID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CountryCodeIndicator] [nvarchar](max) NULL,
	[EmployeeCode] [nvarchar](max) NULL,
	[CompanyID] [nvarchar](max) NULL,
	[TaxNo] [nvarchar](max) NULL,
	[TitleTypeID] [nvarchar](max) NULL,
	[FirstName] [nvarchar](max) NULL,
	[SecondName] [nvarchar](max) NULL,
	[KnownAsName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[MaritalStatusTypeID] [nvarchar](max) NULL,
	[IDNumber] [nvarchar](max) NULL,
	[IDNumberExpiryDate] [nvarchar](max) NULL,
	[BirthDate] [nvarchar](max) NULL,
	[CityOfBirth] [nvarchar](max) NULL,
	[Gender] [nvarchar](max) NULL,
	[NationalityCountryCode] [nvarchar](max) NULL,
	[CountryOfBirth] [nvarchar](max) NULL,
	[PassportNo] [nvarchar](max) NULL,
	[PassportCountryCode] [nvarchar](max) NULL,
	[Disabled] [nvarchar](max) NULL,
	[RacialGroup] [nvarchar](max) NULL,
	[DateEngaged] [nvarchar](max) NULL,
	[TerminationDate] [nvarchar](max) NULL,
	[TerminationReasonID] [nvarchar](max) NULL,
	[DateJoinedGroup] [nvarchar](max) NULL,
	[LeaveStartDate] [nvarchar](max) NULL,
	[ProbationPeriodEndDate] [nvarchar](max) NULL,
	[AnnualSalary] [nvarchar](max) NULL,
	[PeriodSalary] [nvarchar](max) NULL,
	[RatePerHour] [nvarchar](max) NULL,
	[PensionFundStartDate] [nvarchar](max) NULL,
	[ProvidentFundStartDate] [nvarchar](max) NULL,
	[MedicalStartDate] [nvarchar](max) NULL,
	[ForeignIncome] [nvarchar](max) NULL,
	[TaxStartDate] [nvarchar](max) NULL,
	[UseWork] [nvarchar](max) NULL,
	[UnitPostalNumber] [nvarchar](max) NULL,
	[Complex] [nvarchar](max) NULL,
	[StreetNumber] [nvarchar](max) NULL,
	[StreetFarmName] [nvarchar](max) NULL,
	[SuburbDistrict] [nvarchar](max) NULL,
	[CityTown] [nvarchar](max) NULL,
	[Province] [nvarchar](max) NULL,
	[PostalCode] [nvarchar](max) NULL,
	[CountryCode] [nvarchar](max) NULL,
	[UsePhysical1] [nvarchar](max) NULL,
	[UnitPostalNumber1] [nvarchar](max) NULL,
	[Complex1] [nvarchar](max) NULL,
	[StreetNumber1] [nvarchar](max) NULL,
	[StreetFarmName1] [nvarchar](max) NULL,
	[SuburbDistrict1] [nvarchar](max) NULL,
	[CityTown1] [nvarchar](max) NULL,
	[Province1] [nvarchar](max) NULL,
	[PostalCode1] [nvarchar](max) NULL,
	[CountryCode1] [nvarchar](max) NULL,
	[UsePostal2] [nvarchar](max) NULL,
	[UnitPostalNumber2] [nvarchar](max) NULL,
	[Complex2] [nvarchar](max) NULL,
	[StreetNumber2] [nvarchar](max) NULL,
	[StreetFarmName2] [nvarchar](max) NULL,
	[SuburbDistrict2] [nvarchar](max) NULL,
	[CityTown2] [nvarchar](max) NULL,
	[Province2] [nvarchar](max) NULL,
	[PostalCode2] [nvarchar](max) NULL,
	[CountryCode2] [nvarchar](max) NULL,
	[AccountName] [nvarchar](max) NULL,
	[AccountTypeID] [nvarchar](max) NULL,
	[AccountNo] [nvarchar](max) NULL,
	[BankBranchID] [nvarchar](max) NULL,
	[Ccy] [nvarchar](max) NULL,
	[Home] [nvarchar](max) NULL,
	[Work] [nvarchar](max) NULL,
	[Fax] [nvarchar](max) NULL,
	[Cell] [nvarchar](max) NULL,
	[Mail] [nvarchar](max) NULL,
	[Paypoint] [nvarchar](max) NULL,
	[RSCCode] [nvarchar](max) NULL,
	[SocialSecurityNumber] [nvarchar](max) NULL,
	[NHIFNumber] [nvarchar](max) NULL,
	[NSSFNumber] [nvarchar](max) NULL,
	[NSSFMembershipNumber] [nvarchar](max) NULL,
	[PPFMembershipNumber] [nvarchar](max) NULL,
	[SourceFileName] [nvarchar](max) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
 CONSTRAINT [PK_AI_EmployeeSource_OID] PRIMARY KEY CLUSTERED 
(
	[OID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
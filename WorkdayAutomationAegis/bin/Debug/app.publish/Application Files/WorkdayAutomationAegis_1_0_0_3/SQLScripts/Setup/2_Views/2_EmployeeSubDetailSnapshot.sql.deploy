CREATE VIEW [AI].[EmployeeSubDetailSnapshot]
AS
SELECT *
FROM
(
SELECT e.EmployeeID
	,e.EmployeeCode
	,'HierarchyHeader' [SubQueueTableType]
	,hh.Code [SubQueueType]
	,h.[HierarchyID] [SubQueueValueID]
	,h.HierarchyCode [SubQueueValue]
FROM (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY DateEngaged DESC, ISNULL(CAST(TerminationDate AS datetime),'9999-12-31') DESC) RwNumb ,* FROM Employee.Employee) emp WHERE RwNumb = 1) e
	INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID
	INNER JOIN Employee.EmployeeRuleHierarchyRel erh ON erh.EmployeeRuleID = er.EmployeeRuleID
	INNER JOIN Entity.HierarchyHeader hh ON hh.HierarchyHeaderID = erh.HierarchyHeaderID
	INNER JOIN Entity.Hierarchy h ON h.[HierarchyID] = erh.[HierarchyID]

UNION ALL

SELECT e.EmployeeID
	,e.EmployeeCode
	,'Contact' [SubQueueTableType]
	,c.ContactType [SubQueueType]
	,c.ContactID [SubQueueValueID]
	,c.ContactDetail [SubQueueValue]
FROM (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY DateEngaged DESC, ISNULL(CAST(TerminationDate AS datetime),'9999-12-31') DESC) RwNumb ,* FROM Employee.Employee) emp WHERE RwNumb = 1) e
	LEFT JOIN (SELECT ge.GenEntityID,'HOME' [ContactType],NULL [ContactID],ge.HomeNumber [ContactDetail] FROM Entity.GenEntity ge WHERE ge.HomeNumber IS NOT NULL
UNION ALL SELECT ge.GenEntityID,'WORK' [ContactType],NULL [ContactID],ge.WorkNumber [ContactDetail] FROM Entity.GenEntity ge WHERE ge.WorkNumber IS NOT NULL
UNION ALL SELECT ge.GenEntityID,'FAX' [ContactType],NULL [ContactID],ge.FaxNumber [ContactDetail] FROM Entity.GenEntity ge WHERE ge.FaxNumber IS NOT NULL
UNION ALL SELECT ge.GenEntityID,'CELL' [ContactType],NULL [ContactID],ge.CellNumber [ContactDetail] FROM Entity.GenEntity ge WHERE ge.CellNumber IS NOT NULL
UNION ALL SELECT ge.GenEntityID,'MAIL' [ContactType],NULL [ContactID],ge.EmailAddress [ContactDetail] FROM Entity.GenEntity ge --Email Inserted regardless, so that at least 1 field will return for new employees
UNION ALL SELECT c.GenEntityID,ct.Code [ContactType],c.ContactID [ContactID],c.ContactDetail FROM Entity.Contact c INNER JOIN Entity.ContactType ct ON ct.ContactTypeID = c.ContactTypeID WHERE c.ContactDetail IS NOT NULL) c ON c.GenEntityID = e.GenEntityID


UNION ALL

SELECT e.EmployeeID
	,e.EmployeeCode
	,'EmployeeGenericFields' [SubQueueTableType]
	,GenericFieldName [SubQueueType]
	,EmployeeGenericFieldsID [SubQueueValueID]
	,GenericFieldValue [SubQueueValue]
FROM (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY DateEngaged DESC, ISNULL(CAST(TerminationDate AS datetime),'9999-12-31') DESC) RwNumb ,* FROM Employee.Employee) emp WHERE RwNumb = 1) e
INNER JOIN (SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField1' [GenericFieldName],GenericStringField1 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField1 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField2' [GenericFieldName], GenericStringField2 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField2 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField3' [GenericFieldName], GenericStringField3 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField3 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField4' [GenericFieldName], GenericStringField4 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField4 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField5' [GenericFieldName], GenericStringField5 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField5 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField6' [GenericFieldName], GenericStringField6 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField6 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField7' [GenericFieldName], GenericStringField7 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField7 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField8' [GenericFieldName], GenericStringField8 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField8 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField9' [GenericFieldName], GenericStringField9 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField9 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericStringField10'[GenericFieldName],GenericStringField10 [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericStringField10 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField1' [GenericFieldName], CONVERT(varchar,GenericBitField1) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField1 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField2' [GenericFieldName], CONVERT(varchar,GenericBitField2) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField2 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField3' [GenericFieldName], CONVERT(varchar,GenericBitField3) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField3 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField4' [GenericFieldName], CONVERT(varchar,GenericBitField4) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField4 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField5' [GenericFieldName], CONVERT(varchar,GenericBitField5) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField5 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField6' [GenericFieldName], CONVERT(varchar,GenericBitField6) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField6 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField7' [GenericFieldName], CONVERT(varchar,GenericBitField7) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField7 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField8' [GenericFieldName], CONVERT(varchar,GenericBitField8) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField8 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField9' [GenericFieldName], CONVERT(varchar,GenericBitField9) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField9 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericBitField10'[GenericFieldName],CONVERT(varchar,GenericBitField10) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericBitField10 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField1' [GenericFieldName], CONVERT(varchar,GenericDateField1,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField1 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField2' [GenericFieldName], CONVERT(varchar,GenericDateField2,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField2 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField3' [GenericFieldName], CONVERT(varchar,GenericDateField3,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField3 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField4' [GenericFieldName], CONVERT(varchar,GenericDateField4,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField4 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField5' [GenericFieldName], CONVERT(varchar,GenericDateField5,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField5 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField6' [GenericFieldName], CONVERT(varchar,GenericDateField6,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField6 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField7' [GenericFieldName], CONVERT(varchar,GenericDateField7,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField7 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField8' [GenericFieldName], CONVERT(varchar,GenericDateField8,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField8 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField9' [GenericFieldName], CONVERT(varchar,GenericDateField9,112) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField9 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDateField10'[GenericFieldName], CONVERT(varchar,GenericDateField10,112)[GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDateField10 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField1' [GenericFieldName], CONVERT(varchar,GenericDecimalField1) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField1 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField2' [GenericFieldName], CONVERT(varchar,GenericDecimalField2) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField2 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField3' [GenericFieldName], CONVERT(varchar,GenericDecimalField3) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField3 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField4' [GenericFieldName], CONVERT(varchar,GenericDecimalField4) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField4 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField5' [GenericFieldName], CONVERT(varchar,GenericDecimalField5) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField5 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField6' [GenericFieldName], CONVERT(varchar,GenericDecimalField6) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField6 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField7' [GenericFieldName], CONVERT(varchar,GenericDecimalField7) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField7 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField8' [GenericFieldName], CONVERT(varchar,GenericDecimalField8) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField8 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField9' [GenericFieldName], CONVERT(varchar,GenericDecimalField9) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField9 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericDecimalField10'[GenericFieldName], CONVERT(varchar,GenericDecimalField10)[GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericDecimalField10 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField1' [GenericFieldName], CONVERT(varchar,GenericIntField1) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField1 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField2' [GenericFieldName], CONVERT(varchar,GenericIntField2) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField2 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField3' [GenericFieldName], CONVERT(varchar,GenericIntField3) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField3 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField4' [GenericFieldName], CONVERT(varchar,GenericIntField4) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField4 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField5' [GenericFieldName], CONVERT(varchar,GenericIntField5) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField5 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField6' [GenericFieldName], CONVERT(varchar,GenericIntField6) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField6 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField7' [GenericFieldName], CONVERT(varchar,GenericIntField7) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField7 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField8' [GenericFieldName], CONVERT(varchar,GenericIntField8) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField8 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField9' [GenericFieldName], CONVERT(varchar,GenericIntField9) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField9 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericIntField10'[GenericFieldName], CONVERT(varchar,GenericIntField10)[GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericIntField10 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField1' [GenericFieldName], CONVERT(varchar,GenericLookupField1) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField1 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField2' [GenericFieldName], CONVERT(varchar,GenericLookupField2) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField2 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField3' [GenericFieldName], CONVERT(varchar,GenericLookupField3) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField3 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField4' [GenericFieldName], CONVERT(varchar,GenericLookupField4) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField4 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField5' [GenericFieldName], CONVERT(varchar,GenericLookupField5) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField5 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField6' [GenericFieldName], CONVERT(varchar,GenericLookupField6) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField6 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField7' [GenericFieldName], CONVERT(varchar,GenericLookupField7) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField7 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField8' [GenericFieldName], CONVERT(varchar,GenericLookupField8) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField8 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField9' [GenericFieldName], CONVERT(varchar,GenericLookupField9) [GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField9 IS NOT NULL
 UNION ALL SELECT EmployeeGenericFieldsID,EmployeeID,'GenericLookupField10'[GenericFieldName], CONVERT(varchar,GenericLookupField10)[GenericFieldValue] FROM Employee.EmployeeGenericFields WHERE GenericLookupField10 IS NOT NULL
 ) egf ON egf.EmployeeID = e.EmployeeID
) sl

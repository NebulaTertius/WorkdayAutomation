CREATE PROCEDURE AI.LeaveTransactionToBalanceQueue
AS

INSERT INTO AI.LeaveBalanceQueueHistory SELECT * FROM AI.LeaveBalanceQueue WHERE StatusCode IN ('New','Success')
DELETE FROM AI.LeaveBalanceQueue WHERE StatusCode IN ('New','Success')


INSERT INTO AI.LeaveTransactionQueueHistory SELECT * FROM AI.LeaveTransactionQueue WHERE StatusCode IN ('Moved')
DELETE FROM AI.LeaveTransactionQueue WHERE StatusCode IN ('Moved')


--Queue Leave Types
IF OBJECT_ID('tempdb..##LeaveTypesPerEmployee') IS NOT NULL
    DROP TABLE ##LeaveTypesPerEmployee

SELECT EmployeeCode,CompanyCode,LeaveTypeCode,LeaveCode,SUM(TotalUnits) TotalUnits INTO ##LeaveTypesPerEmployee
FROM (SELECT EmployeeCode
	,(SELECT CompanyCode FROM Company.Company WHERE CompanyID = (SELECT TOP 1 e.CompanyID FROM Employee.Employee e WHERE e.EmployeeCode = q.EmployeeCode ORDER BY TerminationDate, DateEngaged DESC)) [CompanyCode]
	,LeaveTypeCode
	,'Time_Off_Entry(s): ' 
		+ STUFF((SELECT ' |' + REPLACE(LeaveCode,'TIME_OFF_ENTRY-','') + '('+CONVERT(varchar,FromDate,112)+')'+'['+UnitsTaken+' '+Unit+']' AS [text()]
			FROM AI.LeaveTransactionQueue tq
			WHERE tq.EmployeeCode = q.EmployeeCode AND tq.LeaveTypeCode = q.LeaveTypeCode
			FOR XML PATH('')
			),1,1,''
			) [LeaveCode]
	,SUM(CONVERT(decimal(18,4),UnitsTaken)) TotalUnits
FROM AI.LeaveTransactionQueue q
GROUP BY EmployeeCode
	,LeaveTypeCode
	,LeaveCode
) lq
WHERE LeaveTypeCode IS NOT NULL
GROUP BY EmployeeCode, CompanyCode, LeaveTypeCode, LeaveCode
ORDER BY EmployeeCode, CompanyCode, LeaveTypeCode, LeaveCode



--Leave Definitions Order
IF OBJECT_ID('tempdb..##DefOrderPerEmployee') IS NOT NULL
    DROP TABLE ##DefOrderPerEmployee
SELECT ROW_NUMBER() OVER (PARTITION BY e.EmployeeID, ld.LeaveTypeID ORDER BY ld.LeaveTypeID, lpdr.Sequence ASC) LveDefRwNumb
	,COUNT(ld.LeaveTypeID) OVER (PARTITION BY e.EmployeeID, ld.LeaveTypeID) LveDefCount
	,e.EmployeeID
	,e.EmployeeCode
	,e.CompanyID
	,c.CompanyCode
	,e.DateEngaged
	,e.TerminationDate
	,lp.LongDescription LeavePolicyDescription
	,lt.Code LeaveTypeCode
	,lt.LongDescription LeaveType
	,lpdr.Sequence
	,ld.LeaveDefID
	,ld.Code LeaveDefCode
	,ld.LongDescription LeaveDefinition
	,SUM(el.BalanceBroughtForward) BalanceBroughtForward
	,SUM(el.AccruedThisPeriod) AccruedThisPeriod
	,SUM(el.TakenThisPeriod) TakenThisPeriod
	,SUM(ISNULL(el.Adjustment,0)) Adjustment
	,SUM(el.BalanceCarriedForward) BalanceCarriedForward
	,SUM(el.PlannedLeave) PlannedLeave
	,SUM(el.BalanceIncludingPlanned) BalanceIncludingPlanned
INTO ##DefOrderPerEmployee
FROM (SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode, CompanyID ORDER BY TerminationDate, DateEngaged DESC) [RwNumb], * FROM Employee.Employee) e WHERE RwNumb = 1) e
	INNER JOIN Company.Company c ON c.CompanyID = e.CompanyID
	INNER JOIN Employee.EmployeeRule er ON er.EmployeeID = e.EmployeeID
	INNER JOIN Company.PayPeriodGen pp ON pp.CompanyRuleID = er.CompanyRuleID AND pp.PeriodStatus = 'L'
	INNER JOIN Employee.EmployeePayPeriod epp ON epp.EmployeeID = e.EmployeeID AND epp.PayPeriodGenID = pp.PayPeriodGenID
	INNER JOIN Leave.EmployeeLeave el ON el.EmployeePayPeriodID = epp.EmployeePayPeriodID
	INNER JOIN Leave.EmployeeLeavePolicy elp ON elp.EmployeeRuleID = er.EmployeeRuleID AND elp.[Status] = 'A'
	INNER JOIN Leave.LeavePolicy lp ON lp.LeavePolicyID = elp.LeavePolicyID
	INNER JOIN Leave.LeavePolicyDefRel lpdr ON lpdr.LeavePolicyID = elp.LeavePolicyID AND lpdr.LeaveDefID = el.LeaveDefID
	INNER JOIN Leave.LeaveDef ld ON ld.LeaveDefID = lpdr.LeaveDefID
	INNER JOIN Leave.LeaveType lt ON lt.LeaveTypeID = ld.LeaveTypeID
WHERE e.EmployeeCode + c.CompanyCode + lt.Code IN (SELECT DISTINCT EmployeeCode + CompanyCode + LeaveTypeCode FROM ##LeaveTypesPerEmployee)
GROUP BY ld.LeaveTypeID
	,e.EmployeeID
	,e.EmployeeCode
	,e.CompanyID
	,c.CompanyCode
	,e.DateEngaged
	,e.TerminationDate
	,lp.LongDescription
	,lt.Code
	,lt.LongDescription
	,lpdr.Sequence
	,ld.LeaveDefID
	,ld.Code
	,ld.LongDescription
ORDER BY e.EmployeeCode, ld.LeaveTypeID



DECLARE @EmployeeCode varchar(15), @LeaveTypeCode varchar(15)
	,@TotalRunningUnits decimal(18,2),@CurrentUnitAdjust decimal(18,2),@CurrentSequence int
	,@CombinedLeaveCodeRef varchar(max)

WHILE EXISTS (SELECT TOP 1 * FROM ##LeaveTypesPerEmployee ORDER BY EmployeeCode, LeaveTypeCode)
BEGIN	

	SET @EmployeeCode = (SELECT TOP 1 EmployeeCode FROM ##LeaveTypesPerEmployee ORDER BY EmployeeCode, LeaveTypeCode)
	SET @LeaveTypeCode = (SELECT TOP 1 LeaveTypeCode FROM ##LeaveTypesPerEmployee ORDER BY EmployeeCode, LeaveTypeCode)
	SET @TotalRunningUnits = (SELECT TOP 1 TotalUnits FROM ##LeaveTypesPerEmployee ORDER BY EmployeeCode, LeaveTypeCode)
	SET @CombinedLeaveCodeRef = (SELECT TOP 1 LeaveCode FROM ##LeaveTypesPerEmployee ORDER BY EmployeeCode, LeaveTypeCode)
	

	--For each Definition within the Leave Type
	WHILE EXISTS (SELECT TOP 1 * FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode ORDER BY [Sequence])
	BEGIN

	
	SET @CurrentSequence = (SELECT TOP 1 CONVERT(int,[Sequence]) FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode ORDER BY [Sequence])
	--Steps: For each definition in type
	--If total units less than zero, then it should check the history, or for now just add to first priority
	--Loop through each definition and write to the Balance Queue to log the current balance, amount taken off and transaction tracking fields.

	IF (@TotalRunningUnits > 0)
	BEGIN

	SET @CurrentUnitAdjust = (SELECT TOP 1 CASE WHEN @TotalRunningUnits > BalanceIncludingPlanned THEN BalanceIncludingPlanned ELSE @TotalRunningUnits END [CurrentAdjust]
							FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode)
			
			--Check if the @CurrentSequence is the final line
			IF ((SELECT TOP 1 LveDefCount FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode ORDER BY [Sequence]) <> @CurrentSequence)
			BEGIN
				INSERT INTO AI.LeaveBalanceQueue (EventCode,EventDescription,EventSequenceID,CompanyCode,EmployeeCode,LeaveTypeCode,LeaveCode,CurrentStartBalance,CurrentAccrual,CurrentTaken
						,CurrentAdjustment,CurrentEndBalance,CurrentPlanned,UnitAdjustment,UnitOverride,EndBalanceIncludingAdjustment,Note,DateCreated,StatusCode)
						SELECT 'New','New Leave Balance Adjustment',l.[Sequence],l.CompanyCode,l.EmployeeCode,l.LeaveTypeCode,l.LeaveDefCode
							,BalanceBroughtForward [CurrentStartBalance]
							,AccruedThisPeriod [CurrentAccrual]
							,TakenThisPeriod [CurrentTaken]
							,Adjustment [CurrentAdjustment]
							,BalanceCarriedForward [CurrentEndBalance]
							,PlannedLeave [CurrentPlanned]
							,@CurrentUnitAdjust [UnitAdjustment]
							,@CurrentUnitAdjust + ISNULL(l.Adjustment,0) [UnitOverride]
							,BalanceCarriedForward + @TotalRunningUnits + ISNULL(l.Adjustment,0) [EndBalanceIncludingAdjustment]
							,@CombinedLeaveCodeRef [Note]
							,GETDATE(),'New'
						FROM (SELECT TOP 1 * FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode) l
					SET @TotalRunningUnits = @TotalRunningUnits - @CurrentUnitAdjust
			END
			ELSE
				BEGIN
					INSERT INTO AI.LeaveBalanceQueue (EventCode,EventDescription,EventSequenceID,CompanyCode,EmployeeCode,LeaveTypeCode,LeaveCode,CurrentStartBalance,CurrentAccrual,CurrentTaken
						,CurrentAdjustment,CurrentEndBalance,CurrentPlanned,UnitAdjustment,UnitOverride,EndBalanceIncludingAdjustment,Note,DateCreated,StatusCode)
						SELECT 'New','New Leave Balance Adjustment',l.[Sequence],l.CompanyCode,l.EmployeeCode,l.LeaveTypeCode,l.LeaveDefCode
							,BalanceBroughtForward [CurrentStartBalance]
							,AccruedThisPeriod [CurrentAccrual]
							,TakenThisPeriod [CurrentTaken]
							,Adjustment [CurrentAdjustment]
							,BalanceCarriedForward [CurrentEndBalance]
							,PlannedLeave [CurrentPlanned]
							,@TotalRunningUnits [UnitAdjustment]
							,@TotalRunningUnits + ISNULL(l.Adjustment,0) [UnitOverride]
							,BalanceCarriedForward + @TotalRunningUnits + ISNULL(l.Adjustment,0) [EndBalanceIncludingAdjustment]
							,@CombinedLeaveCodeRef [Note]
							,GETDATE(),'New'
						FROM (SELECT TOP 1 * FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode) l
					SET @TotalRunningUnits = 0
				END

		END
		ELSE
		BEGIN
			INSERT INTO AI.LeaveBalanceQueue (EventCode,EventDescription,EventSequenceID,CompanyCode,EmployeeCode,LeaveTypeCode,LeaveCode,CurrentStartBalance,CurrentAccrual,CurrentTaken
				,CurrentAdjustment,CurrentEndBalance,CurrentPlanned,UnitAdjustment,UnitOverride,EndBalanceIncludingAdjustment,Note,DateCreated,StatusCode)
				SELECT 'New','New Leave Balance Adjustment',l.[Sequence],l.CompanyCode,l.EmployeeCode,l.LeaveTypeCode,l.LeaveDefCode
					,BalanceBroughtForward [CurrentStartBalance]
					,AccruedThisPeriod [CurrentAccrual]
					,TakenThisPeriod [CurrentTaken]
					,Adjustment [CurrentAdjustment]
					,BalanceCarriedForward [CurrentEndBalance]
					,PlannedLeave [CurrentPlanned]
					,@TotalRunningUnits [UnitAdjustment]
					,@TotalRunningUnits + ISNULL(l.Adjustment,0) [UnitOverride]
					,BalanceCarriedForward + @TotalRunningUnits + ISNULL(l.Adjustment,0) [EndBalanceIncludingAdjustment]
					,@CombinedLeaveCodeRef [Note]
					,GETDATE(),'New'
				FROM (SELECT TOP 1 * FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode) l
			SET @TotalRunningUnits = 0
		END

	DELETE TOP (1) FROM ##DefOrderPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode AND [Sequence] = @CurrentSequence
	END

DELETE FROM ##LeaveTypesPerEmployee WHERE EmployeeCode = @EmployeeCode AND LeaveTypeCode = @LeaveTypeCode
UPDATE AI.LeaveTransactionQueue SET StatusCode = 'Moved' WHERE StatusCode = 'New'


--Validations on BalanceQueue after transactions have been moved
--Old Termination is included.
UPDATE AI.LeaveBalanceQueue SET StatusCode = 'Warning', StatusMessage = ISNULL(StatusMessage,'')+'Employee terminated in previous period|', WarningCode = ISNULL(WarningCode,'')+'Terminated|', WarningMessage = ISNULL(WarningMessage,'')+'Terminated employee ('+q.EmployeeCode+') in company ('+q.CompanyCode+') is included for processing|'
FROM AI.LeaveBalanceQueue q
	INNER JOIN AI.EmployeeContractSequence i ON i.EmployeeCode = q.EmployeeCode AND i.ContractSequenceByEmployeeCode = 1 
	INNER JOIN Company.Company c ON c.CompanyID = i.CompanyID
WHERE i.EmployeeStatusID IN (3)
	AND StatusCode = 'New'


--Result will be a negative balance
UPDATE AI.LeaveBalanceQueue SET StatusCode = 'Warning', StatusMessage = ISNULL(StatusMessage,'')+'Balance will result in a negative|', WarningCode = ISNULL(WarningCode,'')+'Negative|', WarningMessage = ISNULL(WarningMessage,'')+'Value for Employee ('+q.EmployeeCode+') in company ('+q.CompanyCode+') will result in a negative|'
FROM AI.LeaveBalanceQueue q
WHERE q.UnitOverride < 0
	AND StatusCode = 'New'


END

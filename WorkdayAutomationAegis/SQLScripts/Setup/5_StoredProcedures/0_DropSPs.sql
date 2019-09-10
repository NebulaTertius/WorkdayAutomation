IF OBJECT_ID('AI.EmployeeBatchValidations', 'P') IS NOT NULL DROP PROCEDURE AI.EmployeeBatchValidations
IF OBJECT_ID('AI.MappingValidations', 'P') IS NOT NULL DROP PROCEDURE AI.MappingValidations
IF OBJECT_ID('AI.ProcessEmployeeQueue', 'P') IS NOT NULL DROP PROCEDURE AI.ProcessEmployeeQueue
IF OBJECT_ID('AI.FinancialBatchSP', 'P') IS NOT NULL DROP PROCEDURE AI.FinancialBatchSP
IF OBJECT_ID('AI.ProcessFinancialQueue', 'P') IS NOT NULL DROP PROCEDURE AI.ProcessFinancialQueue
IF OBJECT_ID('AI.RefreshValidationWarnings', 'P') IS NOT NULL DROP PROCEDURE AI.RefreshValidationWarnings
IF OBJECT_ID('AI.LeaveTransactionToBalanceQueue', 'P') IS NOT NULL DROP PROCEDURE AI.LeaveTransactionToBalanceQueue
IF OBJECT_ID('AI.ProcessLeaveQueue', 'P') IS NOT NULL DROP PROCEDURE AI.ProcessLeaveQueue
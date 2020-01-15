CREATE PROCEDURE [AI].[AutoCreateHierarchy]
AS


BEGIN TRY BEGIN TRANSACTION 

--***Important Note
--Table version must be updated to force a cache refresh after direct SQL insert of a new item to be linked, before a batch is processed.
--The batch processing uses the local cache to link Hierarchy's, Job Costing and Batch Items, and either results in an Object reference error, or processes without an error, but does not update the field

SELECT 1

--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'JobGradeList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'JobTitleTypeList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'HierarchyHeaderList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'HierarchyList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'HierarchyHeaderCompanyRelList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'NatureOfContractList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'BankList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'BankBranchList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'WorkDayList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'JobCostingProfileList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'LevelDefinitionList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'JobCostingGroupList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'LevelSetupList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'LevelSetupTranCodeRateRelList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'ShiftDefList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'BatchTemplateList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'BatchItemList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'FunctionList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'JobGeneralList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'LevelOfWorkList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'CriticalPositionList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'OccupationalLevelTypeList'
--UPDATE dbo.TableVersion SET [Version] = [Version] + 1 WHERE [Name] = 'OFOVersionTypeList'
--etc

IF ((SELECT XACT_STATE()) = 1) COMMIT TRANSACTION END TRY 
BEGIN CATCH IF ((SELECT XACT_STATE()) = -1) ROLLBACK TRANSACTION END CATCH

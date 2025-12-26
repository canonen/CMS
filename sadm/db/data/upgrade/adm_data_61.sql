SET NUMERIC_ROUNDABORT OFF
GO
--SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
--SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO


PRINT 'inserting rows for unsubscribe messages feature'
GO

-- inserting data for Unsubscribe Message feature in britemoon 6.1

-- Insert service_type_id in sadm_service_type
INSERT INTO [brite_sadm_500].[dbo].[sadm_service_type] ([type_id],[type_name]) VALUES (102,'SADM_UNSUB_MESSAGE_UPDATE');
IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

-- Insert new feature_id in sadm_feature
INSERT INTO [brite_sadm_500].[dbo].[sadm_feature] ([feature_id],[feature_name]) VALUES (610,'UNSUB_EDIT');
IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

-- Insert new object_type in scps_object_type
INSERT INTO [brite_sadm_500].[dbo].[scps_object_type] ([type_id],[type_name]) VALUES (350,'Unsubscribe Messages');
IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

COMMIT TRANSACTION
GO


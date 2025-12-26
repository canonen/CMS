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

-- data scripts to support Unsubscribe messages feature in Britemoon 6.1

-- Insert new feature_id in ccps_feature
INSERT INTO [dbo].[ccps_feature] ([feature_id],[feature_name]) VALUES (610,'UNSUB_EDIT');

IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

-- Insert new object type in ccps_object_type
INSERT INTO [dbo].[ccps_object_type] ([type_id],[type_name]) VALUES (350,'Unsubscribe Messages');

IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

-- Insert access values for user 77 in ccps_access_mask
INSERT INTO [dbo].[ccps_access_mask] ([user_id],[type_id],[mask]) VALUES (77,350,62);

IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

delete from ccps_registry where key_name = 'image_file_path'
IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

delete from ccps_registry where key_name = 'image_url_path'
IF @@ERROR<>0 AND @@TRANCOUNT>0 PRINT ('ROLLBACK TRANSACTION')
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 END
GO 

INSERT INTO [dbo].[crpt_unsub_level]
           ([level_id]
           ,[level_name])
     VALUES
           (200
           ,'Standard')
GO

INSERT INTO [dbo].[crpt_unsub_level]
           ([level_id]
           ,[level_name])
     VALUES
           (250
           ,'Spam Complaints')
GO

insert into [dbo].[ctgt_filter_type] values (68 ,'RLST_CAMP_UNSUB_WITH_LEVEL');
insert into [dbo].[ctgt_filter_type] values (69 ,'RLST_CAMP_DOMAIN_SPAM_COMPLAINT');

COMMIT TRANSACTION
GO




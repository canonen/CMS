PRINT N'Alter Table [dbo].[cftp_ftp_file]'
GO

IF Exists (Select * from dbo.sysobjects where id = object_id(N'[dbo].[cxcs_file_type]') 
and OBJECTPROPERTY(id, N'IsUserTable') = 1) 
BEGIN 
Exec sp_rename 'cxcs_file_type', 'ccps_file_type' 
  
IF @@Error <> 0 
Raiserror('Failed to rename Table cxcs_file_type to ccps_file_type',16,1) 
ELSE 
Print 'Table cxcs_file_type Renamed to ccps_file_type' 
END 
ELSE 
Print 'Table cxcs_file_type does not exist' 
GO


/*
PRINT N'Adding foreign key to [dbo].[cftp_ftp_file]'
GO
ALTER TABLE [dbo].[cftp_ftp_file] WITH NOCHECK ADD
CONSTRAINT [FK_cft_ftp_file_ccps_file_type] FOREIGN KEY ([type_id]) REFERENCES [dbo].[ccps_file_type] ([type_id])
GO
*/

PRINT N'Renaming Foreign Key  to [dbo].[cxcs_file]'

IF Exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[cxcs_file_type_id_ref_cxcs_file_type') 
and OBJECTPROPERTY(id, N'IsForeignKey') = 1) 
BEGIN 
Exec sp_rename 'cxcs_file_type_id_ref_cxcs_file_type', 'FK_cxcs_file_ccps_file_type', 'OBJECT' 
  
IF @@Error <> 0 
Raiserror('Failed to rename FK cxcs_file_type_id_ref_cxcs_file_type to FK_cxcs_file_ccps_file_type',16,1) 
ELSE 
Print 'FK cxcs_file_type_id_ref_cxcs_file_type Renamed to FK_cxcs_file_ccps_file_type' 
END 
ELSE 
Print 'FK cxcs_file_type_id_ref_cxcs_file_type does not exist' 
END
GO

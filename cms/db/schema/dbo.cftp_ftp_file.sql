PRINT N'Alter Table [dbo].[cftp_ftp_file]'
GO
ALTER TABLE [dbo].[cftp_ftp_file]
	ADD 
	[type_id] [int] NULL
GO


PRINT N'Adding foreign key to [dbo].[cftp_ftp_file]'
GO
ALTER TABLE [dbo].[cftp_ftp_file] DROP CONSTRAINT [FK_cftp_ftp_file_ftp_file_type]
GO

ALTER TABLE [dbo].[cftp_ftp_file] WITH NOCHECK ADD
CONSTRAINT [FK_cftp_ftp_file_ccps_file_type] FOREIGN KEY ([type_id]) REFERENCES [dbo].[ccps_file_type] ([type_id])
GO
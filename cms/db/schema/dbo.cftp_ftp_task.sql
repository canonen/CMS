PRINT N'Alter Table [dbo].[cftp_ftp_task]'
GO
ALTER TABLE [dbo].[cftp_ftp_task]
	ADD 
	[type_id] [int] NULL
GO


PRINT N'Adding foreign key to [dbo].[cftp_ftp_task]'
GO
ALTER TABLE [dbo].[cftp_ftp_task] WITH NOCHECK ADD
CONSTRAINT [FK_cft_ftp_task_ftp_task_type] FOREIGN KEY ([type_id]) REFERENCES [dbo].[cftp_ftp_task_type] ([type_id])
GO
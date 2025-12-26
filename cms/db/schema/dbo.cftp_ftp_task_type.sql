PRINT N'Create Table to [dbo].[cftp_ftp_task_type]'
GO
CREATE TABLE [dbo].[cftp_ftp_task_type]
(
	[type_id] [int] NOT NULL,
        [type_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO

PRINT N'Creating primary key [XPKcftp_ftp_task_type] on [dbo].[cftp_ftp_task_type]'
GO
ALTER TABLE [dbo].[cftp_ftp_task_type] ADD CONSTRAINT [XPKcftp_ftp_task_type] PRIMARY KEY CLUSTERED  ([type_id])
GO

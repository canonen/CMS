SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TABLE [dbo].[ccnt_cont_load_file]
	ADD 
	[content_group] [varchar(255)] NULL
GO

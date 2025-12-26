SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

PRINT N'Altering [dbo].[sadm_customer]'
ALTER TABLE [dbo].[sadm_customer]
	ADD 
	[max_consec_bbacks] [int] NULL,
        [max_consec_bback_days] [int] NULL
        
GO

PRINT N'Altering [dbo].[sadm_customer] columns max_bbacks, max_bback_days'
ALTER TABLE [dbo].[sadm_customer]
	ALTER COLUMN max_bbacks int NULL
GO
ALTER TABLE [dbo].[sadm_customer]
	ALTER COLUMN max_bback_days int NULL
GO

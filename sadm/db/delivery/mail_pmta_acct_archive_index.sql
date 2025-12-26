-- this script should be created on the delivery database
-- currently, it is the mail_pmta_accounting database in app9.010.com
--
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE NONCLUSTERED INDEX [IX_mail_pmta_acct_archive_cust_camp_type] ON [dbo].[mail_pmta_acct_archive] 
(
	[custID] ASC,
	[campID] ASC,
	[reportType] ASC
) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


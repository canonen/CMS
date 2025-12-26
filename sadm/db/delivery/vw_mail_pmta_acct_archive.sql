-- this script should be created on the delivery database
-- currently, it is the mail_pmta_accounting database in app9.010.com
--
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vw_mail_pmta_acct_archive]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[vw_mail_pmta_acct_archive]
GO

CREATE VIEW dbo.vw_mail_pmta_acct_archive 
AS 
SELECT     custID AS cust_id, campID AS camp_id, reportType AS report_type_id, COUNT(*) AS report_total
FROM         dbo.mail_pmta_acct_archive WITH (NOLOCK, INDEX (IX_mail_pmta_acct_archive_cust_camp_type))
GROUP BY custID, campID, reportType 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


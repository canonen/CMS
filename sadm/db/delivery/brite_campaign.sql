-- this script should be created on the delivery database
-- currently, it is the mail_pmta_accounting database in app9.010.com
--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[brite_campaign]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[brite_campaign]
GO

CREATE TABLE [dbo].[brite_campaign] (
	[camp_id] [int] NOT NULL ,
	[cust_id] [int] NULL ,
	[cust_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[camp_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[start_date] [datetime] NULL ,
	[recip_total_qty] [int] NULL ,
	[recip_sent_qty] [int] NULL ,
	[delivered] [int] NULL ,
	[bounced] [int] NULL ,
	[sent_pct] [int] NULL ,
	[acct_pct] [int] NULL ,
	[alert] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_brite_campaign_cust_camp] ON [dbo].[brite_campaign] 
(
	[cust_id] ASC,
	[camp_id] ASC
) ON [PRIMARY]


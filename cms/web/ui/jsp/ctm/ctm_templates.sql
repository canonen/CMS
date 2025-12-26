if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ctm_templates]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ctm_templates]
GO

CREATE TABLE [dbo].[ctm_templates] (
	[template_id] [int] NOT NULL ,
	[category] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[customer_id] [int] NULL ,
	[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[sections_n] [tinyint] NOT NULL ,
	[template_html] [image] NULL ,
	[template_txt] [image] NULL ,
	[small_image] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[large_image] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[global_flag] [tinyint] NULL ,
	[active] [tinyint] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


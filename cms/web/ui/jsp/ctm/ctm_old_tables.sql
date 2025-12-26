if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ctm_templates_old]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ctm_templates_old]
GO

CREATE TABLE [dbo].[ctm_templates_old](
	[template_id] [int] NOT NULL,
	[category] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[customer_id] [int] NULL,
	[name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sections_n] [tinyint] NOT NULL,
	[template_html] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[template_txt] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[template_aol] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[small_image] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[large_image] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[global_flag] [tinyint] NULL,
	[active] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ctm_page_values_old]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ctm_page_values_old]
GO

CREATE TABLE [dbo].[ctm_page_values_old](
	[value_id] [int] NOT NULL,
	[content_id] [int] NOT NULL,
	[input_id] [int] NOT NULL,
	[i_value] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


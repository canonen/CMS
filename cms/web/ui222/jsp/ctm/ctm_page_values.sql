if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ctm_page_values]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ctm_page_values]
GO

CREATE TABLE [dbo].[ctm_page_values] (
	[value_id] [int] NOT NULL ,
	[content_id] [int] NOT NULL ,
	[input_id] [int] NOT NULL ,
	[i_value] [image] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


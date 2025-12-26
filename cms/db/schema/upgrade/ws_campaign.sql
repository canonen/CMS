IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cxcs_cust_resource]') AND type in (N'U'))
DROP TABLE [dbo].[cxcs_cust_resource]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cxcs_cust_resource](
	[cust_id] [int] NOT NULL,
	[resource_id] [int] NOT NULL,
	[username] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[password] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[host] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[url] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[str_value] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[id_value] [int] NULL,
 CONSTRAINT [PK_cxcs_cust_resource] PRIMARY KEY CLUSTERED 
(
	[cust_id] ASC,
	[resource_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cxcs_cust_resource_type]') AND type in (N'U'))
DROP TABLE [dbo].[cxcs_cust_resource_type]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cxcs_cust_resource_type](
	[type_id] [int] NOT NULL,
	[type_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_cxcs_cust_resource_type] PRIMARY KEY CLUSTERED 
(
	[type_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cxcs_ws_campaign]') AND type in (N'U'))
DROP TABLE [dbo].[cxcs_ws_campaign]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cxcs_ws_campaign](
	[cust_id] [int] NOT NULL,
	[ws_camp_id] [int] NOT NULL,
	[status_id] [smallint] NOT NULL,
	[error_msg] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ws_seal_id] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[camp_id] [int] NULL,
	[list_file_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[list_file_count] [int] NULL,
	[clickseal_file_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[import_file_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[import_id] [int] NULL,
	[filter_id] [int] NULL,
	[create_date] [datetime] NOT NULL,
	[modify_date] [datetime] NOT NULL,
 CONSTRAINT [PK_cxcs_ws_campaign] PRIMARY KEY CLUSTERED 
(
	[cust_id] ASC,
	[ws_camp_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO


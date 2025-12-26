PRINT 'Creating [dbo].[ctm_offer]'
GO
/****** Object:  Table [dbo].[ctm_offer]    Script Date: 02/28/2007 15:35:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ctm_offer](
	[offer_id] [int] IDENTITY (1,1) NOT NULL,
	[cust_id] [int] NOT NULL,
	[size_id] [int] NOT NULL,  -- 1 = small; 2 = large 
	[name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[headline_html] [image] NULL,
        [detail_html] [image] NULL,
        [image_url] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[detail_text] [image] NOT NULL,
        [last_send_date] [DATETIME] NULL,
 CONSTRAINT [XPKctm_offer] PRIMARY KEY CLUSTERED 
(
	[offer_id] ASC,
	[cust_id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO


SET ANSI_PADDING OFF

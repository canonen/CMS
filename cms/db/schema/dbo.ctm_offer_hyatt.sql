PRINT 'Creating [dbo].[ctm_offer_hyatt]'
GO
/****** Object:  Table [dbo].[ctm_offer_hyatt]    Script Date: 02/28/2007 15:35:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ctm_offer_hyatt](
	[offer_id] [int] NOT NULL,
	[cust_id] [int] NOT NULL,
        [hotel_id] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[brand_code] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
    	
 CONSTRAINT [XPKctm_offer_hyatt] PRIMARY KEY CLUSTERED 
(
	[offer_id] ASC,
	[cust_id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] 

GO
SET ANSI_PADDING OFF


PRINT N'Adding foreign key to [dbo].[ctm_offer_hyatt]'
GO
ALTER TABLE [dbo].[ctm_offer_hyatt] WITH CHECK ADD
CONSTRAINT [FK_ctm_offer_hyatt_ctm_offer] FOREIGN KEY ([offer_id],[cust_id]) REFERENCES [dbo].[ctm_offer] ([offer_id],[cust_id])
GO


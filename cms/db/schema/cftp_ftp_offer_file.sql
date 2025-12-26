PRINT 'Creating [dbo].[cftp_ftp_offer_file]'
GO
/****** Object:  Table [dbo].[cftp_ftp_offer_file]    Script Date: 02/28/2007 15:35:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[cftp_ftp_offer_file](
	[original_file_id] [int] NOT NULL,
	[offer_file_id] [int] NOT NULL,
	[type_id] [int] NOT NULL,
	[offer_file_name] varchar(255) NULL,
	[offer_file_path] varchar(255) NULL,
CONSTRAINT [pk_cftp_ftp_offer_zip_file] PRIMARY KEY CLUSTERED
(
	[original_file_id] ASC,
	[offer_file_id] ASC
) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY=OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[cftp_ftp_offer_file]  WITH NOCHECK ADD  CONSTRAINT [cftp_ftp_offer_file_cftp_ftp_file] FOREIGN KEY([original_file_id])
REFERENCES [dbo].[cftp_ftp_file] ([file_id])
GO
ALTER TABLE [dbo].[cftp_ftp_offer_file] CHECK CONSTRAINT [cftp_ftp_offer_file_cftp_ftp_file]
GO
ALTER TABLE [dbo].[cftp_ftp_offer_file]  WITH CHECK ADD  CONSTRAINT [cftp_ftp_offer_file_ccps_file_type] FOREIGN KEY([type_id])
REFERENCES [dbo].[ccps_file_type] ([type_id])
GO
ALTER TABLE [dbo].[cftp_ftp_offer_file] CHECK CONSTRAINT [cftp_ftp_offer_file_ccps_file_type]
GO
	
	
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'Altering [dbo].[ccnt_cont_part]'
ALTER TABLE [dbo].[ccnt_cont_part] 
    ADD
    [max_elements_in_logic_block] [int] NULL
GO

PRINT N'Altering [dbo].[ccnt_cont_load_file]'
ALTER TABLE [dbo].[ccnt_cont_load_file]
	ADD 
	[content_group] [varchar] (255) NULL
GO

PRINT N'Altering [dbo].[ccps_customer]'
ALTER TABLE [dbo].[ccps_customer]
	ADD 
	[max_consec_bbacks] [int] NULL,
    [max_consec_bback_days] [int] NULL
GO

--PRINT N'Altering [dbo].[ccps_customer]'
--ALTER TABLE [dbo].[ccps_customer]
--	MODIFY 
--	[max_bbacks] [int] NULL,
--    [max_bback_days] [int] NULL
--GO

PRINT N'Altering [dbo].[ccps_customer] columns max_bbacks, max_bback_days'
ALTER TABLE [dbo].[ccps_customer]
	ALTER COLUMN max_bbacks int NULL
GO
ALTER TABLE [dbo].[ccps_customer]
	ALTER COLUMN max_bback_days int NULL
GO

PRINT N'Altering [dbo].[cque_camp_sample]'
ALTER TABLE [dbo].[cque_camp_sample]
	ADD 
    [reply_to] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [filter_id] [int] NULL,
    [priority] [int] NULL
GO

PRINT N'Altering [dbo].[cque_camp_sampleset]'
ALTER TABLE [dbo].[cque_camp_sampleset]
	ADD 
    [filter_flag] [tinyint] NULL,
    [reply_to_flag] [tinyint] NULL
GO


PRINT N'Altering [dbo].[cque_campaign]'
ALTER TABLE [dbo].[cque_campaign]
	ADD 
    [sample_filter_id] [int] NULL,
    [sample_priority] [int] NULL,
    [camp_code] varchar(255) NULL
GO

PRINT N'Altering [dbo].[crpt_camp_domain]'
ALTER TABLE [dbo].[crpt_camp_domain]
	ADD 
    [spam_complaints] [int] NULL
GO

PRINT N'Altering [dbo].[crpt_camp_domain_cache]'
ALTER TABLE [dbo].[crpt_camp_domain_cache]
	ADD 
    [spam_complaints] [int] NULL
GO

PRINT N'Creating [dbo].[crpt_unsub_level]'
CREATE TABLE [dbo].[crpt_unsub_level](
	[level_id] [int] NOT NULL,
	[level_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_crpt_unsub_level] PRIMARY KEY CLUSTERED 
(
	[level_id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

PRINT N'Creating [dbo].[crpt_camp_unsub]'
CREATE TABLE [dbo].[crpt_camp_unsub](
	[camp_id] [int] NOT NULL,
	[level_id] [int] NOT NULL,
	[unsubs] [int] NULL,
 CONSTRAINT [PK_crpt_camp_unsub] PRIMARY KEY CLUSTERED 
(
	[camp_id] ASC,
	[level_id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crpt_camp_unsub]  WITH CHECK ADD  CONSTRAINT [FK_crpt_camp_unsub_crpt_camp_summary] FOREIGN KEY([camp_id])
REFERENCES [dbo].[crpt_camp_summary] ([camp_id])
GO
ALTER TABLE [dbo].[crpt_camp_unsub] CHECK CONSTRAINT [FK_crpt_camp_unsub_crpt_camp_summary]
GO
ALTER TABLE [dbo].[crpt_camp_unsub]  WITH CHECK ADD  CONSTRAINT [FK_crpt_camp_unsub_crpt_unsub_level] FOREIGN KEY([level_id])
REFERENCES [dbo].[crpt_unsub_level] ([level_id])
GO
ALTER TABLE [dbo].[crpt_camp_unsub] CHECK CONSTRAINT [FK_crpt_camp_unsub_crpt_unsub_level]
GO

PRINT N'Creating [dbo].[crpt_camp_unsub_cache]'
CREATE TABLE [dbo].[crpt_camp_unsub_cache](
	[cache_id] [int] NOT NULL,
	[level_id] [int] NOT NULL,
	[unsubs] [int] NULL,
	[camp_id] [int] NOT NULL,
 CONSTRAINT [PK_crpt_camp_unsub_cache] PRIMARY KEY CLUSTERED 
(
	[cache_id] ASC,
	[level_id] ASC,
	[camp_id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crpt_camp_unsub_cache]  WITH CHECK ADD  CONSTRAINT [FK_crpt_camp_unsub_cache_crpt_camp_summary_cache] FOREIGN KEY([camp_id], [cache_id])
REFERENCES [dbo].[crpt_camp_summary_cache] ([camp_id], [cache_id])
GO
ALTER TABLE [dbo].[crpt_camp_unsub_cache] CHECK CONSTRAINT [FK_crpt_camp_unsub_cache_crpt_camp_summary_cache]
GO
ALTER TABLE [dbo].[crpt_camp_unsub_cache]  WITH CHECK ADD  CONSTRAINT [FK_crpt_camp_unsub_cache_crpt_unsub_level] FOREIGN KEY([level_id])
REFERENCES [dbo].[crpt_unsub_level] ([level_id])
GO
ALTER TABLE [dbo].[crpt_camp_unsub_cache] CHECK CONSTRAINT [FK_crpt_camp_unsub_cache_crpt_unsub_level]
GO

alter table [dbo].[crpt_camp_domain]  add  spam_complaints [int] NULL
GO
alter table [dbo].[crpt_camp_domain_cache]  add  spam_complaints [int] NULL
GO

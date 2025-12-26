-- this script should be created on the delivery database
-- currently, it is the mail_pmta_accounting database in app9.010.com
--
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_brite_campaign_save]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_brite_campaign_save]
GO



CREATE PROCEDURE usp_brite_campaign_save
(
	@camp_id int = NULL,
	@cust_id int = NULL,
	@camp_name varchar(255) = NULL,
	@cust_name varchar(255) = NULL,
	@start_date datetime = NULL,
	@recip_total_qty int = NULL,
	@recip_sent_qty int = NULL
)
AS

IF EXISTS (SELECT TOP 1 * FROM brite_campaign WHERE (camp_id = @camp_id))
BEGIN
	UPDATE brite_campaign
		SET
			cust_id = @cust_id,
			camp_name = @camp_name,
			cust_name = @cust_name,
			start_date = @start_date,
			recip_total_qty = @recip_total_qty,
			recip_sent_qty = @recip_sent_qty
		WHERE
			(camp_id = @camp_id)
END
ELSE
BEGIN
	INSERT brite_campaign
		(
			camp_id,
			cust_id,
			camp_name,
			cust_name,
			start_date,
			recip_total_qty,
			recip_sent_qty
		)
		VALUES
		(
			@camp_id,
			@cust_id,
			@camp_name,
			@cust_name,
			@start_date,
			@recip_total_qty,
			@recip_sent_qty
		)
END

SELECT @camp_id
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


-- this script should be created on the delivery database
-- currently, it is the mail_pmta_accounting database in app9.010.com
--
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_update_brite_campaigns]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[usp_update_brite_campaigns]
GO

CREATE PROCEDURE usp_update_brite_campaigns
(
	@started_past_hours  int = NULL,
	@hm_camp_bounce_limit int = NULL,
	@hm_camp_deliver_limit int = NULL,
	@hm_camp_deliver_wait int = NULL
)
AS

DECLARE @hm_bad_word varchar(255)
IF (@hm_bad_word IS NULL)  SET @hm_bad_word  = 'BAD'

IF (@started_past_hours IS NULL)  SET @started_past_hours = 336
IF (@hm_camp_bounce_limit IS NULL)  SET @hm_camp_bounce_limit = 12
IF (@hm_camp_deliver_wait IS NULL)  SET @hm_camp_deliver_wait  = 180
IF (@hm_camp_deliver_limit  IS NULL)  SET @hm_camp_deliver_limit  = 80

UPDATE brite_campaign
   SET delivered = (SELECT ISNULL(report_total,0) 
                      FROM vw_mail_pmta_acct v
                     WHERE brite_campaign.cust_id = v.cust_id 
                       AND brite_campaign.camp_id = v.camp_id 
                       AND 'delivered' = v.report_type_id)

UPDATE brite_campaign
   SET delivered = ISNULL(delivered,0) +
                   (SELECT ISNULL(report_total,0)  
                      FROM vw_mail_pmta_acct_archive v
                     WHERE brite_campaign.cust_id = v.cust_id 
                       AND brite_campaign.camp_id = v.camp_id 
                       AND 'delivered' = v.report_type_id)
 WHERE EXISTS (SELECT * 
                 FROM mail_pmta_acct_archive t WITH(NOLOCK, INDEX(IX_mail_pmta_acct_archive_cust_camp_type))
                WHERE brite_campaign.cust_id = t.custId 
                  AND brite_campaign.camp_id = t.campId
                  AND 'delivered' = t.reportType)

UPDATE brite_campaign
   SET bounced = (SELECT ISNULL(report_total,0)  
                      FROM vw_mail_pmta_acct v
                     WHERE brite_campaign.cust_id = v.cust_id 
                       AND brite_campaign.camp_id = v.camp_id 
                       AND 'bounced' = v.report_type_id)

UPDATE brite_campaign
   SET bounced = ISNULL(bounced,0) +
                 (SELECT ISNULL(report_total,0) 
                    FROM vw_mail_pmta_acct_archive v
                   WHERE brite_campaign.cust_id = v.cust_id 
                     AND brite_campaign.camp_id = v.camp_id 
                     AND 'bounced' = v.report_type_id)
 WHERE EXISTS (SELECT * 
                 FROM mail_pmta_acct_archive t WITH(NOLOCK, INDEX(IX_mail_pmta_acct_archive_cust_camp_type))
                WHERE brite_campaign.cust_id = t.custId 
                  AND brite_campaign.camp_id = t.campId
                  AND 'bounced' = t.reportType)

UPDATE brite_campaign
       SET sent_pct = 100 * recip_sent_qty / recip_total_qty
WHERE recip_total_qty > 0

UPDATE brite_campaign
       SET acct_pct = 100 * (delivered + bounced)  / recip_sent_qty
WHERE recip_sent_qty > 0

UPDATE brite_campaign
       SET  alert = @hm_bad_word + ' - bounce rate is too high'
WHERE( recip_sent_qty > 0) 
     AND (bounced / recip_sent_qty > @hm_camp_bounce_limit)

UPDATE brite_campaign
       SET  alert = @hm_bad_word + ' - dispatched msg un-accounted for  is too high'
WHERE (acct_pct < @hm_camp_deliver_limit)
     AND  (DATEDIFF(mi, start_date,getDate()) > @hm_camp_deliver_wait)

DELETE FROM brite_campaign WHERE DATEDIFF(hh, start_date,getDate()) > @started_past_hours

SELECT @@rowcount
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


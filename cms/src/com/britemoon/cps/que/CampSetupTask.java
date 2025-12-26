package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class CampSetupTask extends BriteTask
{
	private Campaign m_Camp = null;
	private static Logger logger = Logger.getLogger(CampSetupTask.class.getName());

	public CampSetupTask(String sCampId) throws Exception
	{
		Campaign camp = new Campaign(sCampId);
		init(camp);
	}
		
	public CampSetupTask(Campaign camp)
	{
		init(camp);
	}
	
	private void init(Campaign camp)
	{
		m_Camp = camp;
		
		// === === ===
		
		setTaskName("CampSetupTask");
		
		setCustId(camp.s_cust_id);
		setIdName("Campaign");
		setId(camp.s_camp_id);
		setStringComment(camp.s_camp_name);

		setCreateDate(new java.util.Date());
	}

	public void start() throws Exception
	{
		String sCampId = m_Camp.s_camp_id;
		logger.info(this + " camp_id = " + sCampId + " started at " + new java.util.Date());
		startStatic(sCampId);
		logger.info(this + " camp_id = " + sCampId + " finished at " + new java.util.Date());
	}
	
	public void startStatic(String sCampId) throws Exception
	{
		CampSetupStatus cssSetupStatus = new CampSetupStatus(sCampId);

		String sErrMsg =
			"CampSetupTask ERROR: cannot setup campaign " + cssSetupStatus.s_camp_id;
		
		// === RCP ===

		if (cssSetupStatus.s_rcp_status == null)
		{
			try
			{
				CampSetupUtil.doRcpSetup(sCampId);
				cssSetupStatus.s_rcp_status = "1";
			}
			catch(Exception ex)
			{
				logger.error(sErrMsg + " on RCP", ex);
				throw ex;
			}
		}

		// === JTK ===
		
		if (cssSetupStatus.s_jtk_status == null)
		{
			try
			{
				CampSetupUtil.doJtkSetup(sCampId);
				cssSetupStatus.s_jtk_status = "1";
			}
			catch(Exception ex)
			{
				logger.error(sErrMsg + " on JTK", ex);
				throw ex;
			}
		}

		// === INB ===
		
		if (cssSetupStatus.s_inb_status == null)
		{
			try
			{
				CampSetupUtil.doInbSetup(sCampId);
				cssSetupStatus.s_inb_status = "1";
			}
			catch(Exception ex)
			{
				logger.error(sErrMsg + " on INB", ex);
				throw ex;
			}
		}

		// === MAILER ===
		
		cssSetupStatus.retrieve(); // <-- this should be removed
				
		if (cssSetupStatus.s_jtk_status == null) return;

		if (cssSetupStatus.s_mailer_status == null)
		{
			try
			{
				CampSetupUtil.doMailerSetup(sCampId);
				cssSetupStatus.s_mailer_status = "1";				
			}
			catch(Exception ex)
			{
				logger.error(sErrMsg + " for MAILER", ex);
				throw ex;				
			}
		}
		
		// === === ===

		cssSetupStatus.retrieve(); // <-- this should be removed
		
		if (cssSetupStatus.s_rcp_status == null) return;
		if (cssSetupStatus.s_jtk_status == null) return;
		if (cssSetupStatus.s_inb_status == null) return;
		if (cssSetupStatus.s_mailer_status == null) return;
		
		String sSql =
			" UPDATE cque_campaign" +
			" SET status_id = " + CampaignStatus.READY_TO_SEND +
			" WHERE camp_id = " + sCampId +
			" AND status_id < " + CampaignStatus.READY_TO_SEND;
		BriteUpdate.executeUpdate(sSql);
	}
}

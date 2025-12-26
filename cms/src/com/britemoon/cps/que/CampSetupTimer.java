package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class CampSetupTimer extends BriteTimer
{
	private static Logger logger = Logger.getLogger(CampSetupTimer.class.getName());
	public CampSetupTimer(String sTimerNameSuffix)
	{
		String sName = this.getClass().getName().replaceFirst("com.britemoon.","");
		sName += sTimerNameSuffix;
		setTimerName(sName);
		init();
	}

	public Vector buildTaskList()
	{
		Vector vTaskList = new Vector();
		
		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			Statement stmt  = null;
			ResultSet rs = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("CampSetupTimer");

			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT c.camp_id" +
					" FROM cque_campaign c" +
						" LEFT OUTER JOIN cque_camp_setup_status css" +
							" ON c.camp_id = css.camp_id" +
							" AND ((css.rcp_status + css.jtk_status + css.inb_status + css.mailer_status) IS NULL)" +
					" WHERE c.status_id >= " + CampaignStatus.RECIPS_QUEUED + // ??? CampaignStatus.SENT_TO_RCP
						" AND	c.status_id < " + CampaignStatus.READY_TO_SEND +
						" AND c.type_id <> " + CampaignType.NON_EMAIL +
						" AND (c.media_type_id IS NULL OR c.media_type_id = 1) " + 
						" AND c.origin_camp_id IS NOT NULL " + 
					" ORDER BY c.camp_id";
					
				rs = stmt.executeQuery(sSql);
				
				String sCampId = null;

				byte[] b = null;
				CampSetupTask camp_setup_task = null;				
				while (rs.next())
				{
					sCampId = rs.getString(1);
					camp_setup_task = new CampSetupTask(sCampId);
					vTaskList.add(camp_setup_task);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) { logger.error("Exception: ", ex); }
		finally { if (conn!=null) cp.free(conn); }
	
		// sleep anyway
		// if setup failed there is no reasone to retry it immediatelly
		vTaskList.add(new SleepTask(findSleepInterval()));
		
		return vTaskList;
	}

	// === === ===

	public long findSleepInterval()
	{
		long lSleepInterval = 60000;
		
		try
		{
			String sSleepInterval = Registry.getKey("default_camp_setup_sleep");
			if (sSleepInterval != null) lSleepInterval = Long.parseLong(sSleepInterval);
		}
		catch(Exception ex)
		{
			lSleepInterval = 60000;
		}
		
		return lSleepInterval;
	}
}

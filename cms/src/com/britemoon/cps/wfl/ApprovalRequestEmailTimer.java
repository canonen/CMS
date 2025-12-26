package com.britemoon.cps.wfl;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.que.*;
import com.britemoon.cps.upd.*;

import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class ApprovalRequestEmailTimer extends BriteTimer
{
    private static Logger logger = Logger.getLogger(ApprovalRequestEmailTimer.class.getName());	
	public ApprovalRequestEmailTimer(String sTimerNameSuffix)
	{
		String sName = this.getClass().getName().replaceFirst("com.britemoon.","");
		sName += sTimerNameSuffix;
		setTimerName(sName);
		init();
	}

	/* Runs tasks for both Campaign and Filter Approval requests. */
     public Vector buildTaskList()
	{
		Vector vTaskList = new Vector();
          buildCampEmailTaskList(vTaskList);
          buildFilterEmailTaskList(vTaskList);
			
		// sleep anyway
		// if setup failed there is no reason to retry it immediatelly
		vTaskList.add(new SleepTask(findSleepInterval()));
		
		return vTaskList;
	}

     private void buildCampEmailTaskList(Vector vTaskList) {

		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			Statement stmt  = null;
			ResultSet rs = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ApprovalRequestEmailTimer.Camp()");

			try
			{
				stmt = conn.createStatement();

				// Find approval requests that have not yet sent the request for approval email
				String sSql = "Select ar.approval_request_id, max(camp.camp_id) " +
                                        " FROM " +
                                             " ccps_aprvl_request ar WITH(NOLOCK), " +
                                             " ccps_aprvl_task at WITH(NOLOCK), " +
                                             " cque_campaign camp WITH(NOLOCK), " +
                                             " cque_camp_statistic cstat WITH(NOLOCK) " +
                                        " WHERE " +
                                             " ar.active_flag = 1 AND " +
                                             " ar.email_sent_date is NULL AND " +
                                             " ar.aprvl_id = at.approval_id AND " +
                                             " at.active_flag = 1 AND " +
                                             " at.object_type = " + ObjectType.CAMPAIGN + " AND " +
                                             " at.object_id = camp.origin_camp_id AND " +
                                             " (at.camp_sample_flag is null or at.camp_sample_flag = 0) AND " +
                                             " camp.sample_id is null AND " +
                                             " camp.type_id = 1 AND " +
                                             " camp.mode_id = 20 AND " +
                                             " cstat.camp_id = camp.camp_id AND " +
                                             " cstat.recip_total_qty > 0 " +
                                             " GROUP by ar.approval_request_id " +
                                             " UNION " +
                                        "Select ar.approval_request_id, max(camp.camp_id) " +
                                        " FROM " +
                                             " ccps_aprvl_request ar WITH(NOLOCK), " +
                                             " ccps_aprvl_task at WITH(NOLOCK), " +
                                             " cque_campaign camp WITH(NOLOCK), " +
                                             " cque_camp_statistic cstat WITH(NOLOCK) " +
                                        " WHERE " +
                                             " ar.active_flag = 1 AND " +
                                             " ar.email_sent_date is NULL AND " +
                                             " ar.aprvl_id = at.approval_id AND " +
                                             " at.active_flag = 1 AND " +
                                             " at.object_type = " + ObjectType.CAMPAIGN + " AND " +
                                             " at.object_id = camp.origin_camp_id AND " +
                                             " at.camp_sample_flag = 1 AND " +
                                             " camp.sample_id is not null AND " +
                                             " camp.type_id = 1 AND " +
                                             " camp.mode_id = 20 AND " +
                                             " cstat.camp_id = camp.camp_id AND " +
                                             " cstat.recip_total_qty > 0 " +
                                             " GROUP by ar.approval_request_id ";
					
				rs = stmt.executeQuery(sSql);
				
				String sApprovalRequestId = null;
                    String sCampId = null;

				CampApprovalRequestEmailTask camp_aprvl_request_email_task = null;				
				while (rs.next())
				{
					sApprovalRequestId = rs.getString(1);
					sCampId = rs.getString(2);
					camp_aprvl_request_email_task = new CampApprovalRequestEmailTask(sApprovalRequestId, sCampId);
					vTaskList.add(camp_aprvl_request_email_task);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ", ex); 
		}
		finally { if (conn!=null) cp.free(conn); }
	
	}

     private void buildFilterEmailTaskList(Vector vTaskList) {

		ConnectionPool cp = null;
		Connection conn = null;
		
		try
		{
			Statement stmt  = null;
			ResultSet rs = null;

			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("ApprovalRequestEmailTimer.Filter()");

			try
			{
				stmt = conn.createStatement();

				// Find approval requests that have not yet sent the request for approval email
				String sSql =
				" SELECT ar.approval_request_id, f.filter_id" +
				" FROM ctgt_filter f WITH(NOLOCK), " +
                    " ccps_aprvl_request ar WITH(NOLOCK), " +
                    " ccps_aprvl_task at  WITH(NOLOCK) " +
				" WHERE f.origin_filter_id IS NULL" +
				" AND f.type_id = " + FilterType.MULTIPART +
				" AND ISNULL(f.aprvl_status_flag,1) = 0 " +
				" AND f.status_id = " + FilterStatus.READY +
                    " AND f.filter_id = at.object_id " +
                    " AND at.object_type = " + ObjectType.FILTER +
                    " AND ar.active_flag = 1 " +
                    " AND ar.email_sent_date is NULL " +
                    " AND ar.aprvl_id = at.approval_id " +
                    " AND at.active_flag = 1";

					
				rs = stmt.executeQuery(sSql);
				
				String sApprovalRequestId = null;
                    String sFilterId = null;

				FilterApprovalRequestEmailTask filt_aprvl_request_email_task = null;				
				while (rs.next())
				{
					sApprovalRequestId = rs.getString(1);
					sFilterId = rs.getString(2);
					filt_aprvl_request_email_task = new FilterApprovalRequestEmailTask(sApprovalRequestId, sFilterId);
					vTaskList.add(filt_aprvl_request_email_task);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) 
		{ 
			logger.error("Exception: ", ex);
		}
		finally { if (conn!=null) cp.free(conn); }
	
	}

	// === === ===

	public long findSleepInterval()
	{
		long lSleepInterval = 60000;
		
		try
		{
			String sSleepInterval = Registry.getKey("default_approval_request_email_sleep");
			if (sSleepInterval != null) lSleepInterval = Long.parseLong(sSleepInterval);
		}
		catch(Exception ex)
		{
			lSleepInterval = 60000;
		}
		
		return lSleepInterval;
	}
}

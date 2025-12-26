package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;
import org.apache.log4j.*;

public class UserNotifyTimer extends BriteTimer
{
	private ServletContext m_Context = null;
	private static Logger logger = Logger.getLogger(UserNotifyTimer.class.getName());
	
	public UserNotifyTimer(String sTimerNameSuffix, ServletContext context)
	{
		m_Context = context;
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
			conn = cp.getConnection("UserNotifyTimer");

			try
			{
				stmt = conn.createStatement();

				String sSql =
					" SELECT u.user_id" +
					" FROM ccps_user u, ccps_customer c" +
					" WHERE" +
					"	u.cust_id = c.cust_id" +
					"	AND datediff(d, GETDATE(), u.pass_exp_date) < c.pass_notify_days" + 
					"	AND	isnull(datediff(d, GETDATE(), u.pass_notify_date), 1) > 0" +
					"	AND	pass_exp_date >= GETDATE()" + 
					" ORDER BY u.user_id";
					
				rs = stmt.executeQuery(sSql);
				
				String sUserId = null;

				UserNotifyTask user_notify_task = null;				
				while (rs.next())
				{
					sUserId = rs.getString(1);
					user_notify_task = new UserNotifyTask(sUserId, m_Context);
					vTaskList.add(user_notify_task);
				}
				rs.close();
			}
			catch(Exception ex) { throw ex; }
			finally { if (stmt!=null) stmt.close(); }
		}
		catch(Exception ex) {logger.error("Exception: ", ex);}
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
			String sSleepInterval = Registry.getKey("default_user_notify_sleep");
			if (sSleepInterval != null) lSleepInterval = Long.parseLong(sSleepInterval);
		}
		catch(Exception ex)
		{
			lSleepInterval = 60000;
		}
		
		return lSleepInterval;
	}
}
